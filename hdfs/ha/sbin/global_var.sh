
# cluster parameters
namenodes=(0 1)
datanodes=(2 3 4)
jnodes=(2 3 4)
znodes=(0 1 5)
allnodes=(0 1 2 3 4 5)

# benchmark parameters
large_file_dir=/root/my_large_file # on sdb1 device
large_file_dir_tmp=/root/my_large_file/tmp # on sdb1 device
read_times=2
benchmark_threads=1
