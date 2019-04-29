#!/usr/bin/env bash

LB='\033[1;34m'
RR='\033[1;31m'
NC='\033[0m' # No Color

# dep-locations
exutils="../../utils/exutils.sh"

# imports
source $exutils

container_home__bench='/bigbenchv2'
loc_des_container="thadoop-hadoop-bench-driver-0"

bench_tag=${LB}[A-Bench]${NC}

if [[ $# -eq 0 ]] ; then
    ./$0 --help
    exit 0
fi

for var in "$1"
do
case  $var  in

#--------------------------------------------------------------------------------------[ Experiment ]--
(run_ex) #                  -- ProcFedure to run the experiment described by the steps below. 
    echo -e "Experiment TAG: #$ex_tag"
    echo -e "$bench_tag Running defined experiment... "
    callerExportDirectory=${2:-"./"}
    exTag=${3:-unkown3}
    exRunID=${4:-unkown4}
    exportLocationOfExperiment=$callerExportDirectory/$exRunID
    echo -e "$bench_tag --------------------------------------------------- [mSRE -$exRunID- S] "
    
    echo  $exportLocationOfExperiment
    ./$0 mSRE_prepare

    start_time=$(exutils_UTC_TimestampInNanos)
    ./$0 mSRE_workload 
    end_time=$(exutils_UTC_TimestampInNanos)
    echo "waiting 60 s until all data are available in the database" && sleep 60
    exutils_auto_collectMeasurementsToZip $start_time $end_time $exportLocationOfExperiment $exTag
    
    ./$0 mSRE_collect $start_time $end_time $exportLocationOfExperiment $exTag
    ./$0 mSRE_clean
    echo -e "$bench_tag --------------------------------------------------- [mSRE -$exRunID- E] "

;;
#----------------------------------------------------------------------------[ Experiment-Functions ]--
(mSRE_prepare) #             -- Procedure to prepare a running enviroment.            via custom script.
    echo -e "$bench_tag Preparing the infrastructure for the workloads.     | $RR mSRE_prepare"
#    //TODO Your code comes here 
;;
(mSRE_workload) #            -- Procedure to run the experiment related workload.     via custom script.
    echo -e "$bench_tag Executing the workload of the experiment.           | $RR mSRE_workload $NC"
    
    kubectl exec -ti $loc_des_container -- bash -c      "   cd $container_home__bench                    && \
                                                            hive -f queries/q29.hql 
                                                        "   

;;
(mSRE_collect) #             -- Procedure to collect the results of the experiment.   via custom script.
    echo -e "$bench_tag Downloading the results of the experiment.          | $RR mSRE_collect $NC"
    # Variables which are available for you at runtime. 
    experiment_start=$2
    experiment_end=$3
    exportDirectory=$4
    exportExperimentID=$5

    kubectl exec -ti $loc_des_container -- bash -c      "   cd $container_home__bench                   && \
                                                            mkdir 'results'                             && \
                                                            hadoop fs -get '/' './results'              && \
                                                            echo 'Hadoop export successfull.'
                                                        "
    kubectl cp $loc_des_container:$container_home__bench/results $exportDirectory
    location=$(readlink -f $exportDirectory)
    echo -e "$bench_tag Download complete. Your data are located under <${LB}$location${NC}>"
;;
(mSRE_clean) #               -- Procedure to clean up the enviroment if needed        via custom script.
    echo -e "$bench_tag Cleaning the infrastructure.                        | $RR mSRE_clean $NC"
#    //TODO Your code comes here 
;;
 
#--------------------------------------------------------------------------------------------[ Help ]--
(--help|*) #                -- Prints the help and usage message
  exutils_dynmic_helpByCodeParse
;;
esac     
done