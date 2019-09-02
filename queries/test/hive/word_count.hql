-- orginal code-source: http://www.lichun.cc/blog/2012/06/wordcount-mapreduce-example-using-hive-on-local-and-emr/
-- looked up: 2.09.2019
drop table if exists raw_lines;

-- create table raw_line, and read all the lines in '/user/inputs', this is the path on your local HDFS
create external table if not exists raw_lines(line string)
ROW FORMAT DELIMITED
stored as textfile
location '/user/inputs';

drop table if exists word_count;

-- create table word_count, this is the output table which will be put in '/user/outputs' as a text file, this is the path on your local HDFS

create external table if not exists word_count(word string, count int)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
lines terminated by '\n' STORED AS TEXTFILE LOCATION '/user/outputs/';

-- add the mapper&reducer scripts as resources, please change your/local/path
add file /bigbenchv2/queries/test/hive/word_count_mapper.py;
add file /bigbenchv2/queries/test/hive/word_count_reducer.py;

from (
        from raw_lines
        map raw_lines.line
        --call the mapper here
        using 'word_count_mapper.py'
        as word, count
        cluster by word) map_output
insert overwrite table word_count
reduce map_output.word, map_output.count
--call the reducer here
using 'word_count_reducer.py'
as word,count;