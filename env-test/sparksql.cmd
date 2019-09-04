hdfs dfs -mkdir /inputs &&\
wget -O zips.json wget https://media.mongodb.org/zips.json;\
sleep 5 &&\
hdfs dfs -put zips.json /inputs &&\
echo "finish**\n"