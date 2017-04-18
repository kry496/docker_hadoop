#!/bin/bash           

rm $HADOOP_CONF_DIR/slaves                                                                                                                                                                                                        
serf members -status=alive |awk -F :7946 '{print $1}'|awk '{print $1}'>> $HADOOP_CONF_DIR/slaves  
