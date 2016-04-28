----
title: Hbase异常记录及其解决方案
date: 2015-04-08 10:42:00
updated: 2015-07-08 10:42:00
categories: 
- Distributed Development
- Hbase
tags:
- Hbase
----

**记录我Hbase 使用的相关问题解决方案，持续更新**

## java.net.ConnectException: Connection refused
### 问题描述
```
at sun.nio.ch.SocketChannelImpl.checkConnect(Native Method)
at sun.nio.ch.SocketChannelImpl.finishConnect(SocketChannelImpl.java:739)
at org.apache.zookeeper.ClientCnxnSocketNIO.doTransport(ClientCnxnSocketNIO.java:350)
at org.apache.zookeeper.ClientCnxn$SendThread.run(ClientCnxn.java:1075)
15/04/08 10:42:26 WARN zookeeper.RecoverableZooKeeper: Possibly transient ZooKeeper exception: org.apache.zookeeper.KeeperException$ConnectionLossException: KeeperErrorCode = ConnectionLoss for /hbase/hbaseid
15/04/08 10:42:26 INFO util.RetryCounter: Sleeping 2000ms before retry #1...
15/04/08 10:42:27 INFO zookeeper.ClientCnxn: Opening socket connection to server localhost/127.0.0.1:2181. Will not attempt to authenticate using SASL (unknown error)
15/04/08 10:42:27 WARN zookeeper.ClientCnxn: Session 0x0 for server null, unexpected error, closing socket connection and attempting reconnect
java.net.ConnectException: Connection refused
```
### 解决方案
**hbase-site.xml 中没有配置`hbase.zookeeper.quorum`**

应用程序指定ZK地址
```
conf.set("hbase.zookeeper.quorum", "datanode01.hadoop"); 
```


> ## ConnectionException: An error is preventing HBase from connecting to ZooKeeper

### 问题描述

```
Thu Apr 23 17:38:19 CST 2015, org.apache.hadoop.hbase.client.ScannerCallable@60ac8067, org.apache.hadoop.hbase.ZooKeeperConnectionException: An error is preventing HBase from connecting to ZooKeeper

        at org.apache.hadoop.hbase.client.AbstractClientScanner$1.hasNext(AbstractClientScanner.java:44)
        at mapreduce.test1.md5ConvertID(test1.java:41)
        at mapreduce.test1.main(test1.java:152)
        at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
        at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.lang.reflect.Method.invoke(Method.java:606)
        at org.apache.hadoop.util.RunJar.main(RunJar.java:208)
```
### 解决方案
**检查相关程序，确保scanner开放**
```
     ResultScanner scanner = table.getScanner(scan);
     使用scanner 获取数据的时候， Htable 已经关闭。
```
 
## Too Many fetch failures.Failing the attempt

### 解决方案
** 某一台服务器上的磁盘满了。 删除临时文件或无效数据。 或者增加磁盘**