#!/usr/bin/env bash

function exutils_UTC_TimestampInNanos {
    echo "$(date -u +%s%N)"
}

function exutils_collectMeasurements_FromT_ToT_csv_zip {
    start_time=$1
    end_time=$2
    exportFile=$3

    urlToCall=$(exutils_createCollectingURLForExperiment $start_time $end_time)
    echo "calling url <$urlToCall>"
    curl "$urlToCall" --output $exportFile
    echo "Datacollection finished. Export located at <$exportFile>"
}

function exutils_createCollectingURLForExperiment {
    # ------- Input
    fromT=$1
    toT=$2
    # ------- Self-creating
    service_ip_port=$(exutils_minikube_getDataServiceNamePort)

    result_URL="http://$service_ip_port/csv-zip?host=monitoring-influxdb&port=8086&dbname=k8s&filename=experi01&fromT=$fromT&toT=$toT"
    echo $result_URL
}

# Gathers the endpoint-informations (name:port) which helps to access the data 
# persists in the influx-db
#
# Returns   : Returns the IP:Port of  the service as a string if the service exists.
#             Otherwise empty.
function exutils_minikube_getDataServiceNamePort {
    serviceToLookFor=influxdb-client && \
    nodeIP="$(minikube ip)"
    servicePort="$(kubectl get svc --all-namespaces | grep $serviceToLookFor |\
                awk '{print $6}' | awk -F ':|/' '{print $2}')"
    echo "$nodeIP:$servicePort"
}

function exutils_auto_collectMeasurementsToZip {
    experiment_start=$1
    experiment_end=$2
    exportDirectory=$3
    exportFileName=$4
    mkdir -p $exportDirectory
    ab_exportDirectory=$(readlink -f $exportDirectory)
    echo "stop"
    echo $experiment_start $experiment_end "$ab_exportDirectory/$exportFileName.zip"
    exutils_collectMeasurements_FromT_ToT_csv_zip $experiment_start $experiment_end "$ab_exportDirectory/$exportFileName.zip"
}

# Defines a unique time-based name for a result-directory, creates the directory if needed.
# The location is relative to the provied prefix. The function will return the absolut path
# via echoing.
# E.g:      /usr/home/test   // < Input
# Return:   /usr/home/test/results/20190101145559

# Argument 1: $1 -- Prefix - Path for the directory
# Return    :    -- Path to  directory.
function exutils_relResultDirPath()
{   
    home_framework=$1
    current_time=$(date "+%Y%m%d_%H_%M_%S")
    dir_name=$current_time
    pathToCollectDir=$home_framework/results/$dir_name
    
    # Return
    echo $pathToCollectDir
}

function exutils_dynmic_helpByCodeParse {
    # Greetings to Ma_Sys.ma -- https://github.com/m7a --
    # The original code-snipped bellow and the switch-case file structure was implemented by him .  
    echo -e  "${bench} USAGE $var <case>"
    echo -e 
    echo -e  The following cases are available:
    echo -e 
    # An intelligent means of printing out all cases available and their
 	# section. WARNING: -E is not portable!
    grep -E '^(#--+\[ |\([a-zA-Z_\|\*-]+\))' < "$0" | cut -c 2- | \
    sed -E -e 's/--+\[ (.+) \]--/\1/g' -e 's/(.*)\)$/ * \1/g' \
    -e 's/(.*)\) # (.*)/ * \1 \2/g'
}

# Stops the exection for a specific sleep-time
#
# Argument 1: $1 -- Time to sleep in seconds
function exutils_sleep()
{   
    # scr:  https://stackoverflow.com/questions/12498304/using-bash-to-display-a-progress-working-indicator
    # user: William Pursell
    echo "Execution will pause for $1 seconds."
    sleep $1 &
    pid=$! # Process Id of the previous running command
    spin='-\|/'

    i=0
    counter=$(($1-1))   
    lCounter=0
    mod=0
    while kill -0 $pid 2>/dev/null
    do
      i=$(( (i+1) %4 ))
      printf "\r${spin:$i:1}    | $counter [s]"
      sleep .1
      lCounter=$((lCounter+1))
      mod=$((lCounter%10))
        if [ $mod -eq 0 ]
            then
            lCounter=0
            counter=$((counter-1))
        fi
    done
    echo ''
}