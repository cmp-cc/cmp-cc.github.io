----
title: Spark异常处理
date: 2015-10-14 17:54:00
updated:
categories: 
- Distributed Development
- Spark
tags:
- Spark
----

## 使用CDH5.4.5 运行spark-shell 的时候 （Spark applications stuck at ACCEPTED state）

无限循环这样一个信息
```
Application report for application_1444275336846_0027 (state: ACCEPTED)
```

{%asset_img 9ae12f91-6de5-4a4f-971d-cdfb70e3b60a.png 详情%}

**可能两个原因：**
* 你首先看一下日志详情，如出现如下情况`org.apache.spark.SparkException: Failed to connect to driver!`

{%asset_img 4ddd198c-d9f3-4fed-b9f5-6dd7a2f1ee86.png 错误信息%}

出现这样问题的原因： **防火墙没有关闭，导致Spark集群不能正常通信.**

* 你的节点管理器（NodeManager） 所提供的内存资源可能低于applications/jobs运行要求的内存。这是一个常见的情况,导致Job（作业）等待接受状态（state：ACCEPTED）,等待更多的资源来运行。
增加yarn.nodemanager.resource.memory-mb等字段的值
> You can raise the CM -> YARN -> Configuration -> "Container Memory" field values to higher numbers to resolve this.

