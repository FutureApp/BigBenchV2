#!/usr/bin/python
# orginal code-source: http://www.lichun.cc/blog/2012/06/wordcount-mapreduce-example-using-hive-on-local-and-emr/
# looked up: 2.09.2019
import sys

# maps words to their counts
word2count = {}

for line in sys.stdin:
    line = line.strip()

    # parse the input we got from mapper.py
    word, count = line.split('\t', 1)
    # convert count (currently a string) to int
    try:
        count = int(count)
    except ValueError:
        continue

    try:
        word2count[word] = word2count[word]+count
    except:
        word2count[word] = count

# write the tuples to stdout
# Note: they are unsorted
for word in word2count.keys():
    print '%st%s'% ( word, word2count[word] )