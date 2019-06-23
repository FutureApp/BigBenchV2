FROM java:8-jre

# Add native libs
ARG HADOOP_VERSION=2.6.5
# ADD content/hadoop-${HADOOP_VERSION}.tar.gz /usr/local
#ADD hadoop-native-${HADOOP_VERSION}.tar /usr/local/hadoop-${HADOOP_VERSION}/lib/native

ENV \
  HADOOP_PREFIX=/usr/local/hadoop \
  HADOOP_COMMON_HOME=/usr/local/hadoop \
  HADOOP_HDFS_HOME=/usr/local/hadoop \
  HADOOP_MAPRED_HOME=/usr/local/hadoop \
  HADOOP_YARN_HOME=/usr/local/hadoop \
  HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop \
  HADOOP_HOME=/usr/local/hadoop \
  YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop \
  HADOOP_USER_CLASSPATH_FIRST=true \
  HIVE_HOME=/usr/local/hadoop/hive  \
  PATH="${PATH}:/usr/local/hadoop/bin:\
/usr/local/hadoop/hive/bin"


RUN \
cd ${HADOOP_HOME}/.. && \
HADOOP_VERSION=2.6.5; wget -q \
  https://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
mkdir hadoop && \
pwd && \
tar -xf hadoop*.tar.gz -C hadoop --strip-components=1 && \
echo "Version $(ls | grep hadoop- | sed -e 's/[^0-9 . ]//g')" >> ./hadoop/version.conf && \
chmod +x ./hadoop/bin/hadoop && \
rm -rf hadoop*.*

RUN \
  rm -f ${HADOOP_PREFIX}/logs/*

# HIVE
RUN \
  cd ${HADOOP_HOME} && \
  mkdir -p hive && \
  wget -q http://archive.cloudera.com/cdh5/cdh/5/hive-0.13.1-cdh5.3.2.tar.gz && \
  tar -xf hive*.tar.gz -C hive --strip-components=1 && \
  rm hive-*.tar.gz

  # the jessie specific files were moved to the archive backend
  # In order to run apt-get update we have to use the following workaround
  # Solution based on the git hubposts under (state 4/28/2019;14.10):
  # https://unix.stackexchange.com/questions/508724/failed-to-fetch-jessie-backports-repository
RUN \
  echo "deb [check-valid-until=no] http://cdn-fastly.deb.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie.list && \
  echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list && \
  sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list && \
  apt-get -o Acquire::Check-Valid-Until=false update && \
  apt-get install libmysql-java -y  && \
  ln -s /usr/share/java/mysql-connector-java.jar /usr/local/hadoop/hive/lib/mysql-connector-java.jar
  
  
ADD content/hive-env.sh /usr/local/hadoop/hive/conf/hive-env.sh
ADD content/hive-site.xml /usr/local/hadoop/hive/conf/hive-site.xml

ENV \
  HADOOP_USER_CLASSPATH_FIRST=true \  
  HADOOP_OPTS="-Djava.library.path=/usr/local/hadoop/lib"



# --------------------------------------------------------------[ Python-S ]--
# System install procedure
RUN \
    apt-get install -y nano python3 dnsutils  python3-pip   && \
    echo 'alias python="python3 "' >> ~/.bashrc         && \
    echo 'alias pip="pip3 "' >> ~/.bashrc

# --------------------------------------------------------------[ Python-F ]--
WORKDIR $HADOOP_PREFIX

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122
# METASTORE 
EXPOSE 9083
