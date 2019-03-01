
./sbin/run_test.sh dfs.datanode.balance.bandwidthPerSec 1k datanode
sleep 30
./sbin/run_test.sh dfs.datanode.balance.bandwidthPerSec 1g datanode
sleep 30

./sbin/run_test.sh dfs.datanode.balance.max.concurrent.moves 1 datanode
sleep 30
./sbin/run_test.sh dfs.datanode.balance.max.concurrent.moves 5000 datanode
sleep 30

./sbin/run_test.sh dfs.datanode.block-pinning.enabled  datanode
sleep 30
./sbin/run_test.sh dfs.datanode.block-pinning.enabled TRUE datanode
sleep 30

./sbin/run_test.sh dfs.datanode.block.id.layout.upgrade.threads 1 datanode
sleep 30
./sbin/run_test.sh dfs.datanode.block.id.layout.upgrade.threads 1200 datanode
sleep 30

