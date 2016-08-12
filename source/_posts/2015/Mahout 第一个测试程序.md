----
title: Mahout 第一个测试程序
date: 2015-04-21
updated:
categories: 
- ML
- Mahout
tags:
- Mahout
----


#### 安装配置
* 下载 `mahout-distribution-xx.tar.gz`
* 解压到 `/opt`
```
    tar -zxvf mahout-distribution-xx.tar.gz
```
* 修改 `vi /etc/profile` (可忽略)
``` 
    export MAHOUT_HOME=/opt/mahout-distribution-xx
    export PATH=$MAHOUT_HOME/bin:$PATH

    export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$MAHOUT_HOME/lib:$JAVA_HOME/lib/tools.jar
```


#### 测试
**运行一个Kmeans算法**

* 数据准备
```
     http://archive.ics.uci.edu/ml/databases/synthetic_control/synthetic_control.data
```
* hadoop 创建目录及其上传数据
```
     hadoop fs -mkdir testdata
     hadoop fs -put ~/synthetic_control.data testdata 
```
* 运行Kmeans算法
```
hadoop jar mahout-examples-0.7-job.jar org.apache.mahout.clustering.syntheticcontrol.kmeans.Job

CDH ：

hadoop jar /opt/cloudera/parcels/CDH-4.7.0-1.cdh4.7.0.p0.40/lib/mahout/mahout-examples-0.7-cdh4.7.0-job.jar org.apache.mahout.clustering.syntheticcontrol.kmeans.Job
```
**差不多运行10个MR： 数据如下：**


{%asset_img 6fb59740-fe94-43d0-a004-104d31da2bc4.png 运行结果%}

**hadoop fs -text /user/pengwei/output/data/part-m-00000 >> kmeans.txt ** 取出数据

* 源码分析 
```
http://repo1.maven.org/maven2/org/apache/mahout/mahout-examples/0.7/ 
```
查看Kmeans 算法。 了解其内部组成结构 