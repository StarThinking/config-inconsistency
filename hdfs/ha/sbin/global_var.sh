# cluster parameters

# HA cluster
#namenodes=(0 1)
#datanodes=(2 3 4) # make sure sdb is formatted
#jnodes=(2 3 4) # modify hdfs-site.xml as well
#reconf_journalnode=4
#znodes=(0 1 5) # core-site.xml?
#znode_ids=(1 2 3)
#clients=(5)
#allnodes=(0 1 2 3 4 5)

# 4 datanodes
namenodes=(0 1)
datanodes=(2 3 4 5) # make sure sdb is formatted
reconf_datanode=5
reconf_journalnode=4
jnodes=(2 3 4) # modify hdfs-site.xml as well
znodes=(0 1 6) # core-site.xml?
znode_ids=(1 2 3)
clients=(6)
allnodes=(0 1 2 3 4 5 6)

# dir
hadoop_root_dir=/root/hdfs-root
hadoop_data_dir=$hadoop_root_dir/data # for datanode
journal_dir=$hadoop_root_dir/journal # for datanode
large_file_dir=$hadoop_root_dir/my_large_file # for client
large_file_dir_tmp=$hadoop_root_dir/my_large_file/tmp # for client
