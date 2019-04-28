#!/usr/bin/env bash

LB='\033[1;34m'
RR='\033[1;31m'
NC='\033[0m' # No Color

# dep-locations
exutils="../../utils/exutils.sh"

# imports
source $exutils


bench_tag=${LB}[A-Bench]${NC}
ex_tag="template_ex"

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
    ./$0 cus_build
    ./$0 cus_deploy
    ./$0 cus_prepare

    start_time=$(exutils_UTC_TimestampInNanos)
    ./$0 cus_workload
    end_time=$(exutils_UTC_TimestampInNanos)
    exutils_auto_collectMeasurementsToZip $start_time $end_time ~ $ex_tag
    
    ./$0 cus_collect $start_time $end_time ~ $ex_tag
    ./$0 cus_clean
    ./$0 cus_finish
;;
#----------------------------------------------------------------------------[ Experiment-Functions ]--
(cus_build) #               -- Procedure to build your kube infrastructure (docker). via custom script.
    echo -e "$bench_tag Deploying the infrastructure of the experiment.     | $RR cus_build $NC"
#    //TODO Your code comes here 
;;
(cus_deploy) #              -- Procedure to deploy your benchmark on kubernetes.     via custom script.
    echo -e "$bench_tag Deploying the infrastructure of the experiment.     | $RR cus_deploy $NC"
#    //TODO Your code comes here 
;;
(cus_prepare) #             -- Procedure to prepare a running enviroment.            via custom script.
    echo -e "$bench_tag Preparing the infrastructure for the workloads.     | $RR cus_prepare"
#    //TODO Your code comes here 
;;
(cus_workload) #            -- Procedure to run the experiment related workload.     via custom script.
    echo -e "$bench_tag Executing the workload of the experiment.           | $RR cus_workload $NC"
    
#   ----------------------------------------------
#    //TODO Your code comes here 
#   ----------------------------------------------    
;;
(cus_collect) #             -- Procedure to collect the results of the experiment.   via custom script.
    echo -e "$bench_tag Downloading the results of the experiment.          | $RR cus_collect $NC"
    # Variables which are available for you at runtime. 
    experiment_start=$2
    experiment_end=$3
    exportDirectory=$4
    exportExperimentID=$5

#    //TODO Your code comes here 
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
    echo -e  "${bench} USAGE $var <case>"
    echo -e 
    echo -e  The following cases are available:
    echo -e 
    # An intelligent means of printing out all cases available and their
 	# section. WARNING: -E is not portable!
    grep -E '^(#--+\[ |\([a-z_\|\*-]+\))' < "$0" | cut -c 2- | \
    sed -E -e 's/--+\[ (.+) \]--/\1/g' -e 's/(.*)\)$/ * \1/g' \
    -e 's/(.*)\) # (.*)/ * \1 \2/g'
;;
esac     
done