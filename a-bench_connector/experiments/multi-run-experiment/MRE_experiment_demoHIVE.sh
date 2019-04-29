#!/usr/bin/env bash

LB='\033[1;34m'
RR='\033[1;31m'
NC='\033[0m' # No Color

# dep-locations
exutils="../../utils/exutils.sh"

# imports
source $exutils

# HOME
home_benchmark='../../../..'
home_framework='../../../../..'
home_charts='../../charts'
home_dockerfile='../../images/hive'


container_home__bench='/bigbenchv2'
loc_des_container="thadoop-hadoop-bench-driver-0"

bench_tag=${LB}[A-Bench]${NC}
ex_tag="MRE_experiment_demoHIVE"

if [[ $# -eq 0 ]] ; then
    ./$0 --help
    exit 0
fi

for var in "$1"
do
case  $var  in

#--------------------------------------------------------------------------------------[ Experiment ]--
(run_ex) #                  -- Procedure to run the experiment described by the steps below. 
    mSRE_iterations=${2:-1}
    echo -e "Experiment TAG: #$ex_tag"
    echo -e "$bench_tag Running defined experiment... "
    ./$0 MRE_build
    ./$0 MRE_deploy
    ./$0 MRE_prepare
    exutils_sleep 60

    home_framework=$(readlink -f "../../../../..")
    pathToCollectDir=$(exutils_relResultDirPath $home_framework)
    echo $pathToCollectDir
    start_time=$(exutils_UTC_TimestampInNanos)
    ./$0 MRE_run $pathToCollectDir $mSRE_iterations
    end_time=$(exutils_UTC_TimestampInNanos)
    exutils_auto_collectMeasurementsToZip $start_time $end_time $pathToCollectDir $ex_tag
    
    ./$0 MRE_collect $start_time $end_time ~ $ex_tag
    ./$0 MRE_clean
    ./$0 MRE_finish
;;
#----------------------------------------------------------------------------[ Experiment-Functions ]--
(MRE_build) #               -- Procedure to build your kube infrastructure (docker). via custom script.
    echo -e "$bench_tag Deploying the infrastructure of the experiment.     | $RR MRE_build $NC"

    eval $(minikube docker-env)
    cd $home_dockerfile
    docker build -t thadoop .
;;
(MRE_deploy) #              -- Procedure to deploy your benchmark on kubernetes.     via custom script.
    echo -e "$bench_tag Deploying the infrastructure of the experiment.     | $RR MRE_deploy $NC"
    
    helm delete --purge sql-mysql
    exutils_sleep 30
    helm install --name sql-mysql \
    --set mysqlRootPassword=a,mysqlUser=hive,mysqlPassword=phive,mysqlDatabase=metastore_db \
    stable/mysql

    nameOfHadoopCluster='thadoop'
    cd $home_charts
    helm delete     --purge $nameOfHadoopCluster
    helm install    --name  $nameOfHadoopCluster hadoop
    echo -e  "${bench_tag} hadoop cluster started and named as < $nameOfHadoopCluster > ..."
    exutils_sleep 30
;;
(MRE_prepare) #             -- Procedure to prepare a running enviroment.            via custom script.
    echo -e "$bench_tag Preparing the infrastructure for the workloads.     | $RR MRE_prepare $NC"
    
    kubectl cp $home_benchmark $loc_des_container:/
    kubectl exec -ti $loc_des_container -- bash -c      "   cd $container_home__bench                    && \
                                                            echo Copying benchmark-data to HDFS         && \
    														bash ./schema/CopyData2HDFS.sh              && \
                                                            echo Copying benchmark-data was successfull && \
                                                            echo Starting to initialize db-schema       && \
    														schematool -dbType mysql -initSchema 
                                                        "  
    kubectl exec -ti $loc_des_container -- bash -c      "   cd $container_home__bench                    && \
                                                            echo Creating BigBenchV2-DB                 && \
                                                            hive -f schema/HiveCreateSchema.sql 
                                                        " 
;;
(MRE_run) #                 -- Procedure to run the experiment related workload.     via custom script.
    echo -e "$bench_tag Executing the workload of the experiment.           | $RR call_mSRE $NC"
    pathDataToCollectTo=$2
    numberOfIterations=$3
    counter=1
    while [ $counter -le $numberOfIterations ]
        do
        echo "Calling mSRE ($counter/$numberOfIterations)"
        bash ./mSRE_experiment_demoHIVE.sh run_ex $pathDataToCollectTo $ex_tag-$counter $counter
        ((counter++))
        done
  
;;
(MRE_collect) #             -- Procedure to collect the results of the experiment.   via custom script.
    echo -e "$bench_tag Downloading the results of the experiment.          | $RR MRE_collect $NC"
    # Variables which are available for you at runtime. 
    experiment_start=$2
    experiment_end=$3
    exportDirectory=$4
    exportExperimentID=$5

    echo "There's nothing at all to collect. We are only interested in the automatically collected measurements." 
;;
(MRE_clean) #               -- Procedure to clean up the enviroment if needed        via custom script.
    echo -e "$bench_tag Cleaning the infrastructure.                        | $RR MRE_clean $NC"
    echo "There's nothing to clean up"
;;
(MRE_finish) #              -- Procedure to signal that the experiment has finished. via custom script.   
    echo -e "$bench_tag Experiment finished.                                | $RR MRE_finish $NC"
;;
#--------------------------------------------------------------------------------------------[ Help ]--
(--help|*) #                -- Prints the help and usage message
    exutils_dynmic_helpByCodeParse
;;
esac     
done