#!/usr/bin/bash

# Upload, run and print the result
# The validation must be performed manuelly.

hadoop fs -mkdir /user/inputs/
hadoop fs -mkdir /user/outputs/
hadoop dfs -copyFromLocal simple-test-data.txt /user/inputs/
hive -f word_count.hql
hadoop fs -cat /user/outputs/000000_0