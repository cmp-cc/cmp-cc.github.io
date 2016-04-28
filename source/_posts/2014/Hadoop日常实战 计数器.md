----
title: Hadoop日常实战 计数器
date: 2014-12-16 17:26:00
categories: 
- 大数据开发
tags:
- Hadoop
----

计数器是一种收集作业统计信息的有效有段

  **在一般情况下，我很需要了解一下Mapreduce 的运行情况，运行的过程是不可见，程序运行成功，但我们不能保证数据是正确的。我们需要质量控制、应用级统计。计数器可以辅助诊断系统故障，检测某一事件是否发生。计数特定属性、方法、异常。然后进一步分析程序数据的正确性。**


## 内置计数器控制台视图

Hadoop 中的内置计数器，用于帮助你分析Mapreduce执行程序的具体状体。

如下是`Hadoop 2.0.0-cdh4.7.0` Hadoop Mapreudce执行程序控制台显示



{% asset_img QQ图片20141211110508.png 内置计数器 %}

 **Counter有组（group）的概念，用于表示逻辑上相同范围的所有数值。**
上图默认输出Counter分为三个组，从中我们可以分析出程序运行使用 CPU、内存、IO读写、网络流量的一个基本情况 

文章推荐: http://www.cnblogs.com/ggjucheng/archive/2013/05/08/3065220.html

## 内置计数器的分类：

分组 |  属性名
--- | ---
Mapreduce任务计数器  | org.apache.hadoop.mapreduce. TaskCounter
任务计数器 | org.apache.hadoop.mapreduce. JobCounter
文件系统计数器 | org.apache.hadoop.mapreduce.FileSystemCounter
输入文件计数器 | org.apache.hadoop.mapreduce.lib.input. FileInputFormatCounter
输出文件计数器 | org.apache.hadoop.mapreduce.lib.output. FileOutputFormatCounter

**这些就是hadoop 内置的计数器类（组），均是枚举类型。**

## 静态计数器和动态计数器

* 静态计数器
**定义一个枚举(enum) 枚举的名称即使Counter组的名称。 枚举属性即使要记录的数值名称，Mapreduce框架将跨所有map和reduce聚集这些计数器，并在作业结束时产生一个结果。**
```
static enum ReporInfo{
    // 统计map端读取数据是否按预期。 MISSING输出为0，表示没有输入数据完整或无缺损。
  MISSING
}
//通过Mapper中的context对象进行计数
context.getCounter(Temperature.MISSING).increment(1);
```
* 动态计数器
**动态计数器使用更加简单,你需要指定两个变量，这个变量均是动态指定。**
```
// 组的名称  和  动态计数的字段名称
context.getCounter("group name","dynamic args").increment(1);
```
* 比较
**静态类型： 先将java枚举类型转换成String类型，再通过RPC发送计数器，两种创建和访问计数器方法(枚举类型和String类型) 实际是等价的。    
相比之下，枚举类型易于使用，还提供类型安全，使用与大多数作业，特定场合使用动态计数器。**

## 通过计数器获取Mapreduce的运行情况
获取计数器：  作业长时间运行，我们需要通过计数器了解运行情况。我们只需要写一个监听类就可以。
如下是Mapreduce2.0写法，同样需要引用1.0中的JobClient类。
```
String jobID = args[0];
JobClient jobClient = new JobClient(new JobConf(getConf()));
RunningJob job = jobClient.getJob(JobID.forName(jobID));
Counters counters = job.getCounters();
long missing = counters.getCounter(
MaxTemperatureWithCounters.Temperature.MISSING);
    
long total = counters.getCounter(Task.Counter.MAP_INPUT_RECORDS);

System.out.printf("Records with missing temperature fields: %.2f%%\n",100.0 * missing / total);
```

## 计数器原理

{% asset_img c5c20a58-0087-49b2-a5d5-91ca4ae38066.jpg 计数器原理图 %}
* 计数器实质是由JobTracker维护，计数器值会定期传到tasktracker，在由tasktracker传递给jobtracker。也就是说所有的计数器信息都是存在jobTracker的内存中，计数器序列化并状态更新同步到JobTracker。
* TaskTracker中累加计数器 记录单节点中的计数个数。通过“心跳“ 传递信息给JobTracker。
* JobTracker会下运行结束之前最终汇总时剔除掉失败任务计数器。


Mapreduce1.0中并没有限制计数器的个数，极其影响程序性能。
为了不对JobTracker产生印象。计数器数目应当控制到100以下。

如果你的计数器超过了120个就会报如下错误：
org.apache.hadoop.mapreduce.counters.LimitExceededException: Too many counters: 121 max=120

## 异常处理
你可能遇到如下异常
```
14/12/12 09:56:48 INFO mapred.JobClient: Task Id : attempt_201412091419_0236_m_000028_0, Status : FAILED
Error: Found interface org.apache.hadoop.mapreduce.Counter, but class was expected
```
* 原因：
**你本地的使用的编译环境是Hadoop1.0(MR1) 而你的集群环境为hadoop2.0(MR2) 所以默认没有找到。**
* 解决方案
更改为hadoop2.0(hadoop-mapreduce-client-core-2.0.0-cdh4.7.0.jar，hadoop-common-2.0.0-cdh4.7.0.jar)的jar。和集群环境保持一致。

推荐Blog：
http://langyu.iteye.com/blog/1171091



