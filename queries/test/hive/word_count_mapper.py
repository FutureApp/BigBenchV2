#!/usr/bin/python
# orginal code-source: http://www.lichun.cc/blog/2012/06/wordcount-mapreduce-example-using-hive-on-local-and-emr/
# looked up: 2.09.2019
import sys


for line in sys.stdin:
	line = line.strip();
	words = line.split(" ");
	# write the tuples to stdout
	for word in words:
		print '%s\t%s' % (word, "1")