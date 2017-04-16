FROM ubuntu:16.04

MAINTAINER kry496 <kry496@my.utsa.edu>

WORKDIR /usr/local

RUN apt-get update && \
    apt-get install -y default-jdk openssh-server wget serf

RUN addgroup hadoopadmin && \
    adduser --ingroup hadoopadmin hduser && \
    usermod -aG sudo hduser
    
RUN wget http://www-eu.apache.org/dist/hadoop/core/hadoop-2.7.3/hadoop-2.7.3.tar.gz && \
    tar -xzvf hadoop-2.7.3.tar.gz && \
    mv hadoop-2.7.3 /usr/local/hadoop && \
    rm hadoop-2.7.3.tar.gz


# Set Hadoop-related environment variables
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_MAPRED_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_HOME=$HADOOP_HOME
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV YARN_HOME=$HADOOP_HOME
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV HADOOP_JAR=/usr/local/hadoop/share/hadoop/mapreduce
# Set JAVA_HOME (we will also configure JAVA_HOME directly for Hadoop later on)
ENV JAVA_HOME=/usr/lib/jvm/default-java
# Set add bin and sbin to the PATH
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin


RUN chown -R hduser:hadoopadmin /usr/local/hadoop && \
    chmod 750 /usr/local/hadoop

RUN su hduser -c "ssh-keygen -t rsa -f /home/hduser/.ssh/id_rsa -P ''"

RUN su hduser -c "cat /home/hduser/.ssh/id_rsa.pub >> /home/hduser/.ssh/authorized_keys"


COPY config_files/* /temp_files/ 

COPY text_files/* /text_files/   

COPY scripts/* /scripts/

RUN chmod 750 /scripts/start_serf_agent.sh 

RUN mv /temp_files/hadoop-env.sh $HADOOP_CONF_DIR/hadoop-env.sh && \
    mv /temp_files/core-site.xml $HADOOP_CONF_DIR/core-site.xml && \
    mv /temp_files/hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml && \
    mv /temp_files/mapred-site.xml $HADOOP_CONF_DIR/mapred-site.xml && \
    mv /temp_files/yarn-site.xml $HADOOP_CONF_DIR/yarn-site.xml 
    

RUN mv /temp_files/ssh_config /home/hduser/.ssh/ssh_config
RUN echo "StrictHostKeyChecking no  >> /etc/ssh/ssh_config"
RUN chown hduser:hadoopadmin /home/hduser/.ssh/ssh_config

RUN mkdir -p /app/hadoop/tmp && \
    chown -R hduser:hadoopadmin /app/hadoop/tmp && \
    chmod 750 /app/hadoop/tmp


RUN su hduser -c "$HADOOP_HOME/bin/hadoop namenode -format"




CMD [ "sh", "-c", "service ssh start;/scripts/start_serf_agent.sh; bash"]
