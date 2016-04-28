----
title: MyBatis Boostrap 
date: 2014-04-02 10:44:00
categories: 
- Java Web
- Mybatis
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

* MyBatis 支持两种类型的事务管理器： JDBC and MANAGED.
   * JDBC 事务管理器被用作当应用程序负责管理数据库连接的生命周期（提交、回退等等）的时候。当你将TransactionManager 属性设置成 JDBC，MyBatis 内部将使用 JdbcTransactionFactory 类创建TransactionManager。例如，部署到 Apache Tomcat 的应用程序，需要应用程序自己管理事务。
   * MANAGED 事 务 管 理 器 是 当 由 应 用 服 务 器 负 责 管 理 数 据 库 连 接 生 命 周 期 的 时 候 使 用 。 当 你将TransactionManager 属性设置成 MANAGED 时，MyBatis 内部使用 ManagedTransactionFactory 类创建事务管理器TransactionManager。例如，当一个 JavaEE 的应用程序部署在类似 JBoss，WebLogic，GlassFish 应用服务器上时，它们会使用 EJB 进行应用服务器的事务管理能力。在这些管理环境中，你可以使用 MANAGED 事务管理器。
>Managed 是托管的意思，即是应用本身不去管理事务，而是把事务管理交给应用所在的服务器进行管理。

### Properties(属性)
属性配置元素可以将配置值具体化到一个属性文件中，，并且使用属性文件的 key 名作为占位符。在上述的配置中，我们将数据库连接属性具体化到了 application.properties 文件中，并且为 driver，URL 等属性使用了占位符。

**1. 在 applications.properties 文件中配置数据库连接参数，如下所示：**
```
jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/mybatisdemo
jdbc.username=root
jdbc.password=admin
```
**2. 在 mybatis-config.xml 文件中，为属性使用 application.properties 文件中定义的占位符：**
```
<properties resource="application.properties">
    <property name="jdbc.username" value="db_user" />
    <property name="jdbc.password" value="verysecurepwd" />
</properties>
<dataSource type="POOLED">
    <property name="driver" value="${jdbc.driverClassName}" />
    <property name="url" value="${jdbc.url}" />
    <property name="username" value="${jdbc.username}" />
    <property name="password" value="${jdbc.password}" />
</dataSource>
```
并且，你可以在<properties>元素中配置默认参数的值。如果<properties>中定义的元素和属性文件定义元素的 key
值相同，它们会被属性文件中定义的值覆盖。
```
<properties resource="application.properties">
    <property name="jdbc.username" value="db_user" />
    <property name="jdbc.password" value="verysecurepwd" />
</properties>
```
这里，如果 application.properties 文件包含值 jdbc.username 和 jdbc.password，则上述定义的 username 和
password 的值 db_user 和 verysecurepwd 将会被 application.properties 中定义的对应的 jdbc.username 和
jdbc.password 值覆盖。

### typeAliases(类型别名)
在 SQLMapper 配置文件中，对于 resultType 和 parameterType 属性值，我们需要使用 JavaBean 的完全限定名。
```
<select id="findStudentById" parameterType="int" resultType="com.mybatis3.domain.Student">
       SELECT STUD_ID AS ID, NAME, EMAIL, DOB FROM STUDENTS WHERE STUD_ID=#{Id}
</select>
<update id="updateStudent" parameterType="com.mybatis3.domain. Student">
       UPDATE STUDENTS SET NAME=#{name}, EMAIL=#{email}, DOB=#{dob} WHERE STUD_ID=#{id}
</update>
```
这里我们为 resultType 和 parameterType 属性值设置为 Student 类型的完全限定名： com.mybatis3.domain.Student

我们可以为完全限定名取一个别名（alias），然后其需要使用完全限定名的地方使用别名，而不是到处使用完全限定
名。如下例子所示，为完全限定名起一个别名：
```
<typeAliases>
    <typeAlias alias="Student" type="com.mybatis3.domain.Student" />
    <typeAlias alias="Tutor" type="com.mybatis3.domain.Tutor" />
    <package name="com.mybatis3.domain" />
</typeAliases>
```
然后在 SQL Mapper 映射文件中, 如下使用 Student 的别名：
```
<select id="findStudentById" parameterType="int" resultType="Student">
    SELECT STUD_ID AS ID, NAME, EMAIL, DOB FROM STUDENTS WHERE STUD_ID=#{id}
</select>
<update id="updateStudent" parameterType="Student">
    UPDATE STUDENTS SET NAME=#{name}, EMAIL=#{email}, DOB=#{dob} WHERE STUD_ID=#{id}
</update>
```
你可以不用为每一个 JavaBean 单独定义别名, 你可以为提供需要取别名的 JavaBean 所在的包(package)，MyBatis
会自动扫描包内定义的 JavaBeans，然后分别为 JavaBean 注册一个小写字母开头的非完全限定的类名形式的别名。如下所
示，提供一个需要为 JavaBeans 起别名的包名：
```
<typeAliases>
    <package name="com.mybatis3.domain" />
</typeAliases>
```
如果 Student.java 和 Tutor.java Bean 定义在 com.mybatis3.domain 包中，则 com.mybatis3.domain.Student
的别名会被注册为 student。而 com.mybatis3.domain.Tutor 别名将会被注册为 tutor。示例如下：
```
<typeAliases>
    <typeAlias alias="Student" type="com.mybatis3.domain.Student" />
    <typeAlias alias="Tutor" type="com.mybatis3.domain.Tutor" />
    <package name="com.mybatis3.domain" />
    <package name="com.mybatis3.webservices.domain" />
</typeAliases>
```
还有另外一种方式为 JavaBeans 起别名，使用注解@Alias:
```
@Alias("StudentAlias")
public class Student{
}
```
@Alias 注解将会覆盖配置文件中的<typeAliases>定义。

### typeHandlers ( 类型处理器)
如上一章已经讨论过，MyBatis 通过抽象 JDBC 来简化了数据持久化逻辑的实现。MyBatis 在其内部使用 JDBC，提供
了更简洁的方式实现了数据库操作。
当 MyBatis 将一个 Java 对象作为输入参数执行 INSERT 语句操作时，它会创建一个 PreparedStatement 对象，并且
使用 setXXX()方式对占位符设置相应的参数值。
这里，XXX 可以是 Int，String，Date 等 Java 对象属性类型的任意一个。示例如下：
```
<insert id="insertStudent" parameterType="Student">
    INSERT INTO STUDENTS(STUD_ID,NAME,EMAIL,DOB) VALUES(#{studId},#{name},#{email},#{dob})
</insert>
```
**为执行这个语句，MyBatis 将采取以下一系列动作：**
**1. 创建一个有占位符的 PreparedStatement 接口，如下：**
```
PreparedStatement pstmt = connection.prepareStatement
("INSERT INTO STUDENTS(STUD_ID,NAME,EMAIL,DOB) VALUES(?,?,?,?)");
```
**检查 Student 对象的属性 studId 的类型，然后使用合适 setXXX 方法去设置参数值。这里 studId 是 integer
类型，所以会使用 setInt()方法：**
```
pstmt.setInt(1,student.getStudId());
```
**3. 类似地，对于 name 和 email 属性都是 String 类型，MyBatis 使用 setString()方法设置参数。**
```
pstmt.setString(2, student.getName());
pstmt.setString(3, student.getEmail());
```
**4. 至于 dob 属性, MyBatis 会使用 setDate() 方法设置 dob 处占位符位置的值。**

**5. MyBaits 会将 java.util.Date 类型转换为 into java.sql.Timestamp 并设值：**
```
pstmt.setTimestamp(4, new Timestamp((student.getDob()).getTime()));
```

   厉害！ MyBatis 是怎么知道对于 Integer 类型属性使用 setInt() 和 String 类型属性使用 setString()方法呢？但
其实 MyBatis 是通过使用类型处理器（type handlers）来决定这么做的。


  MyBatis 对 于 以 下 的 类 型 使 用 内 建 的 类 型 处 理 器 ： 所 有 的 基 本 数 据 类 型 、 基 本 类 型 的 包 裹 类 型 、 byte[] 、
java.util.Date、java.sql.Date、java,sql.Time、java.sql.Timestamp、java 枚举类型等。所以当 MyBatis 发现
属性的类型属于上述类型，他会使用对应的类型处理器将值设置到 PreparedStatement 中，同样地，当从 SQL 结果集构
建 JavaBean 时，也有类似的过程。

   那如果我们给了一个自定义的对象类型，来存储存储到数据库呢？示例如下：
   假设表 STUDENTS 有一个 PHONE 字段，类型为 VARCHAR(15)，而 JavaBean Student 有一个 PhoneNumber 类定义类
型的 phoneNumber 属性。
```
public class PhoneNumber
{
private String countryCode;
private String stateCode;
private String number;
public PhoneNumber()
{
}
public PhoneNumber(String countryCode, String stateCode, String
number)
{
this.countryCode = countryCode;
this.stateCode = stateCode;
this.number = number;
}
public PhoneNumber(String string)
{
if(string != null)
{
String[] parts = string.split("-");
if(parts.length > 0) this.countryCode = parts[0];
if(parts.length > 1) this.stateCode = parts[1];
if(parts.length > 2) this.number = parts[2];
}
}
public String getAsString()
{
return countryCode + "-" + stateCode + "-" + number;
}
// Setters and getters
}
public class Student
{
private Integer id;
private String name;
private String email;
private PhoneNumber phone;
// Setters and getters
}
```
```
<insert id="insertStudent" parameterType="Student">
	insert into students(name,email,phone) values(#{name},#{email},#{phone})
</insert>
```

   这里，phone 参数需要传递给#{phone}；而 phone 对象是 PhoneNumber 类型。然而，MyBatis 并不知道该怎样来处
理这个类型的对象。


   为了让 MyBatis 明白怎样处理这个自定义的 Java 对象类型，如 PhoneNumber，我们可以创建一个自定义的类型处理
器，如下所示：




**1. MyBatis 提供了抽象类 BaseTypeHandler<T> ，我们可以继承此类创建自定义类型处理器。**

**域模型对象PhoneNumber**
```
package org.freecode.domain;
public class PhoneNumber 
{
	private String countryCode;
	private String stateCode;
	private String number;
	
	public PhoneNumber() {
	}

	public PhoneNumber(String countryCode, String stateCode, String number) {
		super();
		this.countryCode = countryCode;
		this.stateCode = stateCode;
		this.number = number;
	}

	public PhoneNumber(String string) {
		if(string != null){
			String[] parts = string.split("-");
			if(parts.length>0) this.countryCode=parts[0];
			if(parts.length>1) this.stateCode=parts[1];
			if(parts.length>2) this.number=parts[2];
			
		}
	}
	
	@Override
	public String toString() {
		return this.getAsString();
	}
	
	public String getCountryCode() {
		return countryCode;
	}

	public void setCountryCode(String countryCode) {
		this.countryCode = countryCode;
	}

	public String getStateCode() {
		return stateCode;
	}

	public void setStateCode(String stateCode) {
		this.stateCode = stateCode;
	}

	public String getNumber() {
		return number;
	}

	public void setNumber(String number) {
		this.number = number;
	}

	public String getAsString() {
		return countryCode+"-"+stateCode+"-"+number;
	}
	
}

```
**定义格式转换类 PhoneTypeHandler**
```

package org.freecode.typehandlers;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.freecode.domain.PhoneNumber;

public class PhoneTypeHandler extends BaseTypeHandler<PhoneNumber>{

	@Override
	public void setNonNullParameter(PreparedStatement ps, int i,
			PhoneNumber parameter, JdbcType jdbcType) throws SQLException {
		ps.setString(i, parameter.getAsString());
	}

	@Override
	public PhoneNumber getNullableResult(ResultSet rs, String columnName)
			throws SQLException {
		return new PhoneNumber(rs.getString(columnName));
	}

	@Override
	public PhoneNumber getNullableResult(ResultSet rs, int columnIndex)
			throws SQLException {
		return new PhoneNumber(rs.getString(columnIndex));
	}

	@Override
	public PhoneNumber getNullableResult(CallableStatement cs, int columnIndex)
			throws SQLException {
		return new PhoneNumber(cs.getString(columnIndex));
	}

}

```
2. 我们使用 ps.setString()和 rs.getString()方法是因为 phone 列是 VARCHAR 类型。

3. 一旦我们实现了自定义的类型处理器，我们需要在 mybatis-config.xml 中注册它：
```
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
<properties resource="application.properties" />
<typeHandlers>
<typeHandler handler="com.mybatis3.typehandlers. PhoneTypeHandler" />
</typeHandlers>
</configuration>
```
注册 PhoneTypeHandler 后, MyBatis 就能够将 Phone 类型的对象值存储到 VARCHAR 类型的列上。
### Settings(全局参数设置)
为满足应用特定的需求，MyBatis 默认的全局参数设置可以被覆盖(overridden)掉，如下所示：
```
<settings>
<setting name="cacheEnabled" value="true" />
<setting name="lazyLoadingEnabled" value="true" />
<setting name="multipleResultSetsEnabled" value="true" />
<setting name="useColumnLabel" value="true" />
<setting name="useGeneratedKeys" value="false" />
<setting name="autoMappingBehavior" value="PARTIAL" />
<setting name="defaultExecutorType" value="SIMPLE" />
<setting name="defaultStatementTimeout" value="25000" />
<setting name="safeRowBoundsEnabled" value="false" />
<setting name="mapUnderscoreToCamelCase" value="false" />
<setting name="localCacheScope" value="SESSION" />
<setting name="jdbcTypeForNull" value="OTHER" />
<setting name="lazyLoadTriggerMethods" value="equals,clone,hashCode ,toString" />
</settings>
```
### Mappers(SQL 映射定义)
Mapper XML 文件中包含的 SQL 映射语句将会被应用通过使用其 statementid 来执行。我们需要在 mybatis-
config.xml 文件中配置 SQL Mapper 文件的位置。
```
<mappers>
<mapper resource="com/mybatis3/mappers/StudentMapper.xml" />
<mapper url="file:///D:/mybatisdemo/app/mappers/TutorMapper.xml" />
<mapper class="com.mybatis3.mappers.TutorMapper" />
<package name="com.mybatis3.mappers" />
</mappers>
```
以上每一个<mapper> 标签的属性有助于从不同类型的资源中加载映射 mapper：
* resource 属性用来指定在 classpath 中的 mapper 文件。
* url 属性用来通过完全文件系统路径或者 web URL 地址来指向 mapper 文件
* class 属性用来指向一个 mapper 接口
* package 属性用来指向可以找到 Mapper 接口的包名


## 使用 Java API 配置 MyBatis

## 自定义MyBatis 日志
   MyBatis 使用其内部 LoggerFactory 作为真正的日志类库使用的门面。其内部的 LaggerFactory 会将日志记录任务
委托给如下的所示某一个日志实现，日志记录优先级由上到下顺序递减：
* SLF4J
* Apache Commons Logging
* Log4j 2
* Log4j
* JDK logging

如果 MyBatis 未发现上述日志记录实现，则 MyBatis 的日志记录功能无效。
如果你的运行环境中，在 classpath 中有多个可用的日志类库，并且你希望 MyBaits 使用某个特定的日志实现，你可以通过调用以下其中一个方法：
```
org.apache.ibatis.logging.LogFactory.useSlf4jLogging();
org.apache.ibatis.logging.LogFactory.useLog4JLogging();
org.apache.ibatis.logging.LogFactory.useLog4J2Logging();
org.apache.ibatis.logging.LogFactory.useJdkLogging();
org.apache.ibatis.logging.LogFactory.useCommonsLogging();
org.apache.ibatis.logging.LogFactory.useStdOutLogging();
```
> 如果你想自定义 MyBatis 日志记录，你应该在调用任何其它方法之前调用以上的其中一个方法。如果你想切换到的日志记录类库在运行时期无效，MyBatis 将会忽略这一请求。

