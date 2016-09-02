----
title: Titan 数据库使用
date: 2016-08-25 19:57:00
updated:
categories: 
- Distributed Development
- Titan

tags:
- Titan
----
> 之前有小规模的使用Neo4j，Neo4j 需要商业授权，且对于大规模的分布式支持并不友好。 案例也不多。
> Titan 作为分布式图数据，构建于Elasticsearch、Hbase、Hadoop 之上， 分布式支持较好，且有部分商业案例. 主要应用:`知识图谱`、`情报分析`等。


# Titan 基本介绍

Titan是一个分布式的图数据库，支持横向扩展，可容纳数千亿个顶点和边。 Titan支持事务，并且可以支撑上千并发用户和 计算复杂图形遍历。

Titan包含下面这些特性:

* 弹性与线性扩展
* 分布式架构，可容错
* 支持多数据中心的高可用和热备
* 支持 ACID and 和最终一致性.
* 支持多种存储后端:
   * Apache Cassandra
   * Apache HBase
   * Oracle BerkeleyDB
* 支持大数据平台集成，完成图数据 分析、报表、ETL 。
   * Apache Spark
   * Apache Giraph
   * Apache Hadoop
* 支持位置、数字范围和全文检索:
   * ElasticSearch
   * Solr
   * Apache Lucene
* 原生支持 TinkerPop 软件栈:
   * Gremlin graph query language
   * Frames object-to-graph mapper
   * Rexster graph server
   * Blueprints standard graph API
* 开源协议Apache 2 license

# Titan 开发环境搭建:
* 数据存储层为：Hbase
* 数据索引层为：Elasticsearch

Titan + Hbase + Elasticsearch + Hadoop = Titan 图数据库

这里使用 Titan + CDH5.7 + Elastcisearch集群  = Titan 图数据库

> 这篇文章将详细的演示CDH + ES + Titan 构建分布式图数据库

**前置条件**
* 已经安装Java8 且配置完成环境变量
* 已经安装Elasticsearch1.5.z 或 Elasticsearch1.5.z 集群
* 已经安装Hadoop、Hbase 或 CDH 平台

> 当前ES最高版本为2.3， 但是只能使用ES1.5 版本。  详情参看： [Titan1.0 兼容表](
http://s3.thinkaurelius.com/docs/titan/1.0.0/version-compat.html)


## 下载Titan-hadoop1
现在地址：https://github.com/thinkaurelius/titan/wiki/Downloads，并查看titan-hadoop1 和titan-hadoop2 日志，现在本质并没有太大区别。 
* 服务器（这里使用为Contos）中下载Titan-hadoop1

{% asset_img d6b915a1-8d65-4714-9eee-addb84c19d5b.png titan安装文件 %}
* 解压`Titan`
```
unzip titan-1.0.0-hadoop1.zip 
```
* 运行`Gremlin 控制台`
```
./bin/gremlin.sh
```

- ---

> 提示如果使用`titan-hadoop2` 需要引入`titan-hadoop.jar`,如下：
```
cd titan-1.0.0-hadoop2
cd lib/
wget http://search.maven.org/remotecontent?filepath=com/thinkaurelius/titan/titan-hadoop/1.0.0/titan-hadoop-1.0.0.jar
```
如果没有引入`titan-hadoop.jar`,通过`./bin/gremlin.sh`启动`Gremlin 控制台`将会跑出如下异常:
```
Invalid import definition: 'com.thinkaurelius.titan.hadoop.MapReduceIndexManagement'; reason: startup failed:
script14719348643282042298222.groovy: 1: unable to resolve class com.thinkaurelius.titan.hadoop.MapReduceIndexManagement
 @ line 1, column 1.
   import com.thinkaurelius.titan.hadoop.MapReduceIndexManagement
   ^

1 error
```
```
Could not instantiate implementation: com.thinkaurelius.titan.diskstorage.hbase.HBaseStoreManager
```
## Hbase 链接测试
**使用Hbase 作为数据存储层**
* 进入`Gremlin 控制台 `./bin/gremlin.sh`
```
hBaseConf = new BaseConfiguration();
hBaseConf.setProperty("storage.backend","hbase");
hBaseConf.setProperty("storage.hostname","worker01.hadoop,worker02.hadoop,worker03.hadoop");
hBaseConf.setProperty("storage.hbase.ext.hbase.zookeeper.property.clientPort","2181");
hBaseConf.setProperty("storage.hbase.table","titan");
titanGraph = TitanFactory.open(hBaseConf);
```
> * 我们需要配置`Hbase连接地址`、`客户端端口`、`存储表`
> * 如何确定`hbase hostname地址`？  hbase 使用`zoopeeker`作为分布式协调服务。找到`hbase-site.xml`中`hbase.zookeeper.quorum`值
进入`CDH Manage`

{% asset_img 7b7f63d9-a299-4d93-8b00-46671256a153.png CDH Manager 页面 %}

{% asset_img 32641fe4-8946-4176-b9a7-3bc968ace9a1.png Hbase 配置URL %}

{% asset_img 380a7f69-ef58-4d3d-94ca-eee1fe0621e1.png zk quorum %}

* 链接成功

查看Hbase所有表，你将看到`titan`表,表示`titan`能够与hbase正常通信。


{% asset_img 86b1776f-c2e3-43e8-b7de-61e91c63118a.png hbase 整合成功 %}

## 配置`titan-hbase-es.properties`
我们只需要加载配置即可完成链接：
* 配置Hbase，作用于存储层
* 配置Elastichsearch 应用于索引层
```
storage.backend=hbase
storage.hostname=worker01.hadoop,worker02.hadoop,worker03.hadoop

index.search.backend=elasticsearch
index.search.hostname=192.168.8.14
```

## Elasticsearch，测试安装
**由于限定版本，只好重新安装一个新的ES服务器，在本地服务，并安装`head插件`**
**下载 `ES1.5.1`，并安装**

```
wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.5.1.tar.gz
tar zxvf elasticsearch-1.5.1.tar.gz
cd elasticsearch-1.5.1
// 安装head 插件
./bin/plugin -i mobz/elasticsearch-head

// 后台启动
./bin/elasticsearch -d 

```



* 如下是链接Elasticsearch 集群

```
conf = new BaseConfiguration()

conf .setProperty("storage.backend","hbase");
conf .setProperty("storage.hostname","worker01.hadoop,worker02.hadoop,worker03.hadoop");
conf .setProperty("storage.hbase.ext.hbase.zookeeper.property.clientPort","2181");
conf .setProperty("storage.hbase.table","titan");

conf.setProperty("index.search.backend","elasticsearch")
conf.setProperty("index.search.hostname", "127.0.0.1")
conf.setProperty("index.search.client-only",true)
titanGraph = TitanFactory.open(conf );
```

* 我们访问新安装的elasticsearch: 

**http://192.168.xx.xx:9200/_plugin/head ,将会发现titan 索引 **


{% asset_img 73418101-b3f8-44c8-8216-467dc3b82cb2.png es链接测试成功 %}


## 将测试成功配置参数，写在配置文件中

**编辑 `vi conf/titan-hbase-es.properties`**

```
========== Titatn Config =======

storage.backend=hbase
storage.hostname=worker01.hadoop,worker02.hadoop,worker03.hadoop
# Must use for MapR Hadoop Distributions ( Tells Titan to contact Zookeeper on port 5181 instead of 2181 )
storage.hbase.ext.hbase.zookeeper.property.clientPort=2181
storage.hbase.table = titan

cache.db-cache = true
cache.db-cache-clean-wait = 20
cache.db-cache-time = 180000
cache.db-cache-size = 0.5

index.search.backend=elasticsearch
index.search.hostname=127.0.0.1
index.search.elasticsearch.client-only=true
```
**控制台 中可以如下加载配置文件**
```
g = TitanFactory.open('conf/titan-hbase-es.properties');
```
- -----

**这里基本的环境已经搭建完毕，你可以创建点、边、属性 等等**
