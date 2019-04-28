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
path_to_mSRE_file="./mSRE_template/mSRE-definition-template.sh"

if [[ $# -eq 0 ]] ; then
    ./$0 --help
    exit 0
fi

for var in "$1"
do
case  $var  in

#--------------------------------------------------------------------------------------[ Experiment ]--
(run_ex) #                  -- ProcFedure to run the experiment described by the steps below. 
    mSRE_iterations=${2:-1}
    echo -e "Experiment TAG: #$ex_tag"
    echo -e "$bench_tag Running defined experiment... "
    ./$0 MRE_build
    ./$0 MRE_deploy
    ./$0 MRE_prepare


    home_framework=$(readlink -f "../../../..")
    pathToCollectDir=$(exutils_relResultDirPath $home_framework)
    echo $pathToCollectDir
    start_time=$(exutils_UTC_TimestampInNanos)
    ./$0 call_mSRE $pathToCollectDir $mSRE_iterations
    end_time=$(exutils_UTC_TimestampInNanos)
    exutils_auto_collectMeasurementsToZip $start_time $end_time $pathToCollectDir $ex_tag
    
    ./$0 MRE_collect $start_time $end_time ~ $ex_tag
    ./$0 MRE_clean
    ./$0 MRE_finish
;;
#----------------------------------------------------------------------------[ Experiment-Functions ]--
(MRE_build) #               -- Procedure to build your kube infrastructure (docker). via custom script.
    echo -e "$bench_tag Deploying the infrastructure of the experiment.     | $RR MRE_build $NC"
#    //TODO Your code comes here 
;;
(MRE_deploy) #              -- Procedure to deploy your benchmark on kubernetes.     via custom script.
    echo -e "$bench_tag Deploying the infrastructure of the experiment.     | $RR MRE_deploy $NC"
#    //TODO Your code comes here 
;;
(MRE_prepare) #             -- Procedure to prepare a running enviroment.            via custom script.
    echo -e "$bench_tag Preparing the infrastructure for the workloads.     | $RR MRE_prepare"
#    //TODO Your code comes here 
;;
(call_mSRE) #            -- Procedure to run the experiment related workload.     via custom script.
    echo -e "$bench_tag Executing the workload of the experiment.           | $RR call_mSRE $NC"
    pathDataToCollectTo=$2
    numberOfIterations=$3
    counter=1
    while [ $counter -le $numberOfIterations ]
        do
        echo "Calling mSRE ($counter/$numberOfIterations)"
        bash ./mSRE-definition-template.sh run_ex $pathDataToCollectTo $ex_tag-$counter $counter
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

#    //TODO Your code comes here 
;;
(MRE_clean) #               -- Procedure to clean up the enviroment if needed        via custom script.
    echo -e "$bench_tag Cleaning the infrastructure.                        | $RR MRE_clean $NC"
#    //TODO Your code comes here 
;;
(MRE_finish) #              -- Procedure to signal that the experiment has finished. via custom script.   
    echo -e "$bench_tag Experiment finished.                                | $RR MRE_finish $NC"
#    //TODO Your code comes here 
;;
#--------------------------------------------------------------------------------------------[ Help ]--
(--help|*) #                -- Prints the help and usage message
    # Greetings to Ma_Sys.ma -- https://github.com/m7a --
#   w The code-snipped was implemented by him.  
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