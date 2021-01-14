nn: node-0
dn: node-1 node-2 node-3 node-4

# HDFS setting
# mkfs and mount a specific dir for hdfs storage '/root/data'.
# do not allocate too much space for it.
mkfs.ext4 /dev/sdb1
mkdir /root/data; mount /dev/sdb1 /root/data
./bin/hdfs namenode -format
./sbin/start-dfs.sh

# create a file of size 512MB locally
dd if=/dev/zero of=file.txt count=131072 bs=4096

# shutdown datanode on node-4 to create unbalance capacity on datanodes
./sbin/hadoop-daemon.sh stop datanode
for i in $(seq 1 30); do ./bin/hdfs dfs -put ./file.txt /file"$i".txt; done

# bring node-4 back
./sbin/hadoop-daemon.sh start datanode
./bin/hdfs dfsadmin -report

# run balancer
# notice that balancer is using another configuration file
./bin/hdfs balancer -conf ~/config-inconsistency/reproduce/upgrade_domain/hdfs-site-for-balancer.xml
