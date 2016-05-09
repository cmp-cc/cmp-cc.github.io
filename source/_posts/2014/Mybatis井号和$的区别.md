----
title: Mybatis ${}和#{} 区别
date: 2014-04-02 12:53:00
categories: 
- Java Web
- MyBatis
tags:
- MyBatis
----

这两个标示符均会出现在MyBatis XML SQL 映射文件中。

* 参照理解：
   * `#{}`  相当于 PrepareStatement 类
    **以占位符的形式进行数值传递，有效的防止SQL注入**
   * `${}` 相当于 Statement 类
    **值传递，不能能防止SQL注入**

> 需要理解JDBC中的PrepareStatement 和 Statement 的关系。

## `#{}` 占位符替换，能够防止SQL 注入问题。

如下Mapper.xml SQL映射语句。
```
<insert id="insertSample" parameterType="Sample">
     INSERT INTO SAMPLE(ID,NAME,EMAIL, TYPE) VALUES(#{Id},#{name},#{email},#{type})
</insert>
```
它将会翻译为：
```
 INSERT INTO SAMPLE(ID,NAME,EMAIL, TYPE) VALUES ?,?,?,?
```
**?会对应顺序的数值进行赋值传递，并检查数值的合法性.(这里有个预编译阶段，用于检验SQL)**

## `${}` 值传递，不能防止SQL注入
如下Mapper.xml SQL映射语句。
```
<insert id="insertSample" parameterType="Sample">
     INSERT INTO SAMPLE(ID,NAME,EMAIL, TYPE) VALUES(${Id},${name},${email},${type})
</insert>
```
它将会翻译为：
```
 INSERT INTO SAMPLE(ID,NAME,EMAIL, TYPE) VALUES 4,飞车,baiwoyidao@163.com,游戏
```
**直接的SQL生成，没有预编译阶段。**
## 建议
* 使用`#{}`替代`${}`
   * `#{}`更加安全
   * `#{}` 性能好一些（部分数据库会对预编译语句进行性能优化）