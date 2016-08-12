----
title: Azkaban 插件
date: 2016-05-29 19:53:00
updated:
categories: 
- Workflow
- Bigdata Workflow
tags:
- Workflow
- Azkaban
----


**Azkaban 官网只提供了2.5版本的zip，3.0 Plugin 需要手工构建，这篇文章介绍如下：**
* Azkaban 3.0 Plugin 手工构建过程
* `HDFS Browser Plugin`的安装过程

## 编译`Azkaban Plugins`
**推荐在Linux环境下进行构建**

* 安装Ant
Azkaban Plugins 使用Ant 构建，确保有Ant环境
```
yum install ant-optional  ant-junit.x86_64
```
* Clone Azkaban Plugins Resources
```
git clone https://github.com/azkaban/azkaban-plugins.git
cd azkaban-plugins-master
ant package
```
**构建输出**
```
[root@salt azkaban-plugins-master]# ant package
Buildfile: build.xml

createDist:
    [mkdir] Created dir: /root/Azkaban_Plugins/azkaban-plugins-master/dist

clean:
     [echo] Deleting generated files in dist

git.info:
     [exec] Result: 128
     [exec] Result: 128
     [echo] Git tag found to be HEAD with tag  from repo https://github.com/azkaban/azkaban-plugins.git

repo.file:

package-dep:

clean:
     [echo] Deleting generated files in dist

build:
    [mkdir] Created dir: /root/Azkaban_Plugins/azkaban-plugins-master/dist/hadoopsecuritymanager/classes
    [javac] Compiling 7 source files to /root/Azkaban_Plugins/azkaban-plugins-master/dist/hadoopsecuritymanager/classes

jars:
    [mkdir] Created dir: /root/Azkaban_Plugins/azkaban-plugins-master/dist/hadoopsecuritymanager/jars
      [jar] Building jar: /root/Azkaban_Plugins/azkaban-plugins-master/dist/hadoopsecuritymanager/jars/azkaban-hadoopsecuritymanager-.jar
.....
.....

package-jobsummary:
    [mkdir] Created dir: /root/Azkaban_Plugins/azkaban-plugins-master/dist/jobsummary/packages
    [mkdir] Created dir: /root/Azkaban_Plugins/azkaban-plugins-master/dist/jobsummary/packages/conf
    [mkdir] Created dir: /root/Azkaban_Plugins/azkaban-plugins-master/dist/jobsummary/packages/lib
    [mkdir] Created dir: /root/Azkaban_Plugins/azkaban-plugins-master/dist/jobsummary/packages/extlib
    [mkdir] Created dir: /root/Azkaban_Plugins/azkaban-plugins-master/dist/jobsummary/packages/web
     [copy] Copying 1 file to /root/Azkaban_Plugins/azkaban-plugins-master/dist/jobsummary/packages/conf
     [copy] Copying 1 file to /root/Azkaban_Plugins/azkaban-plugins-master/dist/jobsummary/packages/lib
     [copy] Copying 3 files to /root/Azkaban_Plugins/azkaban-plugins-master/dist/jobsummary/packages/lib
     [copy] Copying 2 files to /root/Azkaban_Plugins/azkaban-plugins-master/dist/jobsummary/packages/web
     [copy] Copying 1 file to /root/Azkaban_Plugins/azkaban-plugins-master/dist/jobsummary/packages
      [tar] Building tar: /root/Azkaban_Plugins/azkaban-plugins-master/dist/jobsummary/packages/azkaban-jobsummary-.tar.gz

package:

package:
    [mkdir] Created dir: /root/Azkaban_Plugins/azkaban-plugins-master/dist/packages
     [copy] Copying 12 files to /root/Azkaban_Plugins/azkaban-plugins-master/dist/packages/viewer/hdfs
     [copy] Copying 309 files to /root/Azkaban_Plugins/azkaban-plugins-master/dist/packages/jobtypes
     [copy] Copying 310 files to /root/Azkaban_Plugins/azkaban-plugins-master/dist/packages/viewer/javaviewer
      [tar] Building tar: /root/Azkaban_Plugins/azkaban-plugins-master/dist/packages/azkaban-plugins-.tar.gz

BUILD SUCCESSFUL
Total time: 1 minute 32 seconds
```
* 构建结果
**打开dist 目录查看构建结果**
```
cd dist

drwxr-xr-x 5 root root 4096 Jun 02 16:20 hadoopsecuritymanager
drwxr-xr-x 5 root root 4096 Jun 02 16:20 hadoopsecuritymanager-yarn
drwxr-xr-x 7 root root 4096 Jun 02 16:20 hdfsviewer
drwxr-xr-x 6 root root 4096 Jun 02 16:21 javaviewer
drwxr-xr-x 5 root root 4096 Jun 02 16:21 jobsummary
drwxr-xr-x 6 root root 4096 Jun 02 16:20 jobtype
drwxr-xr-x 4 root root 4096 Jun 02 16:21 packages
-rw-r--r-- 1 root root   75 Jun 02 16:20 package.version
drwxr-xr-x 7 root root 4096 Jun 02 16:21 pigvisualizer
drwxr-xr-x 5 root root 4096 Jun 02 16:21 reportal
```
> *  每一个文件包含一个`.tar.gz`文件，如`azkaban-plugins/dist/hdfsviewer/packages/azkaban-hdfs-viewer-3.0.0.tar.gz`

* 同样你可以只构建一个`Plugin`，如下
```
cd plugins/jobtype/
ant package
```


## HDFS Browser 3.0 安装

Azkaban HDFS Browser插件允许你查看HDFS 文件系统和文件类型。
默认情况下 Azkaban HDFS Browser 使用启动Linux 用户冒充用户登陆 （Linux 用户 == Hadoop HDFS 用户）。

* Azkaban `azkaban-web-server-3.0.0/conf/azkaban.properties` 配置文件 配置加载`hdfs viewer plugin`:
```
cd /usr/local/azkaban3.0/azkaban-web-server-3.0.0/conf/
vi azkaban.properties

// 增加如下
viewer.plugins=hdfs
```
* 将`viewer plugin tar` 文件移至`plugins`目录，并解压它，重命名为`hdfs`,移至`plugin/viewer`目录
plugins/viewer/hdfs/conf plugins/viewer/hdfs/lib 

```
cd /usr/local/azkaban3.0/azkaban-web-server-3.0.0/plugins/
mkdir viewer && cd viewer
cp /root/Azkaban_Plugins/azkaban-plugins-master/dist/hdfsviewer/packages/azkaban-hdfs-viewer-3.0.0.tar.gz .
tar zxvf azkaban-hdfs-viewer-3.0.0.tar.gz
mv azkaban-hdfs-viewer-3.0.0 hdfs
rm -f azkaban-hdfs-viewer-3.0.0.tar.gz
```

* 配置`conf/plugin.properites`
```
viewer.name=HDFS
viewer.path=hdfs
viewer.order=1
viewer.hidden=false
viewer.external.classpaths=extlib/
viewer.servlet.class=azkaban.viewer.hdfs.HdfsBrowserServlet

# 这里使用hadoop2.x 

hadoop.security.manager.class=azkaban.security.HadoopSecurityManager_H_2_0
azkaban.should.proxy=false
proxy.user=azkaban
proxy.keytab.location=
allow.group.proxy=false
file.max.lines=1000
```
* 将Hadoop 2.x 相关Jar 放到`extlib`目录中
```
// 当前我使用的 CDH 版本
[root@salt conf]# hadoop version
Hadoop 2.6.0-cdh5.5.2
```

{%asset_img 68b459b3-dc98-49da-a80a-848f0f8ccc66.png HDFS3.0 所需Jar%}


> 原`extlib`目录`hadoop-core-1.0.4.jar` 删除或者重命名`mv hadoop-core-1.0.4.jar hadoop-core-1.0.4.jar.bak`

* `Hadoop 2.x Securiy` 依赖 (这个是官方项目构建的Bug)
**将构建文件中`azkaban-plugins-master/dist/hadoopsecuritymanager-yarn/jars/azkaban-hadoopsecuritymanageryarn-3.0.0.jar` 加入到`lib`目录下**
```
cp /root/Azkaban_Plugins/azkaban-plugins-master/dist/hadoopsecuritymanager-yarn/jars/azkaban-hadoopsecuritymanageryarn-3.0.0.jar hdfs/lib
```
> 推荐将`plugin extlib `中的jar移至`azkaban-web/extlib`目录中,Hadoop 环境检查成功可能会找到不到`plugins extlib`目录

* 配置 Hadoop 
确保当前环境存在Hadoop环境变量`HADOOP_HOME`和`HADOOP_CONF_DIR`
```
vi /etc/profile

// 添加如下
export HADOOP_HOME=/opt/cloudera/parcels/CDH-5.5.2-1.cdh5.5.2.p0.4
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/conf
```
或者
```
vi hdfs/conf/plugin.properties

// 添加类似如下
hadoop.home=/etc/hadoop
hadoop.conf.dir=/etc/hadoop/conf
```
> 如果当前环境已经配置，无需在配置


## HDFS Browser 2.5 安装
如果你安装3.0失败，可以安装2.5版本。 显示效果一模一样

 将Hadoop 2.x 相关Jar 放到`extlib`目录中。 （不像3.0，如下即可）

{%asset_img 11f40929-8ecb-4f67-9e0c-6795f3f32c4d.png HDFS2.5 所需Jar%}


**配置成功**


{%asset_img 97579ced-061a-4780-9536-223bd9a08c2a.png 配置成功%}

## 异常处理

### Cannot get FileSystem
#### 异常信息


{%asset_img 8b9a38f6-5004-4240-a015-2d55749c3d9a.png 错误信息%}
``` java
ity.HadoopSecurityManager_H_2_0java.lang.RuntimeException: java.lang.RuntimeException: java.lang.ClassNotFoundException: Class org.apache.hadoop.security.ShellBasedUnixGroupsMapping not found
java.lang.RuntimeException: java.lang.RuntimeException: java.lang.RuntimeException: java.lang.ClassNotFoundException: Class org.apache.hadoop.security.ShellBasedUnixGroupsMapping not found
        at azkaban.viewer.hdfs.HdfsBrowserServlet.loadHadoopSecurityManager(HdfsBrowserServlet.java:138)
        at azkaban.viewer.hdfs.HdfsBrowserServlet.init(HdfsBrowserServlet.java:99)
        at org.mortbay.jetty.servlet.ServletHolder.initServlet(ServletHolder.java:440)
        at org.mortbay.jetty.servlet.ServletHolder.doStart(ServletHolder.java:263)
        at org.mortbay.component.AbstractLifeCycle.start(AbstractLifeCycle.java:50)
        at org.mortbay.jetty.servlet.ServletHandler.initialize(ServletHandler.java:736)
        at org.mortbay.jetty.servlet.Context.startContext(Context.java:140)
        at org.mortbay.jetty.handler.ContextHandler.doStart(ContextHandler.java:518)
        at org.mortbay.component.AbstractLifeCycle.start(AbstractLifeCycle.java:50)

```
#### 解决方案
* 没有找到 `plugin extlib jar` ，你可以将`extlib` 文件放置到`lib`目录或`azkaban/extlib`目录中 

### HTTP ERROR 500

点击Browser HDFS，返回服务器内部错误
#### 异常信息
```
HTTP ERROR 500
Problem accessing /hdfs. Reason:
    INTERNAL_SERVER_ERROR
Caused by:

java.lang.AbstractMethodError
	at azkaban.webapp.servlet.LoginAbstractAzkabanServlet.doGet(LoginAbstractAzkabanServlet.java:121)
	at javax.servlet.http.HttpServlet.service(HttpServlet.java:707)
	at javax.servlet.http.HttpServlet.service(HttpServlet.java:820)
	at org.mortbay.jetty.servlet.ServletHolder.handle(ServletHolder.java:511)
	at org.mortbay.jetty.servlet.ServletHandler.handle(ServletHandler.java:401)
	at org.mortbay.jetty.servlet.SessionHandler.handle(SessionHandler.java:182)
	at org.mortbay.jetty.handler.ContextHandler.handle(ContextHandler.java:766)
	at org.mortbay.jetty.handler.HandlerWrapper.handle(HandlerWrapper.java:152)
	at org.mortbay.jetty.Server.handle(Server.java:326)
	at org.mortbay.jetty.HttpConnection.handleRequest(HttpConnection.java:542)
	at org.mortbay.jetty.HttpConnection$RequestHandler.headerComplete(HttpConnection.java:928)
	at org.mortbay.jetty.HttpParser.parseNext(HttpParser.java:549)
	at org.mortbay.jetty.HttpParser.parseAvailable(HttpParser.java:212)
	at org.mortbay.jetty.HttpConnection.handle(HttpConnection.java:404)
	at org.mortbay.jetty.bio.SocketConnector$Connection.run(SocketConnector.java:228)
	at org.mortbay.jetty.security.SslSocketConnector$SslConnection.run(SslSocketConnector.java:713)
	at org.mortbay.thread.QueuedThreadPool$PoolThread.run(QueuedThreadPool.java:582)
```
#### 解决方案
参考日志你会发现： `[HadoopSecurityManager] [Azkaban] DFS name file:///`    **`HADOOP_HOME`和`HADOOP_CONF_DIR`配置失败，请检查**

