----
title: Maven3 setting.xml 设置
date: 2014-04-13 16:54:00
categories: 
- 项目构建
tags:
- Maven
----


## 不要修改setting.xml地址 和 仓库地址地址

Maven3 默认setting.xml文件地址和仓库地址为：
> C:/Users/用户名称/.m2/setting.xml
> C:/Users/用户名称/.m2/repository

**你可能觉得仓库地址在C盘有点不合理，它在我指定的目录不是更好吗？  例如：D:/Work-Repository/Maven-Repository**

于是：
* 你复制setting.xml 文件到 D:/Work-Repository/Maven-Repository
* 修改setting.xml Maven仓库
```
<localRepository>D:/Work-Repository/Mvn-Repository</localRepository>
```
* 修改STS/IDEA/MyEclipse 中的setting.xml 地址
* OK，你成功。

但是：
**你可能忘了你有多个工作目录。偶尔你新建一个工作目录，忘了改setting.xml
糟糕的事情发生了**
* 为什么还要重复下载Jar？
* 八嘎！ 为什么两个仓库都在用啊~~   恍然大悟！！

## 修改你的镜像地址
国外的源总是缓慢的，比如：
> http://my.repository.com/repo/path

使用OSChina Maven仓库，如下配置：
```
  <mirrors>

    <mirror>
      <id>mirrorId</id>
      <mirrorOf>repositoryId</mirrorOf>
      <name>Human Readable Name for this Mirror.</name>
      <url>http://my.repository.com/repo/path</url>
    </mirror>
    
  </mirrors>
```
> 提示，OSChina源也有不好使的地方，比如：引入嵌入式数据库： H2，它就找不到，这个时候，你需要切换到其他源或在pom.xml 指定下载源地址。

## 想到了，日后再更新。






