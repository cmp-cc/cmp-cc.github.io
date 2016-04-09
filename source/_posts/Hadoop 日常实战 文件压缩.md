----
title: Hadoop 日常实战 文件压缩
date: 2014-12-28 19:25:00
categories: 
- 大数据开发
tags:
- Hadoop
----


Mapreduce 程序执行可以分为三个阶段：
1、Mapper 阶段
**从HDFS中读取数据源，将计算结果写入HDFS**
2、Suffle与排序阶段
**从HDFS中读取Mapper阶段结果数据，并进行混排操作（Suffle与排序），并将结果数据传递给Reducer**
3、Reducer阶段
**Reducer接受数据，再将计算结果写入HDFS或其它**
> 这里我忽略combiner阶段。 因为combiner阶段只是一步优化操作，不属于Mapreduce模型中的核心。

如上可知，执行Mapreduce程序一共需要两次文件的读入和写入。  如果增加文件压缩，将大大提高程序的运行效率。

## Hadoop 支持的压缩算法

### 内置压缩算法
优势：
* 它减少了存储文件所需的空间；
* 加快了数据在网络上或者从磁盘上或到磁盘上的传输速度；
hadoop对于压缩格式的是透明识别,我们的MapReduce任务的执行是透明的，hadoop能够自动为我们 将压缩的文件解压，而不用我们去关心。 hadoop就会根据扩展名去选择解码器解压。当压缩文件做为mapreduce的输入时，mapreduce将自动通过扩展名找到相应的codec对其解压。

**主流的压缩格式：**

压缩格式|	工具	|算法	|文件扩展名	| 多文件	|是否可切分|	HadoopCompressionCodec
--- |    --- |    --- |   --- | --- | --- | ---
DEFLATE	|无|	DEFLATE	|.deflate	|否|	否	|org.apache.hadoop.io.compress.DefaultCodec
Gzip	|gzip	|DEFLATE|	 .gz	| 否|	否	|org.apache.hadoop.io.compress.GzipCodec
bzip2	|bzip2|	bzip2|	.bz2	| 否|	是	|org.apache.hadoop.io.compress.BZip2Codec
LZO	 |lzop	|LZO	|.lzo	| 否|	是（需要索引）|	com.hadoop.compression.lzo.LzopCodec
Snappy	|N/A|	Snappy	|.Snappy	|否	|否|	org.apache.hadoop.io.compress.SnappyCodec
LZ4	|N/A	|LZ4	|.lz4	|否|	否|	org.apache.hadoop.io.compress.Lz4Codec

压缩算法比较
	主要是时间比较与空间比较。

1）GZIP的压缩率最高，但是其实CPU密集型的，对CPU的消耗比其他算法要多，压缩和解压速度也慢；
2）LZO的压缩率居中，比GZIP要低一些，但是压缩和解压速度明显要比GZIP快很多，其中解压速度快的更多；
3）Zippy/Snappy的压缩率最低，而压缩和解压速度要稍微比LZO要快一些。

### LZO 算法引入Hadoop
上述压缩格式类型。 除lzo 格式需要另外下载。MR2 均内置上述格式。
Lzo下载地址： https://github.com/twitter/hadoop-lzo 
Lzo 本身不支持切分(splitable) 但是我们可以增加索引，即可支持切分
Hadoop的Lzo代码库中有索引工具。（DistributedLzoIndexer）	
请参照：
https://github.com/twitter/hadoop-lzo/blob/master/src/test/java/com/hadoop/mapreduce/TestLzoTextInputFormat.java

**如果希望reduce输出的是lzo格式的文件，添加下面的语句**
```
FileOutputFormat.setCompressOutput(job, true);
FileOutputFormat.setOutputCompressorClass(job, LzopCodec.class);
int result = job.waitForCompletion(true) ? 0 : 1;
//上面的语句执行完成后，会生成最后的输出文件，需要在此基础上添加lzo的索引
LzoIndexer lzoIndexer = new LzoIndexer(conf);
lzoIndexer.index(new Path(args[1]));
```

如果已经存在lzo文件，但没有添加索引，可以采用下面的方法，在输入路径的文件上上添加lzo索引
```
hadoop jar $HADOOP_HOME/lib/hadoop-lzo-0.4.17.jar com.hadoop.compression.lzo.LzoIndexer hdf://inputpath
```



## 压缩分片的最重要性
**理解分片(splitable)的价值:**
* 支持分片是很有用的。
**如： 在HDFS上有一个1G的文件。按照HDFS块(block)的设置大小进行文件划分(默认64M)。 那么就会被划分为16个数据块。**
   * 支持分片：运行这个Mapreduce作业，就会对应16个Map。
   * 不支持分片：运行这个Mapreduce作业，只能对应1个Map。
* 为什么？Hadoop又是怎么判断文件是否支持分片？对程序有什么影响？
   * 1、支持分片，就意味着支持压缩数据流的任意位置读取数据。
   * 2、Hadoop 则是通过文件后缀名来判断所属的文件是否支持分片。
   * 3、牺牲数据本地性优势： 1个Map任务要处理16个HDFS块，而且损失了数据本地化优化特性(执行Map任务与HDFS数据位于同一个节点上)。 而且map的任务越少，就意味着执行的时间越长。


## MapReduce 中使用压缩。
**在MapReduce中使用压缩是简单的。 我们通常有两种方式。**
### 代码方式：
```
// Map端输出压缩：
conf.setBoolean("mapred.compress.map.output", true);  
conf.setClass("mapred.map.output.compression.codec",GzipCodec.class, CompressionCodec.class);
// Reduce 端输出压缩
conf.setBoolean("mapred.out.compress",true);
conf.setClass("mapred.output.compression.codec",SnappyCodec.class,CompressionCodec.class);	

/ /或者

FileOutputFormat.setCompressOutput(job, true);  
FileOutputFormat.setOutputCompressorClass(job, SnappyCodec.class);  

```
### 配置文件：
找到mapred-site.xml文件。  如： 我公司集群环境配置。
Map端输出压缩配置：  我希望Map段输出压缩，并使用Snappy算法压缩
```
<property>
    <name>mapred.compress.map.output</name>
    <value>true</value>
</property>
 <property>
    <name>mapred.map.output.compression.codec</name>
    <value>org.apache.hadoop.io.compress.SnappyCodec</value>
</property>
/*Reduce端输出压缩配置： 我不希望Reduce的输出文件进行压缩。所以使用默认*/
  <property>
    <name>mapred.output.compress</name>
    <value>false</value>
</property>
  <property>
    <name>mapred.output.compression.codec</name>
    <value>org.apache.hadoop.io.compress.DefaultCodec</value>
</property>
```
>提示： 如果使用的CDH版本，按照Cloudera官网的Hadoop配置，默认配置了Mapper阶段进行文件压缩。

## 项目实战运用

**如下是参考的一篇博客的介绍，并非个人实战经验，有待验证**

项目中使用clearspring公司开源的基数估计的概率算法：stream-lib，用于解决去重计算问题，如UV计算等，它的特点在于：
* 一个UV的计算，可以限制在一个固定大小的位图空间内完成（不同大小，对应不同的误差率），如8K，64K；
* 不同的位图可以进行合并操作，得到合并后的UV。
当系统中维护的位图越多的时候，不管是在内存中，还是在存储系统（MySQL、HBase等）中，都会占用相当大的存储空间。因此，需要考虑采取合适的算法来压缩位图。这里分为以下两类情况：
* 当位图在内存中时，此时压缩算法的选择，必须有尽可能快的压缩和解压速度，同时不能消耗过多CPU资源，因此，适合使用LZO或Snappy这样的压缩算法，做到快速的压缩和解压；
* 当位图存储到DB中时，更关注的是存储空间的节省，要有尽可能高的压缩率，因此，适合使用GZIP这样的压缩算法，同时在从内存Dump到DB的过程也可以减少网络IO的传输开销。


