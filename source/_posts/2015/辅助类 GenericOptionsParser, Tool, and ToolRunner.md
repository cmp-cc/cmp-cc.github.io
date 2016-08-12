----
title: 辅助类 GenericOptionsParser, Tool, and ToolRunner
date: 2015-03-26 22:53:00
updated:
categories: 
- Distributed Development
- Hadoop
tags:
- Hadoop
----

## 辅助类 GenericOptionsParser, Tool, and ToolRunner

Hadoop提供了几个辅助类,使其更容易从命令行运行作业。
GenericOptionsParser 用来解释一些常用的命令选项，还可以根据需要为Configuration对象设置相应的值，但是通常不直接使用
GenericOptionsParser，而是更方便的：实现Tool接口，通过Tool来运行应用程序，ToolRunner内部调用GenericOptionsParser 。

```
public interface Tool extends Configurable {
  int run(String [] args) throws Exception;
}

```
一个Tool实现，打印Tool的Configuration 配置属性
```
public class ConfigurationPrinter extends Configured implements Tool {
  /**
     * 1、interface Tool extends Configurable   Tool 继承于Configurable
     * 2、Configured 是Tool接口的最小实现方式。
     * 3、run() 方法通过Configurable的getConf()方法获取Configuration,然后重复执行，将每个属性打印到标准输出
     */  
  static {
    Configuration.addDefaultResource("hdfs-default.xml");
    Configuration.addDefaultResource("hdfs-site.xml");
    Configuration.addDefaultResource("yarn-default.xml");
    Configuration.addDefaultResource("yarn-site.xml");
    Configuration.addDefaultResource("mapred-default.xml");
    Configuration.addDefaultResource("mapred-site.xml");
  }

  @Override
  public int run(String[] args) throws Exception {
    Configuration conf = getConf();
    for (Entry<String, String> entry: conf) {
      System.out.printf("%s=%s\n", entry.getKey(), entry.getValue());
    }
    return 0;
  }
  
  public static void main(String[] args) throws Exception {
        /**
         * ToolRunner 
         * 1、在调用run方式之间，会为Tool建立一个Configuration对象
         * 2、它还是用GenericOptionsParser来获取命令行中指定的任何标准选项，然后在Configuration实例中进行设置
         * 3、查看某个属性的设置
         *     hadoop jar ConfigurationPrinter.jar -conf conf/mapred-site.xml | grep fs.s3.buffer.dir
             权威指南:
              mvn compile
              export HADOOP_CLASSPATH=target/classes/
                hadoop ConfigurationPrinter -conf conf/hadoop-localhost.xml | grep yarn.resourcemanager.address=
         */  
    int exitCode = ToolRunner.run(new ConfigurationPrinter(), args);
    System.exit(exitCode);
  }
}
```
执行hadoop jar ConfigurationPrinter.jar输出结果如下：

```
dfs.datanode.data.dir=file://${hadoop.tmp.dir}/dfs/data
dfs.namenode.checkpoint.txns=1000000
s3.replication=3
mapreduce.output.fileoutputformat.compress.type=BLOCK
mapreduce.jobtracker.jobhistory.lru.cache.size=5
dfs.datanode.failed.volumes.tolerated=0
hadoop.http.filter.initializers=org.apache.hadoop.http.lib.StaticUserWebFilter
mapreduce.cluster.temp.dir=${hadoop.tmp.dir}/mapred/temp
mapreduce.reduce.shuffle.memory.limit.percent=0.25
yarn.nodemanager.keytab=/etc/krb5.keytab
dfs.namenode.checkpoint.max-retries=3
dfs.https.server.keystore.resource=ssl-server.xml
mapreduce.reduce.skip.maxgroups=0
dfs.domain.socket.path=/var/run/hdfs-sockets/dn
hadoop.http.authentication.kerberos.keytab=${user.home}/hadoop.keytab
yarn.nodemanager.localizer.client.thread-count=5
ha.failover-controller.new-active.rpc-timeout.ms=60000
mapreduce.framework.name=yarn
ha.health-monitor.check-interval.ms=1000
io.file.buffer.size=65536
dfs.namenode.checkpoint.period=3600
mapreduce.task.tmp.dir=./tmp
ipc.client.kill.max=10
yarn.resourcemanager.scheduler.class=org.apache.hadoop.yarn.server.resourcemanager.scheduler.fifo.FifoScheduler
mapreduce.jobtracker.taskcache.levels=2
s3.stream-buffer-size=4096
.....
....
....
```

执行 
hadoop jar ConfigurationPrinter.jar -conf conf/mapred-site.xml | grep fs.s3.buffer.dir 输出如下
```
fs.s3.buffer.dir=${hadoop.tmp.dir}/s3
```
通过GenericOptionsParser 设置个别属性
```
hadoop jar hadoop4v1.jar -D color=yellow | grep color
/**
结果如下： -D的优先级高于配置文件里的其他属性。 可以使用-D 覆盖它，
如： -D mapreduce.job.reduces=n 设置Mapreduce作业中的reduce数量
*/

```
## GenericOptionsParser 选项与 ToolRunner选项

{%asset_img 57106921-dd6d-41a9-a00e-92fa5b30a411.png 选项参数%}