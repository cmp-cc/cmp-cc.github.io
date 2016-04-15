----
title: MyBatis Boostrap 
date: 2014-04-02 10:44:00
categories: 
- Java Web
tags:
- Mybatis
----


SqlSessionFactory 是MyBatis的核心对象，用于获取SqlSession，并执行映射的 SQL 语句。
可以通过基于 XML 的配置信息或者 Java API 创建。

我们将探索各种 MaBatis 配置元素，如 dataSource，environments,全局参数设置,typeAlias，typeHandlers，
SQL 映射；接着我们将实例化 SqlSessionFactory。

* 使用 XML 配置 MyBatis
* 使用 Java API 配置 MyBatis
* 自定义 MyBatis 日志

## 使用 XML 配置 MyBatis
**构建 SqlSessionFactory 最常见的方式是基于 XML 配置（的构造方式）。下面的 mybatis-config.xml 展示了一个
典型的 MyBatis 配置文件的样子：**
```
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
	<properties resource="application.properties">
		<property name="username" value="db_user" />
		<property name="password" value="verysecurepwd" />
	</properties>
	<settings>
		<setting name="cacheEnabled" value="true" />
	</settings>
	<typeAliases>
		<typeAlias alias="Tutor" type="com.mybatis3.domain.Tutor" />
		<package name="com.mybatis3.domain" />
	</typeAliases>
	<typeHandlers>
		<typeHandler handler="com.mybatis3.typehandlers. PhoneTypeHandler" />
		<package name="com.mybatis3.typehandlers" />
	</typeHandlers>
	<environments default="development">
		<environment id="development">
			<transactionManager type="JDBC" />
			<dataSource type="POOLED">
				<property name="driver" value="${jdbc.driverClassName}" />
				<property name="url" value="${jdbc.url}" />
				<property name="username" value="${jdbc.username}" />
				<property name="password" value="${jdbc.password}" />
			</dataSource>
		</environment>
		<environment id="production">
			<transactionManager type="MANAGED" />
			<dataSource type="JNDI">
				<property name="data_source" value="java:comp/jdbc/MyBatisDemoDS" />
			</dataSource>
		</environment>
	</environments>
	<mappers>
		<mapper resource="com/mybatis3/mappers/StudentMapper.xml" />
		<mapper url="file:///D:/mybatisdemo/mappers/TutorMapper.xml" />
		<mapper class="com.mybatis3.mappers.TutorMapper" />
	</mappers>
</configuration>
```
**下面让我们逐个讨论上述配置文件的组成部分**

### environment (环境)

MyBatis 支持配置多个 dataSource 环境，可以将应用部署到不同的环境上， DEV(开发环境)，如TEST（测试换将），
QA（质量评估环境）,UAT(用户验收环境),PRODUCTION（生产环境），可以通过将默认 environment 值设置成想要的
environment id 值。
在上述的配置中，默认的环境 environment 被设置成 development。当需要将程序部署到生产服务器上时，你不需
要修改什么配置，只需要将默认环境 environment 值设置成生产环境的
明细；使用 REPORTS 数据库存储订单明细的合计，用作报告。
如果你的应用需要连接多个数据库，你需要将每个数据库配置成独立的环境，并且为每一个数据库创建一个
SqlSessionFactory。
```
<environments default="shoppingcart">
	<environment id="shoppingcart">
		<transactionManager type="MANAGED" />
		<dataSource type="JNDI">
			<property name="data_source" value="java:comp/jdbc/ ShoppingcartDS" />
		</dataSource>
	</environment>
	<environment id="reports">
		<transactionManager type="MANAGED" />
		<dataSource type="JNDI">
			<property name="data_source" value="java:comp/jdbc/ReportsDS" />
		</dataSource>
	</environment>
</environments>
```
**我们可以通过如下，为每一个环境创建一个SqlSessionFactory**
```
inputStream = Resources.getResourceAsStream("mybatis-config.xml");
defaultSqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
cartSqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream, "shoppingcart");
reportSqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream, "reports");
```

创建 SqlSessionFactory 时，如果没有明确指定环境 environment id，则会使用默认的环境 environment 来创
建。在上述的源码中，默认的 SqlSessionFactory 便是使用 shoppingcart 环境设置创建的。
对于每个环境 environment,我们需要配置 dataSource 和 transactionManager 元素。

### DataSource (数据源)
dataSource 元素被用来配置数据库连接属性。
```
<dataSource type="POOLED">
	<property name="driver" value="${jdbc.driverClassName}" />
	<property name="url" value="${jdbc.url}" />
	<property name="username" value="${jdbc.username}" />
	<property name="password" value="${jdbc.password}" />
</dataSource>
```
dataSource 的类型可以配置成其内置类型之一，如 UNPOOLED，POOLED，JNDI。

* 如果将类型设置成 UNPOOLED，MyBatis 会为每一个数据库操作创建一个新的连接，并关闭它。该方式适用于只有小规模数量并发用户的简单应用程序上。
* 如果将属性设置成 POOLED，MyBatis 会创建一个数据库连接池，连接池中的一个连接将会被用作数据库操作。一旦数据库操作完成，MyBatis 会将此连接返回给连接池。在开发或测试环境中，经常使用此种方式。
* 如果将类型设置成 JNDI，MyBatis 从在应用服务器向配置好的 JNDI 数据源 dataSource 获取数据库连接。在生产环境中，优先考虑这种方式。

### TransactionManager(事务管理器)