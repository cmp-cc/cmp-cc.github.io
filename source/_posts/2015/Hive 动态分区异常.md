----
title: Hive 动态分区异常
date: 2015-07-22 19:53:00
categories: 
- Distributed Development
- Hive
tags:
- Hive
----


## 异常信息
** 我们大致设置这样一条插入语句:**

hue_sunyan_detection0711表中 dt>'20150415'的数据插入到pengwei_test_detection0711表中，并自动创建分区。

```
insert overwrite table pengwei_test_detection0711 partition(dt, channel,apptoken)
select a.log_id,a.time,a.receive_time,a.receiver_ip,a.user_ip,a.id,
a.system,a.device,a.version,a.detection_time,
a.app_type,a.apk_md5,a.apk_name,a.vir_name,a.time_consuming,a.engine_version,a.siglib_version,a.scan_opt,a.dt,a.channel,a.apptoken
from hue_sunyan_detection0711 a where dt is not null and dt>'20150415';
```
**他会抛出如下异常。**

{% asset_img 6b1dc171-e5ff-4cd3-8d6d-7d6e2d7be83f.png 异常详情%}
```
Diagnostic Messages for this Task:
Error: java.lang.RuntimeException: org.apache.hadoop.hive.ql.metadata.HiveException: Hive Runtime Error while processing row {"log_id":"fb0c8ac2-93ba-4788-878d-ce572237e5e4","time":"1421005659","receive_time":"1435946517","receiver_ip":"127.0.0.1","user_ip":"75.133.213.133","id":"3333ca9c9857c31b","system":"ro.build.version.release=4.2.2/samsung","device":"SM-T110","version":"0.0.1","detection_time":"1433433618","app_type":"U","apk_md5":"BF70797DF6896555F476F321B2C40DBB","apk_name":"com.pixelberrystudios.hssandroid","vir_name":null,"time_consuming":"14950989","engine_version":null,"siglib_version":null,"scan_opt":null,"dt":"20150605","channel":"opensdk","apptoken":"BD843247B44E87DDDAB7DDAC7FBAE8F6"}
        at org.apache.hadoop.hive.ql.exec.ExecMapper.map(ExecMapper.java:159)
        at org.apache.hadoop.mapred.MapRunner.run(MapRunner.java:54)
        at org.apache.hadoop.mapred.MapTask.runOldMapper(MapTask.java:428)
        at org.apache.hadoop.mapred.MapTask.run(MapTask.java:340)
        at org.apache.hadoop.mapred.YarnChild$2.run(YarnChild.java:160)
        at java.security.AccessController.doPrivileged(Native Method)
        at javax.security.auth.Subject.doAs(Subject.java:396)
        at org.apache.hadoop.security.UserGroupInformation.doAs(UserGroupInformation.java:1438)
        at org.apache.hadoop.mapred.YarnChild.main(YarnChild.java:155)
Caused by: org.apache.hadoop.hive.ql.metadata.HiveException: Hive Runtime Error while processing row {"log_id":"fb0c8ac2-93ba-4788-878d-ce572237e5e4","time":"1421005659","receive_time":"1435946517","receiver_ip":"127.0.0.1","user_ip":"75.133.213.133","id":"3333ca9c9857c31b","system":"ro.build.version.release=4.2.2/samsung","device":"SM-T110","version":"0.0.1","detection_time":"1433433618","app_type":"U","apk_md5":"BF70797DF6896555F476F321B2C40DBB","apk_name":"com.pixelberrystudios.hssandroid","vir_name":null,"time_consuming":"14950989","engine_version":null,"siglib_version":null,"scan_opt":null,"dt":"20150605","channel":"opensdk","apptoken":"BD843247B44E87DDDAB7DDAC7FBAE8F6"}
        at org.apache.hadoop.hive.ql.exec.MapOperator.process(MapOperator.java:675)
        at org.apache.hadoop.hive.ql.exec.ExecMapper.map(ExecMapper.java:141)
        ... 8 more
Caused by: org.apache.hadoop.hive.ql.metadata.HiveException: java.io.IOException: Bad connect ack with firstBadLink as 192.168.12.65:50010
        at org.apache.hadoop.hive.ql.exec.FileSinkOperator.processOp(FileSinkOperator.java:620)
        at org.apache.hadoop.hive.ql.exec.Operator.process(Operator.java:474)
        at org.apache.hadoop.hive.ql.exec.Operator.forward(Operator.java:803)
        at org.apache.hadoop.hive.ql.exec.SelectOperator.processOp(SelectOperator.java:84)
        at org.apache.hadoop.hive.ql.exec.Operator.process(Operator.java:474)
        at org.apache.hadoop.hive.ql.exec.Operator.forward(Operator.java:803)
        at org.apache.hadoop.hive.ql.exec.FilterOperator.processOp(FilterOperator.java:132)
        at org.apache.hadoop.hive.ql.exec.Operator.process(Operator.java:474)
        at org.apache.hadoop.hive.ql.exec.Operator.forward(Operator.java:803)
        at org.apache.hadoop.hive.ql.exec.TableScanOperator.processOp(TableScanOperator.java:83)
        at org.apache.hadoop.hive.ql.exec.Operator.process(Operator.java:474)
        at org.apache.hadoop.hive.ql.exec.Operator.forward(Operator.java:803)
        at org.apache.hadoop.hive.ql.exec.MapOperator.process(MapOperator.java:656)
        ... 9 more
Caused by: java.io.IOException: Bad connect ack with firstBadLink as 192.168.12.65:50010
        at org.apache.hadoop.hdfs.DFSOutputStream$DataStreamer.createBlockOutputStream(DFSOutputStream.java:1168)
        at org.apache.hadoop.hdfs.DFSOutputStream$DataStreamer.nextBlockOutputStream(DFSOutputStream.java:1091)
        at org.apache.hadoop.hdfs.DFSOutputStream$DataStreamer.run(DFSOutputStream.java:502)
```

## 解决方案
**通过如下设置可解决如上异常。**

原因：我们默认分区数过低，有如下几个设置参数：
* hive.exec.max.dynamic.partitions.pernode  （default：100）：每个节点上能够生成的最大分区数。
* hive.exec.max.dynamic.partitions （fault：1000）： 一条DML语句允许创建的最大分区数
* hive.exec.max.created.files （fault：100000）：能够创建的最多文件数。

<pre>
SET hive.exec.max.dynamic.partitions=100000;
SET hive.exec.max.dynamic.partitions.pernode=100000;
</pre>

** 但是如果执行如下HQL，依然会抛出出异常。**

将hue_sunyan_detection0711表的数据文件拷贝到pengwei_test_detection0711表。

```
insert overwrite table pengwei_test_detection0711 partition(dt, channel,apptoken)
select a.log_id,a.time,a.receive_time,a.receiver_ip,a.user_ip,a.id,
a.system,a.device,a.version,a.detection_time,
a.app_type,a.apk_md5,a.apk_name,a.vir_name,a.time_consuming,a.engine_version,a.siglib_version,a.scan_opt,a.dt,a.channel,a.apptoken
from hue_sunyan_detection0711 a where dt is not null;
```

## 我有如下尝试

> 1、修改动态分区参数。（几乎给予最大上限）
```
set hive.exec.max.dynamic.partitions.pernode=1000000;
set hive.exec.max.dynamic.partitions=1000000;
set hive.exec.max.created.files=10000000;
```
> 2、设置Number of map的数量，甚至关闭并行计算。
> 3、查阅一些资料。

> 谁有解决方案啊~~~，告诉我一下！！！
** 插入动态分区是简单，但是这个问题，我都认为是Hive Bug 了 **
```
set hive.exec.dynamic.partition=true; // 是否可以使用动态分区
set hive.exec.dynamic.partition.mode=nostrick;//设置为运行所有分区为动态分区。默认为strick。主分区（第一分区）为静态分区。
```


## 结论
   1. 分批插入数据。（可以按照dt划分多个HQL，分别执行。）
   2. 一定是一个Bug，哈哈~ 尝试更新CDH版本，我们当前CDH版本为4.7。 内置Hive版本为hive-0.10.0+263。 CDH5.4内置hive版本hive-1.1.0。 

> 2015年年初,大数据运维承诺升级CDH5.3，这都TM7月份了
