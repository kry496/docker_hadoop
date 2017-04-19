#! /bin/bash

hdfs dfs -mkdir /a

hdfs dfs -copyFromLocal $HADOOP_HOME/text_files/* /a 

hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.3.jar wordcount /a /ba
