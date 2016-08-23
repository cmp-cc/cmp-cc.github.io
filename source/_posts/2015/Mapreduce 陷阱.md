----
title: Mapreduce 陷阱
date: 2015-03-17 11:51:00
updated:
categories: 

- Distributed Development
- Hadoop
tags:
- Hadoop
----
## 重复值
### 问题描述
重复使用Reduce端Iterable对象，只会得到最后一个值问题。
Mapreduce:  Reduce端,混排之后。
```
     protected void reduce(CompositeGroupKey key, Iterable<IntWritable> values,Context context) throws IOException, InterruptedException {
            Iterator<IntWritable> valueIter = values.iterator(); //多次使用，只能得到最后一个值
     }
```

**调用valueIter.next()将始终返回相同的IntWritable实例，该实例的内容替换为下一个值。所有调用valueIter.next()引用的IntWritable都将被替换。这种行为的设计只是为了减少对象创建和GC开销。（也就是说：Hadoop 推荐只使用一次循环来处理所有的结果）**

### 解决方案：
**克隆原始迭代器集合对象**
```
使用 WritableUtils.clone() 克隆你的集合对象。
```