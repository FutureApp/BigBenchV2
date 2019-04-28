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

    echo $experiment_start $experiment_end "$ab_exportDirectory/$exportFileName.zip"
    exutils_collectMeasurements_FromT_ToT_csv_zip $experiment_start $experiment_end "$ab_exportDirectory/$exportFileName.zip"
}