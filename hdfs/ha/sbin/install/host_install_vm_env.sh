#!/bin/bash

sudo apt-get -y install software-properties-common
sudo apt-get -y install openjdk-8-jdk
sudo apt-get update
sudo apt-get -y install maven
sudo apt-get -y install build-essential autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev
sudo ldconfig
echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64" >> ~/.profile
echo "export HADOOP_HOME=/root/hadoop-3.1.2-src/hadoop-dist/target/hadoop-3.1.2" >> ~/.profile

echo "export ZOOKEEPER_HOME=/root/zookeeper-3.4.13" >> ~/.profile
TEST_HOME=/root/config-inconsistency/hdfs/ha
echo "export TEST_HOME=$TEST_HOME" >> ~/.profile

# install virsh
sudo apt install -y qemu-kvm libvirt0 libvirt-bin virt-manager bridge-utils
sudo systemctl enable libvirt-bin
sudo apt-get -y install expect
 
# allow root user for qemu
cp $TEST_HOME/etc/qemu.conf /etc/libvirt/qemu.conf
service libvirtd restart

printf '%s\n' n '' '' '' '' w | sudo fdisk /dev/sdb
sudo mkfs.ext4 /dev/sdb1
mkdir /root/vm_images
sudo mount /dev/sdb1 /root/vm_images

