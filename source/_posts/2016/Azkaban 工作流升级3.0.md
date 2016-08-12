----
title: Azkaban 工作流升级3.0
date: 2016-05-27 14:06:00
categories: 
- Workflow
- Bigdata Workflow
tags:
- Workflow
- Azkaban
----


前一段时间安装部署Azkaban 2.5 版本，数据运维的童鞋在使用中，确实解决了脚本工作流（依赖）、调度、监控等问题。

* 但是Azkaban还是存在很多问题和不足
   * 不支持远程脚本调度（必须在固定的机器、没有远程登陆）
   * 创建项目不支持中文 （这个Bug一直没有修复）
   * 日志使用高级查询，通过Filter过滤时间，会出现时间格式转换异常。
   * 等等

**Azkaban 3.0 虽然没有正式推出，但可以投入使用，也希望解决一下简单问题**

Azkaban 3.0 目前只能源码安装。

* 升级Azkaban 3.0 分为如下三个步骤
   * 构建Azkaban源码，生成Zip或者Gz包
   * 导入Azkaban3.0 数据库
   * 配置启动`azkaban-web-server` 和 `azkaban-exec-server`






## 构建Azkaban 源码

你可以选择如下方式的一种

### 一个新环境下构建

**安装Linux 基础工具、Java环境、Git**
```
sudo yum groupinstall -y "Development Tools"
sudo yum install -y java-1.7.0-openjdk.x86_64 java-1.7.0-openjdk-devel.x86_64 git mysql-connector-java
```
> 如果有`Java环境 和Git`忽略如上

**编译azkaban**
```
git clone https://github.com/azkaban/azkaban.git
cd azkaban
./gradlew distZip
```
> `distZip` 构建zip文件。如果使用`distTar`表示生成tar文件。 

****






### 可能遇到的异常

**你需要多少执行，甚至需要手工编译**


* 无法更新依赖
```
FAILURE: Build failed with an exception.

* What went wrong:
A problem occurred configuring root project 'azkaban'.
> Could not resolve all dependencies for configuration ':classpath'.
   > Could not resolve net.ltgt.gradle:gradle-errorprone-plugin:0.0.8.
     Required by:
         com.linkedin:azkaban:3.0.0
      > Could not GET 'https://plugins.gradle.org/m2/net/ltgt/gradle/gradle-errorprone-plugin/0.0.8/gradle-errorprone-plugin-0.0.8.pom'.
         > peer not authenticated

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output.

BUILD FAILED

Total time: 45.497 secs
[root@test-liupengwei azkaban]# vi build.gradle 
```
> 如上是网络的原因，无法到`https://plugins.gradle.org/m2/`下载Gradle 插件

* 构建失败
```
    (see http://errorprone.info/bugpattern/WaitNotInLoop)
/root/build2/azkaban-3.0.0/azkaban-execserver/src/test/java/azkaban/execapp/event/BlockingStatusTest.java:86: warning: [WaitNotInLoop] Because of spurious wakeups, wait(long) must always be called in a loop
      wait(3000);
          ^
    (see http://errorprone.info/bugpattern/WaitNotInLoop)
/root/build2/azkaban-3.0.0/azkaban-execserver/src/test/java/azkaban/execapp/event/BlockingStatusTest.java:92: warning: [WaitNotInLoop] Because of spurious wakeups, wait(long) must always be called in a loop
      wait(1000);
          ^
    (see http://errorprone.info/bugpattern/WaitNotInLoop)
/root/build2/azkaban-3.0.0/azkaban-execserver/src/test/java/azkaban/execapp/event/BlockingStatusTest.java:111: warning: [WaitNotInLoop] Because of spurious wakeups, wait(long) must always be called in a loop
      wait(2000);
          ^
    (see http://errorprone.info/bugpattern/WaitNotInLoop)
/root/build2/azkaban-3.0.0/azkaban-execserver/src/test/java/azkaban/execapp/event/BlockingStatusTest.java:118: warning: [WaitNotInLoop] Because of spurious wakeups, wait(long) must always be called in a loop
      wait(2000);
          ^
    (see http://errorprone.info/bugpattern/WaitNotInLoop)
16 warnings
:azkaban-execserver:processTestResources UP-TO-DATE
:azkaban-execserver:testClasses
:azkaban-execserver:test

azkaban.execapp.event.BlockingStatusTest > testUnfinishedBlockSeveralChanges FAILED
    java.lang.AssertionError at BlockingStatusTest.java:100

71 tests completed, 1 failed, 40 skipped
:azkaban-execserver:test FAILED

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':azkaban-execserver:test'.
> There were failing tests. See the report at: file:///root/build2/azkaban-3.0.0/azkaban-execserver/build/reports/tests/index.html

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output.

BUILD FAILED

Total time: 15 mins 44.721 secs
```
> 如上异常是因为构建过程中部分单元测试无法通过。


### 手工 构建（Gradle）Azkaban
* 下载Gradle，并配置环境变量
   * https://services.gradle.org/distributions/gradle-2.13-all.zip
   * 环境path 下添加bin路径

* 修改build.gradle Maven数据源 （可选）
**如果下载依赖缓慢可配置**
```
buildscript {
  repositories {
   /**
    * 如下增加 jcenter()  源 或 oschain源
    */
    jcenter()  
    mavenCentral()
    maven {
      url 'https://plugins.gradle.org/m2/'
    }
  }
  dependencies {
    classpath 'com.linkedin:gradle-dustjs-plugin:1.0.0'
    classpath 'de.obqo.gradle:gradle-lesscss-plugin:1.0-1.3.3'
    classpath 'net.ltgt.gradle:gradle-errorprone-plugin:0.0.8'
  }
}

apply plugin: 'distribution'

allprojects {
  repositories {
    /**
    * 如下增加 jcenter()  源 或 oschain源
    */
    jcenter()
    mavenCentral()
    mavenLocal()
  }
}
```
* 忽略部分单元测试
**有些Unit命令无法执行,并不推荐在Window中进行Azkaban源码构建**
   * 修改`azkaban\azkaban-common\src\test\java\azkaban\jobExecutor\ProcessJobTest.java`
```

/*
  @Test
  public void testFailedUnixCommand() throws Exception {
    // Initialize the Props
    props.put(ProcessJob.COMMAND, "xls -al");

    try {
      job.run();
    } catch (RuntimeException e) {
      Assert.assertTrue(true);
      e.printStackTrace();
    }
  }
*/
/*  @Test
  public void testMultipleUnixCommands() throws Exception {
    // Initialize the Props
    props.put(ProcessJob.COMMAND, "pwd");  //window 没有pwd命令
    props.put("command.1", "date");
    props.put("command.2", "whoami");

    job.run();
  }
*/
```
   * 修改`azkaban\azkaban-common\src\test\java\azkaban\jobExecutor\PythonJobTest.java`
   **Window 构建修改，Linux构建不需要修改**
   ```
      @BeforeClass
  public static void init() {

    long time = (new Date()).getTime();
    scriptFile = "d:/tmp/azkaban_python" + time + ".py";   //选择一个window盘符
    // dump script file
    try {
      Utils.dumpFile(scriptFile, scriptContent);
    } catch (IOException e) {
      e.printStackTrace(System.err);
      Assert.fail("error in creating script file:" + e.getLocalizedMessage());
    }

  }
   ```
* 执行如下命令
```
gradle distZip --debug
```
* 构建成功
**查看：azkaban\build\distributions目录**

{%asset_img a3c3e5d8-87b1-46fc-bd60-36892b1861e1.png 安装成功文件%}

## 安装Azkaban
关于Azkaban的安装，请参考[这篇文件：Azkaban2.5安装指南](http://cmp-cc.github.io/2016/04/27/2016/%E5%A4%A7%E6%95%B0%E6%8D%AE%E5%B7%A5%E4%BD%9C%E6%B5%81%20Azkaban%20%E7%8E%AF%E5%A2%83%E6%90%AD%E5%BB%BA/)

* 不同之处，你需要使用自己编译的Azkaban3.0进行配置。 数据库导入`azkaban.sql-3.0.0.zip`中`create-all-sql-3.0.0.sql`
```
cd azkaban/build/distributions/ 
zunip azkaban-sql-3.0.0.zip
cd azkaban-sql-3.0.0
mysql -uroot -p -D azkaban2 < create-all-sql-3.0.0.sql
```
> 注意：azkaban2 数据库必须存在

* 同时你需要要执行`azkaban.sql-3.0.0.zip`中`update.active_executing_flows.3.0.sql`和`update.execution_flows.3.0.sql`文件,如果不执行，可能会出现如下异常
```
Exception in thread "main" azkaban.executor.ExecutorManagerException: Error fetching active flows
        at azkaban.executor.JdbcExecutorLoader.fetchActiveFlows(JdbcExecutorLoader.java:216)
        at azkaban.executor.ExecutorManager.loadRunningFlows(ExecutorManager.java:431)
        at azkaban.executor.ExecutorManager.<init>(ExecutorManager.java:126)
        at azkaban.webapp.AzkabanWebServer.loadExecutorManager(AzkabanWebServer.java:261)
        at azkaban.webapp.AzkabanWebServer.<init>(AzkabanWebServer.java:197)
        at azkaban.webapp.AzkabanWebServer.main(AzkabanWebServer.java:739)
Caused by: java.sql.SQLException: Unknown column 'ex.executor_id' in 'on clause' Query: SELECT ex.exec_id exec_id, ex.enc_type enc_type, ex.flow_data flow_data, et.host host, et.port port, ax.update_time axUpdateTime, et.id executorId, et.active executorStatus FROM execution_flows ex INNER JOIN  active_executing_flows ax ON ex.exec_id = ax.exec_id INNER JOIN  executors et ON ex.executor_id = et.id Parameters: []
        at org.apache.commons.dbutils.AbstractQueryRunner.rethrow(AbstractQueryRunner.java:363)
        at org.apache.commons.dbutils.QueryRunner.query(QueryRunner.java:350)
        at org.apache.commons.dbutils.QueryRunner.query(QueryRunner.java:306)
        at azkaban.executor.JdbcExecutorLoader.fetchActiveFlows(JdbcExecutorLoader.java:212)
        ... 5 more
```
```
mysql -uroot -p -D azkaban2 < update.active_executing_flows.3.0.sql
mysql -uroot -p -D azkaban2 < update.execution_flows.3.0.sql
```


其他相关步骤查看如上文章，安装过程过程大同小异。

## 可能会遇到的异常

* **解压后的`azkaban-web-server-3.0.0`和`azkaban-exec-server-3.0.0`的bin目录下的`.sh` 均没有可执行权限**
```
cd azkaban-web-server-3.0.0
chmod -R 777 bin/*.sh

// exec 同理
```
* **执行sh出现/bin/bash^M: bad interpreter: No such file or directory**
```
// 如上原因是因为使用了window构建，linux不识别此文件

vi azkaban-web-start.sh

:set ff=nuix
:wq


```