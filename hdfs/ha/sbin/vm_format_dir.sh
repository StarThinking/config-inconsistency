#!/bin/bash

printf '%s\n' n '' '' '' '' w | sudo fdisk /dev/sdb
sudo mkfs.ext4 /dev/sdb1
mkdir ~/vm_images
sudo mount /dev/sdb1 ~/vm_images
