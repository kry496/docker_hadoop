FROM ubuntu:16.04

MAINTAINER kry496 <kry496@my.utsa.edu>

WORKDIR /usr/local

RUN apt-get update && \
    apt-get install -y default-jdk openssh-server wget serf dnsmasq

ADD dnsmasq/* /etc/

#configure serf
ENV SERF_CONFIG_DIR /etc/serf
ADD serf/* $SERF_CONFIG_DIR/
ADD handlers $SERF_CONFIG_DIR/handlers
RUN chmod +x  $SERF_CONFIG_DIR/event-router.sh $SERF_CONFIG_DIR/start-serf-agent.sh

#add hadoop user -hduser
RUN addgroup hadoopadmin && \
    adduser --ingroup hadoopadmin hduser && \
    usermod -aG sudo hduser

#download hadoop    
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

#hduser owns entire hadoop directory
RUN chown -R hduser:hadoopadmin /usr/local/hadoop && \
    chmod 750 /usr/local/hadoop

#generate ssh key
RUN su hduser -c "ssh-keygen -t rsa -f /home/hduser/.ssh/id_rsa -P ''"

#update key to authorized keys file
RUN su hduser -c "cat /home/hduser/.ssh/id_rsa.pub >> /home/hduser/.ssh/authorized_keys"


#Copy neccessary files
COPY config_files/* /temp_files/ 

COPY text_files/* $HADOOP_HOME/text_files/   

COPY scripts/* /usr/local/scripts/

RUN chmod +x /usr/local/scripts/manage_etc_hosts_file.sh

RUN mv /temp_files/hadoop-env.sh $HADOOP_CONF_DIR/hadoop-env.sh && \
    mv /temp_files/core-site.xml $HADOOP_CONF_DIR/core-site.xml && \
    mv /temp_files/hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml && \
    mv /temp_files/mapred-site.xml $HADOOP_CONF_DIR/mapred-site.xml && \
    mv /temp_files/yarn-site.xml $HADOOP_CONF_DIR/yarn-site.xml 
    
#update ssh_config for hduser
RUN mv /temp_files/ssh_config /home/hduser/.ssh/ssh_config
RUN echo "StrictHostKeyChecking no  >> /etc/ssh/ssh_config"
RUN chown hduser:hadoopadmin /home/hduser/.ssh/ssh_config

#setup hadoop temp folders 
RUN mkdir -p /app/hadoop/tmp && \
    chown -R hduser:hadoopadmin /app/hadoop/tmp && \
    chmod 750 /app/hadoop/tmp


# format hdfs
RUN su hduser -c "$HADOOP_HOME/bin/hadoop namenode -format"

# Expose ports
EXPOSE 22 7373 7946 9000 50010 50020 50070 50075 50090 50475 8030 8031 8032 8033 8040 8042 8060 8088 50060

CMD [ "sh", "-c", "echo hello; bash"]
