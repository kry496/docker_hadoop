#!/bin/bash

grep -rl 'master:' $HADOOP_CONF_DIR/ | xargs sed -i 's/master:/'"$(serf members -status=alive | awk '{print $1}' | grep master)"':/g'
