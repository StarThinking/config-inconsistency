#!/bin/bash

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install vim

sudo apt-get -y install software-properties-common
echo | sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get -y install oracle-java8-installer
sudo apt-get -y install maven
sudo apt-get -y install build-essential autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev

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
echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle/" >> ~/.bashrc
echo "export HADOOP_HOME=/root/hadoop-3.1.1-src/hadoop-dist/target/hadoop-3.1.1" >> ~/.bashrc
source ~/.bashrc

wget http://apache.claz.org/hadoop/common/hadoop-3.1.1/hadoop-3.1.1-src.tar.gz
tar zxvf hadoop-3.1.1-src.tar.gz

cd hadoop-3.1.1-src
mvn package -Pdist,native -DskipTests -Dtar

# install zooleeper
cd ~
wget http://ftp.wayne.edu/apache/zookeeper/zookeeper-3.4.13/zookeeper-3.4.13.tar.gz
tar zxvf zookeeper-3.4.13.tar.gz 

echo "export ZOOKEEPER_HOME=/root/zookeeper-3.4.13" >> ~/.bashrc
TEST_HOME=/root/config-inconsistency/hdfs/ha
echo "export TEST_HOME=$TEST_HOME" >> ~/.bashrc
source ~/.bashrc

# mkfs for datanode
. $TEST_HOME/sbin/global_var.sh
for i in ${datanodes[@]}
do
    ssh node-$i-link-0 "printf "%s\n" n '' '' '' '' w | fdisk /dev/sdb"
    ssh node-$i-link-0 "mkfs.ext4 /dev/sdb1"
    ssh node-$i-link-0 "mkdir $hadoop_data_dir; mount /dev/sdb1 $hadoop_data_dir"
done

# mkfs for client
ssh node-$clientnode-link-0 "printf "%s\n" n '' '' '' '' w | fdisk /dev/sdb"
ssh node-$clientnode-link-0 "mkfs.ext4 /dev/sdb1"
ssh node-$clientnode-link-0 "mkdir $large_file_dir; mount /dev/sdb1 $large_file_dir; mkdir $large_file_dir_tmp"
