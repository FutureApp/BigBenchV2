
cd ${HADOOP_HOME}
wget -O alice.txt https://www.gutenberg.org/files/11/11-0.txt
hdfs dfs -mkdir inputs
hdfs dfs -put alice.txt inputs

