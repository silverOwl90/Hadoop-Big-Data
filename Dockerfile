FROM ubuntu:22.04

# Install basic dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    tar \
    openssh-server \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create hadoop user
RUN useradd -m -s /bin/bash hadoop \
    && echo "hadoop:hadoop" | chpasswd \
    && adduser hadoop sudo

# Download and extract hadoop like root
RUN mkdir -p /opt/hadoop \
    && wget -q https://dlcdn.apache.org/hadoop/common/hadoop-3.4.1/hadoop-3.4.1.tar.gz -O /tmp/hadoop-3.4.1.tar.gz \
    && tar xf /tmp/hadoop-3.4.1.tar.gz -C /opt/hadoop --strip-components=1 \
    && rm -f /tmp/hadoop-3.4.1.tar.gz

# Change priority of /opt/hadoop to hadoop user
RUN chown -R hadoop:hadoop /opt/hadoop

# Download and configurate OpenJDK 8 like root
RUN mkdir -p /opt/hadoop/jdk \
    && wget -q https://download.java.net/openjdk/jdk8u44/ri/openjdk-8u44-linux-x64.tar.gz -O /tmp/openjdk-8u44-linux-x64.tar.gz \
    && tar xf /tmp/openjdk-8u44-linux-x64.tar.gz -C /opt/hadoop/jdk --strip-components=1 \
    && rm -f /tmp/openjdk-8u44-linux-x64.tar.gz

# Change priority of /opt/hadoop/jdk to hadoop user
RUN chown -R hadoop:hadoop /opt/hadoop/jdk

# Configurate enviroment variables at .bashrc of hadoop user
RUN echo 'export JAVA_HOME=/opt/hadoop/jdk' >> /home/hadoop/.bashrc \
    && echo 'export HADOOP_HOME=/opt/hadoop' >> /home/hadoop/.bashrc \
    && echo 'export PATH=${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${PATH}' >> /home/hadoop/.bashrc

# Change to user hadoop
USER hadoop
WORKDIR /home/hadoop
