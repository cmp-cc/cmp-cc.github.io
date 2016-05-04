----
title: Linux 开发环境安装指南
date: 2014-11-07 16:53:00
updated: 2015-12-14 17:50:00
categories: 
- Operating System
- Linux
tags:
- Linux
- 安装部署
----

**我的Linux (Centos)开发、应用部署环境，持续更新**

## 安装JDK1.8

### 查看Linux 自带的JDK是否安装
```
java -version
```

{% asset_img 596f24a9-b58f-40e3-b02c-6cfdf4c58dab.png  已安装OpenJDK7 运行环境，但没有编译环境%}
### 卸载自带JDK
#### 查看相关依赖
```
rpm -qa | grep java

或则

rmp -qa |grep jdk
```

{% asset_img 2310dfba-98e6-478a-890e-11291c66f2d1.png  已安装OpenJDK7的相关依赖%}
#### 卸载
```
rpm -e --nodeps java-1.7.0-openjdk-1.7.0.75-2.5.4.2.el7_0.x86_64
rpm -e --nodeps java-1.7.0-openjdk-headless-1.7.0.75-2.5.4.2.el7_0.x86_64
```
### 下载JDK1.8
在Oracle 选择合适的版本，进行JDK安装，这里更新至JDK1.8
**Oracle官网上下载jdk，需要点击accept licence的才能下载，使用下面的命令，直接可以下载。**
```
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u73-b02/jdk-8u73-linux-x64.tar.gz
```
### 解压
-C 表示解压路径
```
tar zxvf jdk-8u73-linux-x64.tar.gz -C /usr/local/jdk/
```
### 环境变量配置
* 修改 `/etc/profile`文件,添加如下
```
vi /etc/profile
//添加如下

JAVA_HOME=/usr/local/jdk/jdk1.8.0_73
CLASSPATH=$CLASSPATH:$JAVA_HOME/lib:.
PATH=$PATH:$JAVA_HOME/bin

export PATH
```
* 重新加载配置
```
source /etc/profile
```


## 安装 Mysql 5.7.11
### 下载
**这里更新至最新版Mysql5.7.11 源码(这里采用编译安装)**
```
wget http://cdn.mysql.com/Downloads/MySQL-5.7/mysql-5.7.11.tar.gz
```
### 解压
```
tar zxvf mysql-5.7.11.tar.gz
```
### 安装必要的包
```
yum install cmake gcc gcc-c++ ncurses-devel perl-Data-Dumper
```
### 安装Boost
```
wget http://jaist.dl.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.zip unzip boost_1_59_0.zip 
```
```
unzip boost_1_59_0.zip 
cd boost_1_59_0 
./bootstrap.sh  
./b2 
./b2 install 
```
### 生成makefile 和 编译
```
cd mysql-5.7.11
// 生成makefile
cmake .
// 编译
make
```
### 安装
```
make install

// mysql 将会安装到/usr/local/mysql路径
```
### 添加mysql用户和组
```
//创建mysql 组
sudo groupadd mysql
// 创建mysql用户 所属组为mysql
sudo useradd -r -g mysql mysql
```
### 修改目录和文件权限，安装默认数据库
```
sudo chown -R mysql.
sudo chgrp -R mysql.
bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
bin/mysql_ssl_rsa_setup 
sudo chown -R root .
sudo chown -R mysql data
```
### 创建/etc/my.cnf文件
```
cp /usr/local/mysql/support-files/my-default.cnf /etc/my.cnf
vi /etc/my.cnf
// 增加如下
```
```
server_id = 1
#binary log
log-bin = mysql-bin
binlog_format = mixed
# expire_logs_day = 30
#slow query log
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 3
log-queries-not-using-indexes
log-slow-admin-statements
# 这里忽略密码了，重设密码后，应当删除
skip-grant-tables
```
### 复制mysql服务启动脚本并加入PATH路径
```
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
vim /etc/profile
// 添加如下
```
```
PATH=/usr/local/mysql/bin:/usr/local/mysql/lib:$PATH:.
export PATH
```
```
source /etc/profile
```
### 启动Mysql 并加入开机自动启动
```
service mysqld start 
chkconfig --level 35 mysqld on
```
### 重设密码
```
mysql -uroot

//选择数据库
use mysql
// 设置密码。 5.7 相比5.5 user表中password字段改为authentication_string。如下
update user set authentication_string=PASSWORD('123456') where user='root' and host='localhost';
//更新权限表
flush privileges;
```