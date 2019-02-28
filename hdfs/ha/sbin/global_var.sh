# cluster parameters

# HA cluster
#namenodes=(0 1)
#datanodes=(2 3 4) # make sure sdb is formatted
#jnodes=(2 3 4) # modify hdfs-site.xml as well
#znodes=(0 1 5)
#clientnode=5
#allnodes=(0 1 2 3 4 5)

# 4 datanodes
namenodes=(0 1)
datanodes=(1 2 3 4) # make sure sdb is formatted
reconf_datanode=4
jnodes=(1 2 3) # modify hdfs-site.xml as well
znodes=(0 1 5)
clientnode=5
allnodes=(0 1 2 3 4 5)

# dir
hadoop_data_dir=/root/data
large_file_dir=/root/my_large_file # on sdb1 device
large_file_dir_tmp=/root/my_large_file/tmp # on sdb1 device
