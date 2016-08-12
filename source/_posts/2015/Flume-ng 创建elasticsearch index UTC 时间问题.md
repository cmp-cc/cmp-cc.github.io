----
title: Flume-ng 创建elasticsearch index UTC 时间问题
date: 2015-12-14 17:53:00
updated:
categories: 
- Distributed Development
- Flume-ng
tags:
- Flume-ng
----

Flume 自动创建es Index，默认采用UTC时间（每天早点八点创建索引）。也就是比北京时间晚8个小时。
这就就会导致今天前8个小时数据在昨天，今天最后8个小时的数据是明天（第二天0点-8点插入今天）。

解决方案：
fastDateFormat会格式化timestamp，然后创建index，且默认使用Etc/UTC时区。（中国时间8点）
```
private FastDateFormat fastDateFormat = FastDateFormat.getInstance("yyyy-MM-dd", TimeZone.getTimeZone("Etc/UTC"));
```
修改配置文件，如下，将fastDateFormat时区改为中国时间
```
a1.sinks.k1.timeZone=Asia/Shanghai
```
> flume-elasticsearch-sink 同样需要如上配置