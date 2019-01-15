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
source ~/.bashrc

wget http://apache.claz.org/hadoop/common/hadoop-3.1.1/hadoop-3.1.1-src.tar.gz
tar zxvf hadoop-3.1.1-src.tar.gz

cd hadoop-3.1.1-src
mvn package -Pdist,native -DskipTests -Dtar
