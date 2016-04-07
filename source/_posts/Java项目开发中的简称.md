----
title: Java项目开发中的简称
date: 2013-02-12 14:13:00
categories: 
- 架构设计
tags:
- DDD (领域驱动设计)
- Java
----


Java项目开发中的简称，这些简称尤其应用到Java项目分层上。 传统的MVC，可以能只是三层架构。分为View、Control、Model。 有些简写的分层，在看别人代码的时候，可能一下反应不过来它是干什么的？ 这里仔细总结一下，我觉得非常有用，它使我们的代码结构更加清晰。

大部分的缩写源于： 领域模型驱动（DDD）。

大致如下缩写：
* POJO (Plain Ordinary Java Object) 简单java对象
* DAO (Data Access Object) 数据访问对象
* DTO (Data Transfer Object) 数据传输对象
* VO (View Object) 值对象
* BO (Business Object) 业务对象
* PO (Persistant Object) 持久化对象


参考了一些文章，加上自己的理解


首先要理解什么是JavaBean 、Model、Entity
* JavaBean
**JavaBean是一种规范，也即包含一组set和get方法的Java对象。Model、Entity、POJO、DTO、BO都属于JavaBean，因为他们符合这种规范。**
**JavaBean分为业务Bean和数据Bean。数据Bean其实就Entity(实体对象)，业务Bean 就是（BO 业务对象）**
* Model
**Model是MVC概念之一。也就是Model层用于存储实体对象（Entity）。Model通常 等价于Entity 用DAO层持久化对象**
* Entity
**Entity 为实体对象。你把它就做POJO、Model、JavaBean，也没人敢说你一定错误。他主要作用为数据（数据库数据）做持久化。 一旦将数据库中的一条数据存储Entity中，你把它叫做PO对象，也是对的。他只是 领域模型驱动中的概念之一**


## 简单java对象 (POJO)
普通的Java对象，对于属性一般实现了JavaBean的标准，另外还可以包含一些简单的业务逻辑(方法)。

一个POJO持久化以后就是PO
直接用它传递、传递过程中就是DTO
直接用来对应表示层就是VO

## 数据访问对象 (DAO)
* DAO 数据访问对象，主要用于封装数据库的访问，通过它可以把POJO持久化为PO，用PO组装出来VO、DTO。
* 我们还会把DAO叫做持久化层。

## 数据传输对象 (DTO)
Data Transfer Object数据传输对象
* DTO的概念是J2EE提出，主要用于分布式应用，用于服务之间的数据传输。
* 分布式应用（JSONP、RCP、RMI等 远程方法或过程调用）之间的数据传输对象使用DTO。
* 单系统中用于展示层与服务层之间的数据传输

## 值对象 (VO)
ViewObject表现层对象 （展示层）
* 主要对应界面显示的数据值对象。它包含了界面（Web、Mobile、PC）所请求的数据信息。
* VO的数据值可以是一个或多个Model的子集或交集，主要目的构成响应（Response）所要展示的内容信息。
* VO值对象会转换为JSON、XML、HTML等格式返回给请求者。


## 业务对象 (BO)
business object业务对象
* 主要作用是把业务逻辑封装为一个对象。这个对象可以包括一个或多个其它的对象。
eg:
比如一个简历，有教育经历、工作经历、社会关系等等。
我们可以把教育经历对应一个PO，工作经历对应一个PO，社会关系对应一个PO。
建立一个对应简历的BO对象处理简历，每个BO包含这些PO。
这样处理业务逻辑时，我们就可以针对BO去处理。

## 持久化对象 (PO)
* 最形象的理解就是一个PO就是数据库中的一条记录。 （好处是可以把一条记录作为一个对象处理，可以方便的转为其它对象。）



{% asset_img 2013-02-12-java.png 整体的结构图 %}


总结：
* 领域模型可以使得责任更加明确。
* 有时候避免过度设计
 不要陷入过度设计，大可不必为了设计而设计一定要在代码中区分各个对象,一句话技术是为应用服务的。

参考

http://www.blogjava.net/vip01/archive/2007/01/08/92430.html
http://b-l-east.iteye.com/blog/1142800
http://www.blogjava.net/johnnylzb/archive/2010/05/27/321968.html