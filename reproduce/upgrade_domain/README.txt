nn: node-0
dn: node-1 node-2 node-3 node-4

# HDFS setting
# mkfs and mount a specific dir for hdfs storage '/root/data'.
# do not allocate too much space for it.
./bin/hdfs namenode -format
./sbin/start-dfs.sh

# create a file of size 128MB locally
dd if=/dev/zero of=file.txt count=131072 bs=1024

# shutdown datanode on node-4 to create unbalance capacity on datanodes
./sbin/hadoop-daemon.sh stop datanode
for i in $(seq 1 30); do ./bin/hdfs dfs -put /root/vm_images/file.txt /file"$i".txt; done

# bring node-4 back
./sbin/hadoop-daemon.sh start datanode
./bin/hdfs dfsadmin -report

# run balancer
# notice that balancer is using another configuration file
./bin/hdfs balancer -conf ~/hdfs-site-for-balancer.xml
