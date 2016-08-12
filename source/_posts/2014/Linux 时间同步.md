----
title: Linux 时间同步
date: 2014-06-13 19:00:00
updated:
categories: 
- Operating System
- Linux
- Work Efficiency

tags:
- Linux
----

我们需要使用到时间同步服务器，来保证Linux时间为北京时间,这一点非常重要，尤其是服务器不在国内的情况。

* 使用`date`命令查看Linux系统的当前时间
```
[root@salt ~]# date
Mon Jun 13 17:43:52 CST 2014
```
> 可以通过`date -s` 修改时间或者日期

## Linux 同步时区
* 删除本地时间
* 软连接为北京时间
* 查看当前时间
```
[root@salt ~]# rm -rf /etc/localtime 
[root@salt ~]# ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
[root@salt ~]# date
Mon Jun 13 17:50:11 CST 2014
```
> 这里没有任何变化，因为Linux 默认当前时间为CST时间而不是EDT，如果在国外，通过如下方法改为`北京时间`

## Linux 时间同步
Linux 时间，有时候莫名其妙与当前时间相差几个小时。 如果是Linux 集群，就会造成时间混乱，非常严重 。使用时间服务器同步Linux 时间。

* 安装`ntpdate` 时间同步服务器
```
yum -y install ntpdate ntp
```
- ---
* 设置 `ntpdate`
   * `vi /etc/ntp.conf` 增加如下
   ```
    server 210.72.145.44
    server cn.pool.ntp.org
   ```
   * `vi /etc/ntp/step-tickers` 加入
   ```
   210.72.145.44
   cn.pool.ntp.org
   ```
- ---

* 启动`ntpdate`
```
service ntpdate start
```
```
[root@salt ~]# service ntp start
ntp: unrecognized service
[root@salt ~]# service ntpdate start
ntpdate: Synchronizing with time server: [  OK  ]
[root@salt ~]# date
Mon Jun 13 18:49:34 CST 2014
```
> 查看时间同步服务器地址 : http://www.pool.ntp.org/zone/asia (cn.pool.ntp.org)
> 查看中国授时中心:http://zqscm.qiniucdn.com/data/20101229110057/index.html   (210.72.145.44)




