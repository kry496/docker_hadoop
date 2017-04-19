#!/bin/bash

                
ssh-keyscan -f $HADOOP_CONF_DIR/slaves >> ~/.ssh/known_hosts                    

export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin    

$HADOOP_HOME/sbin/start-all.sh
