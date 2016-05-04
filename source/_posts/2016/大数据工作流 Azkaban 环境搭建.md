----
title: 大数据工作流 Azkaban 环境搭建
date: 2016-04-27 20:55:00
categories: 
- Workflow
- Bigdata Workflow
tags:
- Workflow
- Azkaban
----


大数据运维的同学Python、Shell脚本泛滥，且依赖混乱，不易管理。 需要符合自身要求的任务调度系统，来减轻痛苦~~。

之前调研了Oozie、AzkaBan、Airflow、Luigi 评估了一下诉求，选择AzkaBan。

这篇文章将演示如何在一个全新的Linux(CentOS)环境安装Azkaban。


## Azkaban 介绍
LinkedIn/Azkaban 为解决Hadoop的任务依赖问题。

* 它有三个重要组件：
   * 关系数据库（目前仅支持mysql）
   * web管理服务器－AzkabanWebServer
   * 执行服务器－AzkabanExecutorServer


{% asset_img d82665b7-7a34-4272-ac43-6beaf6546f68.png azkaban组件%}

### Mysql
Azkaban使用MySQL来存储它的状态信息，Azkaban Executor Server和Azkaban Web Server均使用到了MySQL数据库。

* AzkabanExecutorServer在如下几个方面使用到了数据库：
1、获取project的信息
2、执行工作流
3、存储工作流运行日志

* AzkabanWebServer在如下几个方面使用到了数据库：
1、Project管理
2、跟踪工作流执行进度
3、访问历史工作流的运行信息
4、定时执行工作流任务

### AzkabanWebServer
AzkabanWebserver是整个Azkaban工作流系统的主要管理者，它负责project管理、用户登录认证、定时执行工作流、跟踪工作流执 行进度等一系列任务。同时，它还提供Web服务操作的接口，利用该接口，用户可以使用curl或其他ajax的方式，来执行azkaban的相关操作。操 作包括：用户登录、创建project、上传workflow、执行workflow、查询workflow的执行进度、杀掉workflow等一系列操 作，且这些操作的返回结果均是json的格式。


### AzkabanExecutorServer
之所以将AzkabanWebServer和AzkabanExecutorServer分开，主要是因为在某个任务流失败后，可以更方便的将重新执行。而且也更有利于Azkaban系统的升级。


## Azkaban 开始

* solo server mode：
**最简单的模式，数据库内置的H2数据库，且webServer和executorServer运行在同一个进程中，没有单独分开。该模式适用于小规模的使用。**
* two server mode：
**该模式使用MySQL数据库，webServer和executorServer运行在不同进程中，webServer和executorServer互不影响，该模式适用于大规模应用。**
* multiple executor mode：
**该模式下，执行服务器和管理服务器在不同主机上，且执行服务器可以有多**

## Azkaban 安装

Azkaban2 仅仅只用Mysql 作为数据存储
### 安装JDK1.8
[参考安装JDK1.8 安装](http://cmp-cc.github.io/2014/11/07/2014/Linux%20%E5%BC%80%E5%8F%91%E7%8E%AF%E5%A2%83%E5%AE%89%E8%A3%85%E6%8C%87%E5%8D%97/)
### 安装Mysql
[参考安装Mysql5.7.11 ](http://cmp-cc.github.io/2014/11/07/2014/Linux%20%E5%BC%80%E5%8F%91%E7%8E%AF%E5%A2%83%E5%AE%89%E8%A3%85%E6%8C%87%E5%8D%97/)
#### 创建数据库
##### **创建Azkaban数据库**
```
CREATE DATABASE azkaban;
```
##### **创建数据库用户于Azkaban**
如下：
* 用户名:azkaban
* 地址：localhost
* 密码：azkaban
```
CREATE USER 'azkaban'@'localhost' IDENTIFIED BY 'azkaban' PASSWORD EXPIRE;
```
##### **设置权限于Azkaban 用户**
**这里执行如下，给予所有权限**
```
grant all privileges on azkaban.* to 'azkaban'@'localhost' identified by 'azkaban';
```
**也可以如下限定访问权限**
```
GRANT SELECT,INSERT,UPDATE,DELETE ON azkaban.* TO 'azkaban'@'localhost' identified by 'azkaban';
```
**配置数据包大小，修改属性`max_allowed_packet`值为`1024M`或者更高**
* 编辑`/etc/my.cnf`文件，增加如下
```
vi /etc/my.cnf

[mysqld]
...
max_allowed_packet=2048M
```
* 重启 mysql
```
service mysql restart
```
##### 创建Azkaban 表
* 首先下载[`azkaban-sql-script`](http://azkaban.github.io/downloads.html)压缩文件，这个档案包含在表创建脚本。
* 从下载页面选择合适版本进行下载。(这里选择最新版azkaban-sql-script-2.5.0.tar.gz)
```
wget –no-check-certificate https://s3.amazonaws.com/azkaban2/azkaban2/2.5.0/azkaban-sql-script-2.5.0.tar.gz
```
**create-all-sql 脚本包含所有单条语句,忽略所有`update`前缀的脚本**
* 解压并导入azkaban DB
```
tar zxvf azkaban-sql-script-2.5.0.tar.gz

mysql -u root -p azkaban < /user/cmp-cc/azkaban-2.5.0/create-all-sql-2.5.0.sql 

// 提示你输入密码即可
```
* 检查是否创建成功
```
mysql> show tables;
+------------------------+
| Tables_in_azkaban      |
+------------------------+
| active_executing_flows |
| active_sla             |
| execution_flows        |
| execution_jobs         |
| execution_logs         |
| project_events         |
| project_files          |
| project_flows          |
| project_permissions    |
| project_properties     |
| project_versions       |
| projects               |
| properties             |
| schedules              |
| triggers               |
+------------------------+
```

### 安装 Azkaban Web Server
Azkaban Web Server 处理项目管理、身份验证、调度和触发器的执行。

#### 安装 Web Server
* 选择合适的版本，[下载页面](http://azkaban.github.io/downloads.html)。  
* 你也以可以[`git clone 最新版`](https://github.com/azkaban/azkaban2),查看文档，[如何进行源码安装](http://azkaban.github.io/azkaban/docs/latest/#building-from-source)
* 这里为`azkaban-web-server-2.5.0.tar.gz`
```
wget –no-check-certificate https://s3.amazonaws.com/azkaban2/azkaban2/2.5.0/azkaban-web-server-2.5.0.tar.gz
```
* 解压到指定目录
```
mkdir -p /usr/local/azkaban/

tar zxvf azkaban-web-server-2.5.0.tar.gz -C /usr/local/azkaban/

```
* 相关目录描述

Folder | Description
--- | ---
bin  |The scripts to start Azkaban jetty server
conf |  The configurations for Azkaban solo server
lib | The jar dependencies for Azkaban
extlib |  Additional jars that are added to extlib will be added to Azkaban's classpath
plugins | the directory where plugins can be installed
web  |The web (css, javascript, image) files for Azkaban web server.

* `conf`目录，有如下三个文件
   * azkaban.properties - Used by Azkaban for runtime parameters
   * global.properties - Global static properties that are passed as shared properties to every workflow and job.
   * azkaban-users.xml - Used to add users and roles for authentication. This file is not used if the XmLUserManager is not set up to use it.

The `azkaban.properties` file will be the main configuration file that is necessary to setup Azkaban.

#### 获取SSL KeyStore（可选）
Azkaban 使用`SSL socket` 链接器,设置SSL可以通过使用`https://` 访问页面，使其更加安全。
**SSL 并是必须的，我们可以通过`azkaban.properties`配置取消，请参考SSL配置**

##### 创建SSL 配置
**这里keytool 是JDK提供，并将其密钥生成或复制于`/azkaban/web`目录**
```
cd /usr/local/azkaban/azkaban-web-2.5.0/web/

keytool -genkey -keystore keystore -alias keystore -keyalg RSA
```
将有如下提示，密码长度 >= 6 (这里为:password)
```
Enter keystore password:  
Re-enter new password: 
What is your first and last name?
  [Unknown]:  azkaban
What is the name of your organizational unit?
  [Unknown]:  Jetty
What is the name of your organization?
  [Unknown]:  cmp-cc
What is the name of your City or Locality?
  [Unknown]:  WuHan
What is the name of your State or Province?
  [Unknown]:  WuHan
What is the two-letter country code for this unit?
  [Unknown]:  86
Is CN=azkaban, OU=Jetty, O=cmp-cc, L=WuHan, ST=WuHan, C=86 correct?
  [no]:  yes

Enter key password for <jetty-azkaban>
        (RETURN if same as keystore password):             // 这里回车即可

```
#### 配置`azkaban.properties`文件
 修改`./conf/azkaban.properties`文件,进行如下修改
```
vi /usr/local/azkaban/azkaban-web-2.5.0/conf/azkaban.properties
```
**我的完整配置信息，邮件通知自己配置即可**

```
#Azkaban Personalization Settings
azkaban.name=Test
azkaban.label=My Local Azkaban
azkaban.color=#FF3601
azkaban.default.servlet.path=/index
web.resource.dir=web/
default.timezone.id=Asia/Shanghai

#Azkaban UserManager class
user.manager.class=azkaban.user.XmlUserManager
user.manager.xml.file=conf/azkaban-users.xml

#Loader for projects
executor.global.properties=conf/global.properties
azkaban.project.dir=projects

database.type=mysql
mysql.port=3306
mysql.host=localhost
mysql.database=azkaban
mysql.user=azkaban
mysql.password=azkaban
mysql.numconnections=100

# Velocity dev mode
velocity.dev.mode=false

# Azkaban Jetty server properties.
jetty.maxThreads=25
jetty.ssl.port=8443
jetty.port=8081
jetty.keystore=web/keystore
jetty.password=password
jetty.keypassword=password
jetty.truststore=web/keystore
jetty.trustpassword=password

# Azkaban Executor settings
executor.port=12321

# mail settings
mail.sender=
mail.host=
job.failure.email=
job.success.email=

lockdown.create.projects=false

cache.directory=cache
```
##### SSL 密钥配置
修改`jetty.xxxx`信息为keystore 设置，类似如下：
* 如果已经生成keystore SSL文件，如下配置
```
# Azkaban Jetty server properties.
jetty.maxThreads=25
jetty.ssl.port=8443
jetty.port=8081
jetty.keystore=web/keystore
jetty.password=password
jetty.keypassword=password
jetty.truststore=web/keystore
jetty.trustpassword=password
```
* 取消SSL 设置
```
jetty.maxThreads=25
jetty.port=8081
jetty.use.ssl=false

#jetty.ssl.port=8443
#jetty.keystore=web/keystore
#jetty.password=keystore
#jetty.keypassword=keystore
#jetty.truststore=web/keystore
#jetty.trustpassword=keystore
```
##### DB 设置
* 将MySQL数据库链接添加至`extlib`
```
cd /usr/local/azkaban/azkaban-web-2.5.0/extlib
wget http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.38/mysql-connector-java-5.1.38.jar
```
确保`mysql jdbc连接器`已经添加到`extlib`目录,配置大致如下
```
database.type=mysql
mysql.port=3306
mysql.host=localhost
mysql.database=azkaban
mysql.user=azkaban
mysql.password=azkaban
mysql.numconnections=100
```
##### UserManager 设置
Azkaban 使用`UserManager`支持用户认证和用户角色
默认：Azkaban使用`XmlUserManager`从`azkaban-users.xml`获取用户名、密码、角色信息。
```
user.manager.class=azkaban.user.XmlUserManager
user.manager.xml.file=conf/azkaban-users.xml
```
##### jetty运行设置
```
jetty.maxThreads=25
jetty.ssl.port=8443
```


#### Azkaban-web 运行和关闭
* start AzkabanWebServer.
```
bin/azkaban-web-start.sh
```
* shutdown AzkabanWebServer
```
bin/azkaban-web-shutdown.sh
```
* 浏览器端口
   * 设置SSL=true  默认访问： https://192.168.xx.xxxx:8443
   * 设置SSL=false 默认访问： http://192.168.xx.xxxx:8081

> SSL 是可以关闭的，azkaban.properties 文件中添加`jetty.use.ssl=false` 


**运行Azkaban-web 并访问浏览器验证是否成功**
> 记得关闭防火墙，或开放8443 和 8010 端口


### 安装 Azkaban Executor Server
**Azkaban Executor Server** 处理工作流和作业的实际执行。

#### 安装Executor Server
* [下载页面选择版本](http://azkaban.github.io/downloads.html) 与 Azkaban-Web 保持一致。
* 你也以可以[`git clone 最新版`](https://github.com/azkaban/azkaban2),查看文档，[如何进行源码安装](http://azkaban.github.io/azkaban/docs/latest/#building-from-source)
* 这里是下载`azkaban-executor-server-2.5.0.tar.gz`
```
wget –no-check-certificate  https://s3.amazonaws.com/azkaban2/azkaban2/2.5.0/azkaban-executor-server-2.5.0.tar.gz
```
* 解压到指定目录
```
tar zxvf azkaban-executor-server-2.5.0.tar.gz -C /usr/local/azkaban/
```
* 相关目录描述
Folder | Description
--- | ---
bin | The scripts to start Azkaban jetty server
conf  | The configurations for Azkaban solo server
lib | The jar dependencies for Azkaban
extlib   | Additional jars that are added to extlib will be added to Azkaban's classpath
plugins | the directory where plugins can be installed

#### 配置`azkaban.properties`文件
**修改`./conf/azkaban.properties`文件,进行如下修改**

**我的配置文件**
```
default.timezone.id=Asia/Shanghai

# Azkaban JobTypes Plugins
azkaban.jobtype.plugin.dir=plugins/jobtypes

#Loader for projects
executor.global.properties=conf/global.properties
azkaban.project.dir=projects

database.type=mysql
mysql.port=3306
mysql.host=localhost
mysql.database=azkaban
mysql.user=azkaban
mysql.password=azkaban
mysql.numconnections=100

# Azkaban Executor settings
executor.maxThreads=50
executor.port=12321
executor.flow.threads=30

```

##### 设置DB
* 将MySQL数据库链接添加至`extlib` 可重新下载，如下
```
cd /usr/local/azkaban/azkaban-executor-2.5.0/extlib/
wget http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.38/mysql-connector-java-5.1.38.jar
```
* DB设置(覆盖azkaban.properties)
**如下：**
```
database.type=mysql
mysql.port=3306
mysql.host=localhost
mysql.database=azkaban
mysql.user=azkaban
mysql.password=azkaban
mysql.numconnections=100
```
##### 配置AzabanWebServer 和 AzkabanExecutorServer 
**Executor server 需要一个端口，Web server 需要知道这个端口，使用如下默认即可**
```
# Azkaban Executor settings
executor.maxThreads=50
executor.port=12321
executor.flow.threads=30
```

#### 运行和关闭
* 运行AzkabanExecutorServer
```
bin/azkaban-exec-start.sh
```
* 关闭 AzkabanExecutorServer
```
bin/azkaban-exec-shutdown.sh
```
**这里所有Azkaban 环境已经安装完毕，你需要启动azkaban-web 和 azkaban-executor 进行工作流管理（作业调度）**

