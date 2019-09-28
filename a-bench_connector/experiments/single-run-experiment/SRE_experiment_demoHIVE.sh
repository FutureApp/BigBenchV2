#!/usr/bin/env bash

LB='\033[1;34m'
RR='\033[1;31m'
NC='\033[0m' # No Color

# dep-locations
exutils="../../utils/exutils.sh"

# imports
source $exutils

bench_tag=${LB}[A-Bench]${NC}
ex_tag="experiment#01"

loc_des_container="thadoop-hadoop-bench-driver-0"

# all functions calls are indicated by prefix <util_xxx>
# Provides some additional and nice features.
source ../../../../../dir_bench/lib_bench/shell/util.sh

# HOME
home_benchmark='../../../..'
home_framework='../../../../..'
home_charts='../../charts'
home_dockerfile='../../images/hive'

container_home__bench='/bigbenchv2'
if [[ $# -eq 0 ]] ; then
    ./$0 --help
    exit 0
fi

for var in "$1"
do
case  $var  in
#---------------------------------------------------------------------------------[ Experiment ]--
(run_ex) #                  -- ProcFedure to run the experiment described by the steps below. 
    echo -e "Experiment TAG: #$ex_tag"
    echo -e "$bench_tag Running defined experiment... "
    ./$0 cus_build
    util_sleep 10
    ./$0 cus_deploy
    util_sleep 60
    ./$0 cus_prepare
    util_sleep 10

    start_time=$(exutils_UTC_TimestampInNanos)
    ./$0 cus_workload
    sleep 30
    end_time=$(exutils_UTC_TimestampInNanos)
    util_sleep 10

    pathToCollectDir=$(util_relResultDirPath $home_framework)
    exutils_auto_collectMeasurementsToZip $start_time $end_time $pathToCollectDir $ex_tag
    ./$0 cus_collect $start_time $end_time $pathToCollectDir $ex_tag

    util_sleep 10
    ./$0 cus_clean
    ./$0 cus_finish
;;
#-----------------------------------------------------------------------[ Experiment-Functions ]--
(cus_build) #          -- Procedure to build your kube infrastructure (docker). via custom script.
    echo -e \
    "$bench_tag System is building the infrastructure of the experiment.| $RR cus_build $NC"
    
    eval $(minikube docker-env)
    cd $home_dockerfile
    # docker build -t thadoop .
    docker pull jwgumcz/thadoop:latest
;;
(cus_deploy) #         -- Procedure to deploy your benchmark on kubernetes.     via custom script.
    echo -e "$bench_tag Deploying the infrastructure of the experiment.     | $RR cus_deploy $NC"
    
    nameOfHadoopCluster='thadoop'
    cd $home_charts
    helm delete     --purge $nameOfHadoopCluster && util_sleep 30
    helm install --wait --timeout 600 --name  $nameOfHadoopCluster hadoop \
    --set spark_master.replicas=0,spark_worker.replicas=0 || \
    (   echo -e "$bench_tag Something went wrong. System will make a final attempt." &&\
        helm delete     --purge $nameOfHadoopCluster
        util_sleep 120;
        helm install --wait --timeout 600 --name  $nameOfHadoopCluster hadoop \
        --set spark_master.replicas=0,spark_worker.replicas=0 
    ) || (echo "Problem is persiting. Execution will stop now" && exit 1)
    echo -e  "${bench_tag} hadoop cluster started and named as < $nameOfHadoopCluster > ..."
    echo  -e "${bench_tag} Waiting for stable system."
    util_sleep 30
;;
(cus_prepare) #        -- Procedure to prepare a running enviroment.            via custom script.
    echo -e "$bench_tag Preparing the infrastructure for the workloads.     | $RR cus_prepare $NC"
    
    kubectl cp $home_benchmark $loc_des_container:/
    kubectl exec -ti $loc_des_container -- bash -c      
    "   cd $container_home__bench                   && \
        echo 'Copying benchmark-data to HDFS'       && \
        bash ./schema/CopyData2HDFS.sh              && \
        echo Copying benchmark-data was successfull 
    "  
    kubectl exec -ti $loc_des_container -- bash -c      
    "   cd $container_home__bench                   && \
        echo 'Creating BigBenchV2-DB'               && \
        hive -f ./schema/HiveCreateSchema.sql 
    "
;;
(cus_workload) #       -- Procedure to run the experiment related workload.     via custom script.
    echo -e "$bench_tag Executing the workload of the experiment.          | $RR cus_workload $NC"
    
    kubectl exec -ti $loc_des_container -- bash -c      
    "   cd $container_home__bench                    && \
        hive -f ./queries/q16.hql 
    "   
;;
(cus_collect) #        -- Procedure to collect the results of the experiment.   via custom script.
    echo -e "$bench_tag Downloading the results of the experiment.          | $RR cus_collect $NC"
    # Variables which are available for you at runtime. 
    experiment_start=$2
    experiment_end=$3
    exportDirectory=$4
    exportExperimentID=$5

#   --------------------------
    kubectl exec -ti $loc_des_container -- bash -c      
    "   cd $container_home__bench                   && \
        mkdir 'results'                             && \
        hadoop fs -get '/' './results'              && \
        echo 'Hadoop export successfull.'
    "
    kubectl cp $loc_des_container:$container_home__bench/results $exportDirectory
    location=$(readlink -f $exportDirectory)
    echo -e "$bench_tag Download complete. Your data are located under <${LB}$location${NC}>"
;;
(cus_clean) #          -- Procedure to clean up the enviroment if needed        via custom script.
    echo -e "$bench_tag Cleaning the infrastructure.                        | $RR cus_clean $NC"
#    //TODO Your code comes here 
;;
(cus_finish) #         -- Procedure to signal that the experiment has finished. via custom script.   
    echo -e "$bench_tag Experiment finished.                                | $RR cus_finish $NC"
#    //TODO Your code comes here 
;;
#---------------------------------------------------------------------------------------[ Help ]--
(--help|*) #                -- Prints the help and usage message
    exutils_dynmic_helpByCodeParse
;;
esac     
done