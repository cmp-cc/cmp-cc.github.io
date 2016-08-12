----
title: CDH开启HA 访问HDFS
date: 2015-10-14 17:53:00
updated:
categories: 
- Distributed Development
- Hadoop

tags:
- Hadoop
----




### 常规的访问HDFS
**你可以通过如下指定`hdfs`地址访问hdfs，进行数据读写**
```
String inputDirFile = "hdfs://namenode.hadoop:8020/user/hive/warehouse/mds_crawler_inf"; 
 fs = FileSystem.newInstance(URI.create(directoryAddress.toString()),conf);
```
**如果打开HA（高可用）后，这么方式是不可行的，Hadoop集群不知道你要访问的Master节点地址是哪一个（因为有两个HDFS访问地址）**
你可以将Hadoop配置文件`core-site.xml`和`hdfs-site.xml`放到根目录下（resources）`Configuration`会自动读取文件识别配置文件中定义的Master节点。假设为`master01.hadoop:8020`和`master02.hadoop:8020`而`dfs.nameservices`为`nameservice1`。
```
<configuration>
  <property>
    <name>dfs.nameservices</name>
    <value>nameservice1</value>
  </property> 
  <property>
    <name>dfs.namenode.rpc-address.nameservice1.namenode26</name>
    <value>master01.hadoop:8020</value>
  </property>  
   <property>
    <name>dfs.namenode.rpc-address.nameservice1.namenode39</name>
    <value>master02.hadoop:8020</value>
  </property>

.....
```
当然也可以手动读取：
```
static Configuration conf = new Configuration();  
conf.addResource(ClassLoader.getSystemResourceAsStream("hdfs-site.xml"));
conf.addResource(ClassLoader.getSystemResourceAsStream("core-site.xml"));  
conf.addResource(ClassLoader.getSystemResourceAsStream("yarn-site.xml"));
```
你可以在项目中使用相对路径。
```
String inputDirFile = "/user/hive/warehouse/ods_intelligence_victim/dt=20160131"
```
此时，你需要打成Jar运行，你会发现包如下错误。
```
java.io.IOException: No FileSystem for scheme: hdfs
        at org.apache.hadoop.fs.FileSystem.getFileSystemClass(FileSystem.java:2584)
        at org.apache.hadoop.fs.FileSystem.createFileSystem(FileSystem.java:2591)
        at org.apache.hadoop.fs.FileSystem.access$200(FileSystem.java:91)
        at org.apache.hadoop.fs.FileSystem$Cache.getInternal(FileSystem.java:2630)
        at org.apache.hadoop.fs.FileSystem$Cache.getUnique(FileSystem.java:2618)
        at org.apache.hadoop.fs.FileSystem.newInstance(FileSystem.java:417)
```
解决方案：
**明确指定使用哪一个Master**
```
        conf.addResource(ClassLoader.getSystemResourceAsStream("hdfs-site.xml"));
        conf.addResource(ClassLoader.getSystemResourceAsStream("core-site.xml"));
        conf.addResource(ClassLoader.getSystemResourceAsStream("yarn-site.xml"));

        conf.set("fs.defaultFS"," hdfs://nameservice1:8020/");
        conf.set("hadoop.job.ugi", "cloudera");
        conf.set("fs.hdfs.impl", org.apache.hadoop.hdfs.DistributedFileSystem.class.getName());  
```
**并且使用绝对路径**
```
String inputDirFile = "hdfs://nameservice1:8020/user/hive/warehouse/ods_intelligence_victim/dt=20160131"
```



参考：
http://stackoverflow.com/questions/27805820/cant-access-hdfs-via-java-api-cloudera-cdh4-4-0