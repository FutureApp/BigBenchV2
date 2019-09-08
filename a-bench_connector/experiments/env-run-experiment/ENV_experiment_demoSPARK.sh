#!/usr/bin/env bash

LB='\033[1;34m'
RR='\033[1;31m'
NC='\033[0m' # No Color

# dep-locations
exutils="../../utils/exutils.sh"


# imports
source $exutils


bench_tag=${LB}[A-Bench]${NC}
ex_tag=${EX_TAG:-DefaultExTag}

loc_des_container="thadoop-hadoop-spark-master-0"

# all functions calls are indicated by prefix <util_xxx>
# Provides some additional and nice features.
source ../../../../../dir_bench/lib_bench/shell/util.sh


# HOME
home_benchmark='../../../..'
home_framework='../../../../..'
home_charts='../../charts'
home_dockerfile='../../images/hive'

container_home__bench='/bigbenchv2'

function check_query_number () {
    queryLikeToRun=$1
    if [ -z "$queryLikeToRun" ]; then
        echo "Error, you called the experiment without defining which experiment you would like to executes."; \
        exit 1
    fi
    
    echo "$queryLikeToRun"
}


if [[ $# -eq 0 ]] ; then
    ./$0 --help
    exit 0
fi

for var in "$1"
do
case  $var  in

#--------------------------------------------------------------------------------------[ Experiment ]--
(run_ex) #                  -- ProcFedure to run the experiment described by the steps below. 
    # This is a simple skeleton to run your experiment in a normed order.
    # Normaly, there is nothing to change.
    echo -e "Experiment TAG: #$ex_tag"
    echo -e "$bench_tag Running defined experiment... "
    
    # Checks if a query is given at runtime and passed as an argument to this file
    queryLikeToRun=$2
    if [ -z "$queryLikeToRun" ]; then
        echo "Error, you called the experiment without defining which experiment you would like to executes."; \
        exit 1
    fi
    echo "Query-Mapper has detected: $queryLikeToRun"

    ./$0 cus_build
    util_sleep 10
    ./$0 cus_deploy
    util_sleep 60
    ./$0 cus_prepare
    util_sleep 10

    start_time=$(exutils_UTC_TimestampInNanos)
    ./$0 cus_workload $queryLikeToRun
    sleep 30
    end_time=$(exutils_UTC_TimestampInNanos)
    util_sleep 10

    pathToCollectDir=$(util_relResultDirPath $home_framework)_${ex_tag}_${queryLikeToRun} # formate: date_tag_queryNumber
    exutils_auto_collectMeasurementsToZip $start_time $end_time $pathToCollectDir ${ex_tag}_${queryLikeToRun}
    ./$0 cus_collect $start_time $end_time $pathToCollectDir $ex_tag

    util_sleep 10
    ./$0 cus_clean
    ./$0 cus_finish
;;
#----------------------------------------------------------------------------[ Experiment-Functions ]--
(cus_build) #               -- Procedure to build your kube infrastructure (docker). via custom script.
    echo -e "$bench_tag System is building the infrastructure of the experiment.     | $RR cus_build $NC"
    
    eval $(minikube docker-env)
    cd $home_dockerfile
    # docker build -t jwgumcz/thadoop .
;;
(cus_deploy) #              -- Procedure to deploy your benchmark on kubernetes.     via custom script.
    echo -e "$bench_tag Deploying the infrastructure of the experiment.     | $RR cus_deploy $NC"
    
    util_sleep 30
    nameOfHadoopCluster='thadoop'
    cd $home_charts
    helm delete  --purge $nameOfHadoopCluster || echo "Nothing to clean. The requested Enviroment will start now."
    echo "System-enviroment is booting now"
    helm install --wait --timeout 600 --name $nameOfHadoopCluster hadoop \
    --set spark_master.replicas=1,spark_worker.replicas=1 || \
    ( 
        echo "Something went wrong. The system will stop the execution for some time. After that the system will retry the procedure for a second time" &&\
        helm del --purge $nameOfHadoopCluster;
        util_sleep 60;
        helm install --wait --timeout 600 --name $nameOfHadoopCluster hadoop \
        --set spark_master.replicas=1,spark_worker.replicas=1 
    )

    echo -e  "${bench_tag} Enviroment named as < $nameOfHadoopCluster > is starting now ..."
;;
(cus_prepare) #             -- Procedure to prepare a running enviroment.            via custom script.
    echo -e "$bench_tag Preparing the infrastructure for the workloads.     | $RR cus_prepare $NC"
    
    kubectl cp $home_benchmark $loc_des_container:/
    kubectl exec -ti $loc_des_container -- bash -c      "   cd $container_home__bench                   && \
                                                            echo Copying benchmark-data to HDFS         && \
    														bash ./schema/CopyData2HDFS.sh              && \
                                                            echo Copying benchmark-data was successfull"

    kubectl exec -ti $loc_des_container -- bash -c      "cd $container_home__bench                   && \
                                                         echo Creating BigBenchV2-DB                 && \
    spark-sql --master  spark://thadoop-hadoop-spark-master:7077 -f $container_home__bench/schema/HiveCreateSchema.sql" 
;;
(cus_workload) #            -- Procedure to run the experiment related workload.     via custom script.
    query_number=$2
    echo -e "$bench_tag Executing the workload of the experiment.           | $RR cus_workload $NC"
    query_to_exec="$container_home__bench/queries/$query_number.hql"
    
    echo -e "$bench_tag Running  query $query_to_exec.                                            "
    kubectl exec -ti $loc_des_container -- bash -c      "cd $container_home__bench  && \
    spark-sql --master  spark://thadoop-hadoop-spark-master:7077 -f $query_to_exec"   
;;
(cus_collect) #             -- Procedure to collect the results of the experiment.   via custom script.
    echo -e "$bench_tag Downloading the results of the experiment.          | $RR cus_collect $NC"
    # Variables which are available for you at runtime. 
    experiment_start=$2
    experiment_end=$3
    exportDirectory=$4
    exportExperimentID=$5

#   --------------------------
    kubectl exec -ti $loc_des_container -- bash -c      "   cd $container_home__bench                   && \
                                                            mkdir 'results'                             && \
                                                            hadoop fs -get '/' './results'              && \
                                                            echo 'Hadoop export successfull.'
                                                        "
    kubectl cp $loc_des_container:$container_home__bench/results $exportDirectory
    location=$(readlink -f $exportDirectory)
    echo -e "$bench_tag Download complete. Your data are located under <${LB}$location${NC}>"
;;
(cus_clean) #               -- Procedure to clean up the enviroment if needed        via custom script.
    echo -e "$bench_tag Cleaning the infrastructure.                        | $RR cus_clean $NC"
#    //TODO Your code comes here 
;;
(cus_finish) #              -- Procedure to signal that the experiment has finished. via custom script.   
    echo -e "$bench_tag Experiment finished.                                | $RR cus_finish $NC"
#    //TODO Your code comes here 
;;
#--------------------------------------------------------------------------------------------[ Help ]--
(--help|*) #                -- Prints the help and usage message
    exutils_dynmic_helpByCodeParse
;;
esac     
done
