FROM ubuntu:latest
MAINTAINER kshitij

WORKDIR /root

RUN apt update && apt install -y ssh \
openjdk-8-jdk openssh-server wget

# set environment variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop 
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin 
ENV HDFS_NAMENODE_USER="root"
ENV HDFS_DATANODE_USER="root"
ENV HDFS_SECONDARYNAMENODE_USER="root"
ENV YARN_RESOURCEMANAGER_USER="root"
ENV YARN_NODEMANAGER_USER="root"

RUN wget https://github.com/jbw/build-hadoop/releases/download/3.0.3-ubuntu/hadoop-3.0.3.tar.gz && \
    tar -xzvf hadoop-3.0.3.tar.gz && \
    mv hadoop-3.0.3 /usr/local/hadoop && \ 
    rm hadoop-3.0.3.tar.gz

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

# Docker config
COPY hadoop-config/* /tmp/

# Hadoop config 
RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/start.sh ~/start.sh && \
    mv /tmp/.bashrc ~/.bashrc


RUN chmod +x ~/start.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh

RUN /usr/local/hadoop/bin/hdfs namenode -format

RUN sh -c service ssh start; bash

#CMD ["~/start.sh"]

CMD [ "sh", "-c", "service ssh start; bash "]

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090
# Mapred ports
EXPOSE 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122