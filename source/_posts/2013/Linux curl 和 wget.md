----
title: Linux curl 和wget
date: 2013-03-03 16:53:00
updated:
categories: 
- Operating System
- Linux


tags:
- Linux
----

## curl
如果yum找不到使用如下安装
* 下载
wget http://curl.haxx.se/download/curl-7.17.1.tar.gz
* 解压
tar -zxf curl-7.17.1.tar.gz
* 配置
```
./curl-7.17.1/configure --prefix=/usr/local/curl
```
* 安装 
```
make && make install
```
* 环境
```
 export PATH=$PATH:/usr/local/curl/bin
```
* 实例
```
curl http://www.baidu.com
```

## wget
系统找不到wget，可使用yum安装
```
yum isntall wget
```

## wget 参数
其他常用参数略，如下两个参数也经常被使用到
*  -P 下载到指定目录  
* -c 支持断点下载

