#!/bin/bash

./sbin/binary_search.sh  max dfs.balancer.block-move.timeout 1  namenode 1 300 1

./sbin/binary_search.sh  max dfs.balancer.dispatcherThreads 200  namenode 1 300 1

./sbin/binary_search.sh  max dfs.balancer.getBlocks.min-block-size 10485760  namenode 1 300 1

./sbin/binary_search.sh  max dfs.balancer.getBlocks.size 2147483648  namenode 1 300 1

./sbin/binary_search.sh  max dfs.balancer.max-iteration-time 1200000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.balancer.max-no-move-interval 60000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.balancer.max-size-to-move 10737418240  namenode 1 300 1

./sbin/binary_search.sh  max dfs.balancer.movedWinWidth 5400000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.balancer.moverThreads 1000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.block.access.key.update.interval 600  namenode 1 300 1

./sbin/binary_search.sh  max dfs.block.access.token.lifetime 600  namenode 1 300 1

./sbin/binary_search.sh  max dfs.block.invalidate.limit 1000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.block.misreplication.processing.limit 10000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.block.scanner.volume.bytes.per.second 1048576  namenode 1 300 1

./sbin/binary_search.sh  max dfs.blockreport.incremental.intervalMsec 1  namenode 1 300 1

./sbin/binary_search.sh  max dfs.blockreport.intervalMsec 21600000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.blockreport.split.threshold 1000000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.blocksize 134217728  namenode 1 300 1

./sbin/binary_search.sh  max dfs.bytes-per-checksum 512  namenode 1 300 1

./sbin/binary_search.sh  max dfs.cachereport.intervalMsec 10000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.content-summary.limit 5000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.content-summary.sleep-microsec 500  namenode 1 300 1

./sbin/binary_search.sh  max dfs.default.chunk.view.size 32768  namenode 1 300 1

./sbin/binary_search.sh  max dfs.disk.balancer.block.tolerance.percent 10  namenode 1 300 1

./sbin/binary_search.sh  max dfs.disk.balancer.max.disk.errors 5  namenode 1 300 1

./sbin/binary_search.sh  max dfs.disk.balancer.max.disk.throughputInMBperSec 10  namenode 1 300 1

./sbin/binary_search.sh  max dfs.disk.balancer.plan.threshold.percent 10  namenode 1 300 1

./sbin/binary_search.sh  max dfs.domain.socket.disable.interval.seconds 600  namenode 1 300 1

./sbin/binary_search.sh  max dfs.edit.log.transfer.bandwidthPerSec 1  namenode 1 300 1

./sbin/binary_search.sh  max dfs.edit.log.transfer.timeout 30000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.encrypt.data.transfer.cipher.key.bitlength 128  namenode 1 300 1

./sbin/binary_search.sh  max dfs.ha.tail-edits.namenode-retries 3  namenode 1 300 1

./sbin/binary_search.sh  max dfs.ha.tail-edits.rolledits.timeout 60  namenode 1 300 1

./sbin/binary_search.sh  max dfs.ha.zkfc.nn.http.timeout.ms 20000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.http.client.failover.max.attempts 15  namenode 1 300 1

./sbin/binary_search.sh  max dfs.http.client.failover.sleep.base.millis 500  namenode 1 300 1

./sbin/binary_search.sh  max dfs.http.client.failover.sleep.max.millis 15000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.http.client.retry.max.attempts 10  namenode 1 300 1

./sbin/binary_search.sh  max dfs.image.transfer-bootstrap-standby.bandwidthPerSec 1  namenode 1 300 1

./sbin/binary_search.sh  max dfs.image.transfer.bandwidthPerSec 1  namenode 1 300 1

./sbin/binary_search.sh  max dfs.image.transfer.chunksize 65536  namenode 1 300 1

./sbin/binary_search.sh  max dfs.image.transfer.timeout 60000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.journalnode.sync.interval 120000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.ls.limit 1000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.mover.max-no-move-interval 60000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.mover.movedWinWidth 5400000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.mover.moverThreads 1000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.mover.retry.max.attempts 10  namenode 1 300 1

./sbin/binary_search.sh  max dfs.provided.aliasmap.inmemory.batch-size 500  namenode 1 300 1

./sbin/binary_search.sh  max dfs.provided.aliasmap.load.retries 1  namenode 1 300 1

./sbin/binary_search.sh  max dfs.qjournal.accept-recovery.timeout.ms 120000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.qjournal.finalize-segment.timeout.ms 120000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.qjournal.get-journal-state.timeout.ms 120000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.qjournal.new-epoch.timeout.ms 120000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.qjournal.prepare-recovery.timeout.ms 120000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.qjournal.queued-edits.limit.mb 10  namenode 1 300 1

./sbin/binary_search.sh  max dfs.qjournal.select-input-streams.timeout.ms 20000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.qjournal.start-segment.timeout.ms 20000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.qjournal.write-txns.timeout.ms 20000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.replication 3  namenode 1 300 1

./sbin/binary_search.sh  max dfs.replication.max 512  namenode 1 300 1

./sbin/binary_search.sh  max dfs.short.circuit.shared.memory.watcher.interrupt.check.ms 60000  namenode 1 300 1

./sbin/binary_search.sh  max dfs.stream-buffer-size 4096  namenode 1 300 1

./sbin/binary_search.sh  max dfs.webhdfs.netty.high.watermark 65535  namenode 1 300 1

./sbin/binary_search.sh  max dfs.webhdfs.netty.low.watermark 32768  namenode 1 300 1

./sbin/binary_search.sh  max dfs.webhdfs.ugi.expire.after.access 600000  namenode 1 300 1

./sbin/binary_search.sh  max hadoop.fuse.connection.timeout 300  namenode 1 300 1

./sbin/binary_search.sh  max hadoop.fuse.timer.period 5  namenode 1 300 1

./sbin/binary_search.sh  max httpfs.buffer.size 4096  namenode 1 300 1

./sbin/binary_search.sh  max nfs.rtmax 1048576  namenode 1 300 1

./sbin/binary_search.sh  max nfs.wtmax 1048576  namenode 1 300 1

./sbin/binary_search.sh  max dfs.blockreport.initialDelay 1  namenode 1 300 1

./sbin/binary_search.sh  max dfs.disk.balancer.plan.valid.interval 1  namenode 1 300 1

./sbin/binary_search.sh  max dfs.ha.tail-edits.period 60  namenode 1 300 1

./sbin/binary_search.sh  max dfs.heartbeat.interval 3  namenode 1 300 1

./sbin/binary_search.sh  max dfs.lock.suppress.warning.interval 10  namenode 1 300 1

./sbin/binary_search.sh  max dfs.qjm.operations.timeout 60  namenode 1 300 1

./sbin/binary_search.sh  max dfs.webhdfs.socket.connect-timeout 60  namenode 1 300 1

./sbin/binary_search.sh  max dfs.webhdfs.socket.read-timeout 60  namenode 1 300 1

./sbin/binary_search.sh  max dfs.ha.log-roll.period 120  namenode 1 300 1

