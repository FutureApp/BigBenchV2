FROM java:8-jre
# ----------------------------------------------------------------- [ config ]--
# Add native libs
ARG HADOOP_VERSION=2.7.7
ARG HIVE_VERSION=1.2.1
ARG SPARK_VERSION=2.3.4

ENV \
  HADOOP_PREFIX=/usr/local/hadoop \
  HADOOP_COMMON_HOME=/usr/local/hadoop \
  HADOOP_HDFS_HOME=/usr/local/hadoop \
  HADOOP_MAPRED_HOME=/usr/local/hadoop \
  HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop \
  HADOOP_HOME=/usr/local/hadoop \
  HADOOP_USER_CLASSPATH_FIRST=true \
  HADOOP_OPTS="-Djava.library.path=/usr/local/hadoop/lib" \
  HADOOP_YARN_HOME=/usr/local/hadoop \
  YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop \
  HIVE_HOME=/usr/local/hadoop/hive  \
  SPARK_HOME=/opt/spark \
  PATH="${PATH}:/usr/local/hadoop/bin:\
/usr/local/hadoop/hive/bin:\
/opt/spark/bin"

# ----------------------------------------------------------------- [install] --
# Hadoop
RUN \
  cd ${HADOOP_HOME}/.. && \
  var_down_hadoop_url="https://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" &&\
  echo "Downloading hadoop via: ${var_down_hadoop_url}" &&\
  wget -q ${var_down_hadoop_url} &&\
  mkdir hadoop && \
  pwd && \
  tar -xf hadoop*.tar.gz -C hadoop --strip-components=1 && \
  echo "Version $(ls | grep hadoop- | sed -e 's/[^0-9 . ]//g')" >> ./hadoop/version.conf && \
  chmod +x ./hadoop/bin/hadoop && \
  rm -rf hadoop*.* &&\
  rm -f ${HADOOP_PREFIX}/logs/* && \
  echo "Installation of hadoop completed"

# HIVE
RUN \
  mkdir -p ${HIVE_HOME} && cd ${HIVE_HOME}/.. &&\
  var_down_hive_url="https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz"&&\
  echo "Downloading hive via: ${var_down_hive_url}" &&\
  wget -q ${var_down_hive_url} &&\
  tar -xf apache-hive*.tar.gz -C hive --strip-components=1 && \
  rm apache-hive-*.tar.gz &&\
  echo "Installation of hive completed"

# Apache Spark
# Based on: https://www.linode.com/docs/databases/hadoop/install-configure-run-spark-on-top-of-hadoop-yarn-cluster/
RUN \ 
  mkdir -p ${SPARK_HOME} &&\
  cd ${SPARK_HOME}/.. &&\
  var_spark_url="https://www-eu.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz";\
  echo "Downloading apache spark via: ${var_spark_url}" &&\
  wget -q ${var_spark_url} &&\
  tar zxvf spark*.tgz -C spark --strip-components=1 &&\
  rm spark-*.tgz &&\
  echo "Installation of the spark completed"

# the jessie specific files were moved to the archive backend
# In order to run apt-get update we have to use the following workaround:
# Solution based on the git hubposts under (state 4/28/2019;14.10):
# https://unix.stackexchange.com/questions/508724/failed-to-fetch-jessie-backports-repository
RUN \
  echo "deb [check-valid-until=no] http://cdn-fastly.deb.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie.list && \
  echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list && \
  sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list && \
  apt-get -o Acquire::Check-Valid-Until=false update && \
  apt-get install libmysql-java -y  && \
  ln -s /usr/share/java/mysql-connector-java.jar /usr/local/hadoop/hive/lib/mysql-connector-java.jar && \
  echo "Installation of the mysql-connector-java.jar completed"

# Python & Utils
RUN \
    apt-get install -y python python-pip git dnsutils nano && \
    echo "Installation of pyhton-env and utils completed"

RUN \
  cd / &&\
  git clone "https://github.com/FutureApp/bigbenchv2.git" && \
  echo "Installation of BigBenchV2 - Master - Branch completed!"
# ----------------------------------------------------------- [copy & expose] --
  


ADD content/hive-env.sh /usr/local/hadoop/hive/conf/hive-env.sh
ADD content/hive-site.xml /usr/local/hadoop/hive/conf/hive-site.xml

COPY content/spark-defaults.conf ${SPARK_HOME}/conf
WORKDIR $HADOOP_PREFIX

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
# Spark Master
EXPOSE 9005 7077 6066 
# Spark Worker
EXPOSE 9006 9010
#Other ports
EXPOSE 49707 2122
# METASTORE 
EXPOSE 9083