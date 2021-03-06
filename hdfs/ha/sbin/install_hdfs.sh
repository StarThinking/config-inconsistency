#!/bin/bash

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install vim

sudo apt-get -y install software-properties-common
sudo apt-get -y install openjdk-8-jdk
sudo apt-get update
sudo apt-get -y install maven
sudo apt-get -y install build-essential autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev libsasl2-dev
#
sudo apt-get -y install libprotobuf-java
wget https://github.com/protocolbuffers/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz
tar zxvf protobuf-2.5.0.tar.gz
cd protobuf-2.5.0/
./configure
make
make check
sudo make install
cd ~

# Optional packages
sudo apt-get -y install snappy libsnappy-dev
sudo apt-get -y install bzip2 libbz2-dev
sudo apt-get -y install libjansson-dev
sudo apt-get -y install fuse libfuse-dev
sudo apt-get -y install zstd

sudo ldconfig
echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64" >> ~/.profile
echo "export HADOOP_HOME=/root/hadoop-3.2.1-src/hadoop-dist/target/hadoop-3.2.1" >> ~/.profile

wget https://archive.apache.org/dist/hadoop/common/hadoop-3.2.1/hadoop-3.2.1-src.tar.gz
#tar zxvf hadoop-3.2.1-src.tar.gz
#
#cd hadoop-3.2.1-src
#mvn package -Pdist,native -DskipTests -Dtar
#
## install zookeeper
#cd ~
#wget https://archive.apache.org/dist/zookeeper/zookeeper-3.4.13/zookeeper-3.4.13.tar.gz
#tar zxvf zookeeper-3.4.13.tar.gz 
#
#echo "export ZOOKEEPER_HOME=/root/zookeeper-3.4.13" >> ~/.profile
#echo "export TEST_HOME=/root/config-inconsistency/hdfs/ha" >> ~/.profile
