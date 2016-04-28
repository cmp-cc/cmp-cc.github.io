----
title: MyBatis 入门
date: 2014-04-01 23:44:00
categories: 
- Java Web
tags:
- Mybatis
----

Hibernate 太过于庞大，作为同样的持久化ORM 框架Mybatis 就显得非常小巧灵活。

MyBatis 同样是简单易用的。
   
Java数据库持久化层主要两个部分：
* 将从数据库查询到的数据生成所需要的 Java 对象
* 将 Java 对象中的数据通过 SQL 持久化到数据库中。

## 为什么 选择MyBatis ?

### 消除大量JDBC冗余代码

* 无需关注重复性JDBC操作 (不再与connection，statement，resultSet 重复性对象打交道)，MyBatis 会处理这些底层工作
> 创建 Connection 连接，创建一个 Statement 对象，设置输入参数，关闭资源
* 需要配置数据库连接属性和 SQL 语句。 （POJO <--> SQL Table）
   * Mybatis 准备需要被执行的 SQL statement 对象并且将 Java 对象作为输入数据传递给 statement 对象的任务
   * MyBatis 自动化了将从输入的 Java 对象中的属性设置成查询参数、从 SQL 结果集上生成 Java 对象

**实例说明**
**1. 在 SQL Mapper 映射配置文件中配置 SQL 语句，假定为 StudentMapper.xml**

```
<select id="findStudentById" parameterType="int" resultType="Student">
     SELECT STUD_ID AS studId, NAME, EMAIL, DOB FROM STUDENTS WHERE STUD_ID=#{Id}
</select>

<insert id="insertStudent" parameterType="Student">
     INSERT INTO STUDENTS(STUD_ID,NAME,EMAIL,DOB) VALUES(#{studId},#{name},#{email},#{dob})
</insert>
```
**2. 创建一个 StudentMapper 接口**
```
public interface StudentMapper {
           Student findStudentById(Integer id);
           void insertStudent(Student student);
}
```
**3. 在 Java 代码中，你可以使用如下代码触发 SQL 语句：**

``` Java
SqlSession session = getSqlSessionFactory().openSession();
StudentMapper mapper = session.getMapper(StudentMapper.class);
// Select Student by Id
Student student = mapper.selectStudentById(1);
//To insert a Student record
mapper.insertStudent(student);
```

**编码完成**

### 低学习曲线
**你需要熟悉Java 和 SQL 即可**

### 能够很好地与传统数据库协同工作
Hibernate将 Java 对象静态地映射到数据库的表上
MyBatis 是将查询的结果与 Java 对象映射起来。你可以根据面相对象的模型创建 Java 域对象，执行传统数据库的查询，然后将结果映射到对应的 Java 对象上。

### 接受 SQL
Hibernate鼓励使用实体对象（Entity Objects）和在其底层自动产生 SQL 语句。这种
的 SQL 生成方式，我们有可能不能够利用到数据库的一些特有的特性。Hibernate 允许执行本地 SQL，但是这样会打破持
久层和数据库独立的原则。

MyBatis 框架接受 SQL 语句，而不是将其对开发人员隐藏起来。由于 MyBatis 不会产生任何的 SQL 语句，所以开发
人员就要准备 SQL 语句，这样就可以充分利用数据库特有的特性并且可以准备自定义的查询。另外，MyBatis 对存储过程
也提供了支持。

### 与Spring 集成
MyBatis 提供了与 流行的依赖注入框架 Spring 和 Guice 的开包即用的集成支持，这将进一步简化 MyBatis 的使用

### 与第三方缓存类库的集成支持
MyBatis 有内建的 SqlSession 级别的缓存机制，用于缓存 Select 语句查询出来的结果。除此之外，MyBatis 提供
了与多种第三方缓存类库的集成支持，如 EHCache，OSCache，Hazelcast。

### 良好的性能
* MyBatis 支持数据库连接池，消除了为每一个请求创建一个数据库连接的开销
* MyBatis 提供了内建的缓存机制，在 SqlSession 级别提供了对 SQL 查询结果的缓存。即:如果你调用了相同的select 查询，MyBatis会将放在缓存的结果返回，而不会去再查询数据库。
* MyBatis 框架并没有大量地使用代理机制2，因此对于其他的过度地使用代理的 ORM 框架而言，MyBatis 可以获得更
好的性能。

**如果你的应用是以面向对象模型，并且向动态生成 SQL 语句，那么 MyBatis可能就不符合你的要求。另外，如果你想让你的应用有一个传递性的缓存机制的话（保存父对象时也应该保存关联的子对象），Hibernate 会更适合你。**

## Mybatis 入门

* Mybatis 入门   
   * 新建表 STUDENTS，插入样本数据
   * 新建一个 Maven 项目，pom.xml 添加相关依赖
   * 新建建 MyBatisSqlSessionFactory 单例模式类
   * 新建映射器 StudentMapper 接口和 StudentService 类
   * 新建一个 JUnit 测试类来测试 StudentService

### 新建表 STUDENTS，插入样本数据

**使用以下 SQL 脚本往 MySQL 数据库中创建 STUDENTS 表插入样本数据：**
```SQL
CREATE TABLE STUDENTS
(
stud_id int(11) NOT NULL AUTO_INCREMENT,
name varchar(50) NOT NULL,
email varchar(50) NOT NULL,
dob date DEFAULT NULL,
PRIMARY KEY (stud_id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*Sample Data for the students table */
insert into students(stud_id,name,email,dob)
values (1,'Student1','student1@gmail.com','1983-06-25');
insert into students(stud_id,name,email,dob)
values (2,'Student2','student2@gmail.com','1983-06-25');
```

###  新建一个 Maven 项目，pom.xml 添加相关依赖
* 创建一个名为 mybatis-demo的Maven 项目
* 在 pom.xml 中添加以下依赖：
```
<dependency>
	<groupId>org.mybatis</groupId>
	<artifactId>mybatis</artifactId>
	<version>3.2.6</version>
</dependency>

<dependency>
	<groupId>mysql</groupId>
	<artifactId>mysql-connector-java</artifactId>
	<version>5.1.30</version>
</dependency>

<dependency>
	<groupId>org.slf4j</groupId>
	<artifactId>slf4j-api</artifactId>
	<version>1.7.5</version>
</dependency>

<dependency>
	<groupId>org.slf4j</groupId>
	<artifactId>slf4j-log4j12</artifactId>
	<version>1.7.5</version>
	<scope>runtime</scope>
</dependency>

<dependency>
	<groupId>log4j</groupId>
	<artifactId>log4j</artifactId>
	<version>1.2.17</version>
	<scope>runtime</scope>
</dependency>

<dependency>
	<groupId>junit</groupId>
	<artifactId>junit</artifactId>
	<version>4.11</version>
	<scope>test</scope>
</dependency>
```
* 新建 log4j.properties 文件，添加到 `src/main/resources` (classpath下) 中
```
log4j.rootLogger=DEBUG, stdout
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%d [%-5p] %c - %m%n
```

### 新建 mybatis-config.xml 和映射器 StudentMapper.xml 配置文件
* **`mybatis-config.xml` 为MyBatis的主要配置文件，其中包括数据库连接信息、类型别名等,创建并添加classpath下**
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
	<typeAliases>
		<typeAlias alias="Student" type="org.freecode.domain.Student" />
	</typeAliases>
	<environments default="development">
		<environment id="development">
			<transactionManager type="JDBC" />
			<dataSource type="POOLED">
				<property name="driver" value="com.mysql.jdbc.Driver" />
				<property name="url" value="jdbc:mysql://localhost:3306/test" />
				<property name="username" value="root" />
				<property name="password" value="123456" />
			</dataSource>
		</environment>
	</environments>
	<mappers>
		<mapper resource="or/freecode/mappers/StudentMapper.xml" />
	</mappers>
</configuration>
```
* **`StudentMapper.xml` 实体映射SQL语句文件，并将其放入自定义mapper目录下。（org.freecode.mappers）**
```
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="org.freecode.mappers.StudentMapper">
	<resultMap type="Student" id="StudentResult">
		<id property="studId" column="stud_id" />
		<result property="name" column="name" />
		<result property="email" column="email" />
		<result property="dob" column="dob" />
	</resultMap>
	<select id="findAllStudents" resultMap="StudentResult">
		SELECT * FROM STUDENTS
	</select>
	<select id="findStudentById" parameterType="int" resultType="Student">
		SELECT STUD_ID AS STUDID, NAME, EMAIL, DOB
		FROM STUDENTS WHERE STUD_ID=#{Id}
	</select>
	<insert id="insertStudent" parameterType="Student">
		INSERT INTO STUDENTS(STUD_ID,NAME,EMAIL,DOB)
		VALUES(#{studId },#{name},#{email},#{dob})
	</insert>
</mapper>
```

### 新建 MyBatisSqlSessionFactory 单例类
**新建 MyBatisSqlSessionFactory.java 类文件，实例化它，使其持有一个 SqlSessionFactory 单例对象：**
```
package org.freecode.util;

import java.io.IOException;
import java.io.InputStream;

import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;

public class MyBatisSqlSessionFactory {

	private static SqlSessionFactory sqlSessionFactory;
	public static SqlSessionFactory getSqlSessionFactory(){
		if(sqlSessionFactory == null){
			InputStream inputStream;
			try{
				inputStream = Resources.getResourceAsStream("mybatis-config.xml");
				
				sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
			}catch(IOException e){
				throw new RuntimeException(e.getCause());
			}
		}
		return sqlSessionFactory;
	}
	
	public static SqlSession openSession(){
		return getSqlSessionFactory().openSession();
	}
}
```
**上述的代码段中，我们创建了一个 SqlSessionFactory 对象，我们将使用它来获得 SqlSession 对象和执行映射的SQL 语句。**

### 新建 StudentMapper 接口和 StudentService 类
让我们创建一个 StudentMapper 接口，其定义的方法名和在 Mapper XML 配置文件定义的 SQL 映射语句名称相同；
在创建一个 StudentService.java 类，包含了一些业务操作的实现。

* 首先，创建JavaBean Student.java
```
package org.freecode.domain;

import java.util.Date;

public class Student {
	private Integer studId;
	private String name;
	private String email;
	private Date dob;
	public Integer getStudId() {
		return studId;
	}
	public void setStudId(Integer studId) {
		this.studId = studId;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public Date getDob() {
		return dob;
	}
	public void setDob(Date dob) {
		this.dob = dob;
	}
	@Override
	public String toString() {
		return "Student [studId=" + studId + ", name=" + name + ", email="
				+ email + ", dob=" + dob + "]";
	}
}

```

* 创建映射器 Mapper 接口 StudentMapper.java 其方法签名和 StudentMapper.xml 中定义的 SQL 映射定义名相同
```
package org.freecode.mappers;

import java.util.List;
import org.freecode.domain.Student;

public interface StudentMapper {
	List<Student> findAllStudents();
	Student findStudentById(Integer id);
	void insertStudent(Student student);
}
```
* 创建 StudentService.java 实现对表 STUDENTS 的数据库操作
```
package org.freecode.services;


import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.freecode.domain.Student;
import org.freecode.mappers.StudentMapper;
import org.freecode.util.MyBatisSqlSessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class StudentService {
	private Logger logger = LoggerFactory.getLogger(getClass());
	
	public List<Student> findAllStudents(){
		SqlSession sqlSession = MyBatisSqlSessionFactory.openSession();
		
		try{
			StudentMapper studentMapper = sqlSession.getMapper(StudentMapper.class);
			return studentMapper.findAllStudents();
		}finally{
			// 如果sqlSession 没有关闭， 数据库连接不会返回到连接池(pool)中
			sqlSession.close();
		}
	}
	
	public Student findStudentById(Integer studId){
		logger.debug("Select Student By ID :{}",studId);
		SqlSession sqlSession = MyBatisSqlSessionFactory.openSession();
		try{
			StudentMapper studentMapper = sqlSession.getMapper(StudentMapper.class);
			return studentMapper.findStudentById(studId);
		}finally{
			sqlSession.close();
		}
	}
	
	public void createStudent(Student student){
		SqlSession sqlSession = MyBatisSqlSessionFactory.openSession();
		try{
			StudentMapper studentMapper = sqlSession.getMapper(StudentMapper.class);
			studentMapper.insertStudent(student);
			sqlSession.commit();
		}finally{
			sqlSession.close();
		}
	}
	
	/**
	 * 你也可以不通过Mapper接口执行映射的SQL语句,如下。（并不推荐）
	 * @param studId
	 * @return
	 */
	public Student findStudentById2(Integer studId){
		SqlSession sqlSession = MyBatisSqlSessionFactory.openSession();
		try{
			return (Student)sqlSession.selectOne("org.freecode.mappers.StudentMapper.findStudentById",studId);
		}finally{
			sqlSession.close();
		}
	}
}

```

###  新建一个 JUnit 测试类来测试 StudentService
```
package org.freecode.services;

import java.util.Date;
import java.util.List;

import org.freecode.domain.Student;
import org.junit.AfterClass;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;

public class StudentServiceTest {

	private static StudentService studentService;
	
	@BeforeClass
	public static void setup(){
		studentService = new StudentService();
	}
	
	@AfterClass
	public static void teardown(){
		studentService = null;
	}
	
	@Test
	public void testFindAllStudents(){
		List<Student> students = studentService.findAllStudents();
		Assert.assertNotNull(students);
		for (Student student : students){
			System.out.println(student);
		}
	}
	
	@Test
	public void testFindStudentById(){
		Student student = studentService.findStudentById(3);
		Assert.assertNotNull(student);
		System.out.println(student);
	}

	
	@Test
	public void testCreateStudent(){
		Student student = new Student();
		int id = 3;
		student.setStudId(id);
		student.setName("student_" + id);
		student.setEmail("student_" + id + "gmail.com");
		student.setDob(new Date());
		studentService.createStudent(student);
		Student newStudent = studentService.findStudentById(id);
		Assert.assertNotNull(newStudent);
	}
	
}

```

### 它是怎么工作的？

* 首先，我们配置了 MyBatis 最主要的配置文件-mybatis-config.xml,里面包含了 JDBC 连接参数；配置了映射器Mapper XML 配置文件文件，里面包含了 SQL 语句的映射。
* 我 们 使 用 mybatis-config.xml 内 的 信 息 创 建 了 SqlSessionFactory 对 象 。 每 个 数 据 库 环 境 应 该 就 一 个SqlSessionFactory 对象实例，所以我们使用了单例模式只创建一个 SqlSessionFactory 实例。
* 我们创建了一个映射器 Mapper 接口-StudentMapper，其定义的方法签名和在 StudentMapper.xml 中定义的完全一样（即映射器 Mapper 接口中的方法名跟 StudentMapper.xml 中的 id 的值相同）。注意 StudentMapper.xml 中namespace 的值被设置成 org.freecode.mappers.StudentMapper，是 StudentMapper 接口的完全限定名。这使我们可以使用接口来调用映射的 SQL 语句。
* 在 StudentService.java 中，我们在每一个方法中创建了一个新的 SqlSession，并在方法功能完成后关闭SqlSession。每一个线程应该有它自己的 SqlSession 实例。SqlSession 对象实例不是线程安全的，并且不被共享。所以 SqlSession 的作用域最好就是其所在方法的作用域。从 Web 应用程序角度上看，SqlSession 应该存在于 request 级别作用域上。
