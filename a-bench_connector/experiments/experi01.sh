
#!/usr/bin/env bash
LB='\033[1;34m'
RR='\033[1;31m'
NC='\033[0m' # No Color
bench_tag=${LB}[A-Bench]${NC}


ex_tag="experiment#01"

loc_des_container="thadoop-hadoop-bench-driver-0"
#loc_des_container="thadoop-hadoop-hdfs-nn-0"

# all functions calls are indicated by prefix <util_xxx>
# Provides some additional and nice features.
source ../../../../dir_bench/lib_bench/shell/util.sh

home_benchmark='../../..'
home_framework='../../../..'
home_dockerfile='../images/hive'
home_charts='../charts'
home_container_bench='/bigbenchv2'

if [[ $# -eq 0 ]] ; then
    ./$0 --help
    exit 0
fi

for var in "$@"
do
case  $var  in

#--------------------------------------------------------------------------------------[ Experiment ]--
(run) #                  -- ProcFedure to run the experiment described by the steps below. 
    echo -e "Experiment TAG: #$ex_tag"
    echo -e "$bench_tag Running defined experiment... "
    
    ./$0 cus_build
    util_sleep 10
    ./$0 cus_deploy
    util_sleep 60
    
    ./$0 cus_prepare
    util_sleep 10
    
    ./$0 cus_workload
    util_sleep 10
    
    ./$0 cus_collect
    util_sleep 10
    
    ./$0 cus_clean
    
    ./$0 cus_finish
;;
#----------------------------------------------------------------------------[ Experiment-Functions ]--
(cus_build) #              -- Procedure to build your kube infrastructure (docker).  via custom script.
    echo -e "$bench_tag System is building the infrastructure of the experiment.     | $RR cus_build $NC"
    
    eval $(minikube docker-env)
    cd $home_dockerfile
    docker build -t thadoop .
;;
(cus_deploy) #              -- Procedure to deploy your benchmark on kubernetes.     via custom script.
    echo -e "$bench_tag Deploying the infrastructure of the experiment.     | $RR cus_deploy $NC"
    
    helm delete --purge sql-mysql
    util_sleep 30
    helm install --name sql-mysql \
    --set mysqlRootPassword=a,mysqlUser=hive,mysqlPassword=phive,mysqlDatabase=metastore_db \
    stable/mysql

    nameOfHadoopCluster='thadoop'
    cd $home_charts
    helm delete     --purge $nameOfHadoopCluster
    helm install    --name  $nameOfHadoopCluster hadoop
    echo -e  "${bench_tag} hadoop cluster started and named as < $nameOfHadoopCluster > ..."
    util_sleep 30
;;
(cus_prepare) #             -- Procedure to prepare a running enviroment.            via custom script.
    echo -e "$bench_tag Preparing the infrastructure for the workloads.     | $RR cus_prepare $NC"
    
    kubectl cp $home_benchmark $loc_des_container:/
    kubectl exec -ti $loc_des_container -- bash -c      "   cd $home_container_bench                    && \
                                                            echo Copying benchmark-data to HDFS         && \
    														bash ./schema/CopyData2HDFS.sh              && \
                                                            echo Copying benchmark-data was successfull && \
                                                            echo Starting to initialize db-schema       && \
    														schematool -dbType mysql -initSchema 
                                                        "  
    kubectl exec -ti $loc_des_container -- bash -c      "   cd $home_container_bench                    && \
                                                            echo Creating BigBenchV2-DB                 && \
                                                            hive -f schema/HiveCreateSchema.sql 
                                                        "
;;
(cus_workload) #            -- Procedure to run the experiment related workload.     via custom script.
    echo -e "$bench_tag Executing the workload of the experiment.           | $RR cus_workload $NC"
    
    kubectl exec -ti $loc_des_container -- bash -c      "   cd $home_container_bench                    && \
                                                            hive -f queries/q29.hql 
                                                        "
;;
(cus_collect) #             -- Procedure to collect the results of the experiment.   via custom script.
    echo -e "$bench_tag Downloading the results of the experiment.          | $RR cus_collect $NC"
    
    kubectl exec -ti $loc_des_container -- bash -c      "   cd $home_container_bench                    && \
                                                            mkdir 'results'                             && \
                                                            hadoop fs -get '/' './results'              && \
                                                            echo 'Hadoop export successfull.'
                                                        "
    # defines the result-dir name
    pathToCollectDir=$(util_relResultDirPath $home_framework)
    kubectl cp $loc_des_container:$home_container_bench/results $pathToCollectDir
    cd $pathToCollectDir
    location=$(pwd)
    echo -e "$bench_tag Download complete. The data can be found at <${LB}$location${NC}>"
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
(deba)
    kubectl exec -it $loc_des_container bash
;;
(--help|*) #                -- Prints the help and usage message
    # Greetings to Ma_Sys.ma -- https://github.com/m7a --
    # The code-snipped was implemented by him.
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