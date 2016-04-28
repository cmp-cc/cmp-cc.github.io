----
title: MyBatis 与 第三方框架集成
date: 2014-04-04 22:09:00
categories: 
- Java Web
tags:
- Mybatis
----
**MyBatis 集成第三方框架应用集成**

## 与Spring 集成

### Spring 介绍
   Spring 框 架 是 一 个 基 于 依 赖 注 入 （ Dependency Injection ） 和 面 向 切 面 编 程 (Aspect Oriented Programming,AOP)的 Java 框架，鼓励使用基于 POJO 的编程模型。另外，Spring 提供了声明式和编程式的事务管理能力，可以很大程度上简化应用程序的数据访问层（data access layer）的实现。

**MyBatis-Spring 是 MyBatis 框架的子模块，用于与Spring 进行无缝集成。**
使用 Spring 的基于注解的事务管理机制将大大简化MyBatis 事务管理操作。

* MyBatis 与 Spring 框架集成
   * 依赖整合
   * Spring 应用程序中配置 MyBatis
      * ApplicationContext 上注册 MyBatis bean 实体对象
   * 配置和注入 SqlSession 和 Mapperbean 实体对象以及调用映射语句
      * 使用SqlSession
      * 使用映射器
   * Spring 基于注解的事务处理机制来使用 MyBatis


### Spring 应用程序中配置 MyBatis
#### Maven 进行依赖管理 
如下是使用Maven进行项目依赖管理（Spring 4 + MyBatis3）。
```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>

	<groupId>org.freecode</groupId>
	<artifactId>spring_mybatis</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	<packaging>jar</packaging>

	<name>spring_mybatis</name>
	<url>http://maven.apache.org</url>

	<properties>
		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
		<java.version>1.7</java.version>
		<junit.version>4.11</junit.version>
		<slf4j.version>1.7.5</slf4j.version>
		<log4j.version>1.2.17</log4j.version>
		<mybatis.version>3.2.6</mybatis.version>
		<mybatis-spring.version>1.2.2</mybatis-spring.version>
		<mysql.version>5.1.21</mysql.version>

		<spring.version>4.0.4.RELEASE</spring.version>
		<aspectj.version>1.6.8</aspectj.version>
		<commons.dbcp.version>1.4</commons.dbcp.version>
		<commons.pool.version>1.6</commons.pool.version>
		<commons.lang.version>2.5</commons.lang.version>

	</properties>

	<dependencies>
		<!-- Test start -->
		<dependency>
			<groupId>junit</groupId>
			<artifactId>junit</artifactId>
			<version>${junit.version}</version>
			<scope>test</scope>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-test</artifactId>
			<version>${spring.version}</version>
			<scope>test</scope>
		</dependency>
		<!-- Test end -->

		<!-- MyBatis start -->
		<dependency>
			<groupId>org.mybatis</groupId>
			<artifactId>mybatis</artifactId>
			<version>${mybatis.version}</version>
		</dependency>
		<dependency>
			<groupId>org.mybatis</groupId>
			<artifactId>mybatis-spring</artifactId>
			<version>${mybatis-spring.version}</version>
		</dependency>
		<!-- MyBatis end -->

		<!-- Spring start (不包含Spring Web) -->
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-core</artifactId>
			<version>${spring.version}</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-context</artifactId>
			<version>${spring.version}</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-context-support</artifactId>
			<version>${spring.version}</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-jdbc</artifactId>
			<version>${spring.version}</version>
		</dependency>
		<!-- Spring end -->

		<!-- MySql start -->
		<dependency>
			<groupId>mysql</groupId>
			<artifactId>mysql-connector-java</artifactId>
			<version>${mysql.version}</version>
			<scope>runtime</scope>
		</dependency>
		<!-- MySql end -->

		<!-- other start -->

		<!-- other end -->

		<dependency>
			<groupId>org.slf4j</groupId>
			<artifactId>slf4j-api</artifactId>
			<version>${slf4j.version}</version>
		</dependency>
		<dependency>
			<groupId>org.slf4j</groupId>
			<artifactId>jcl-over-slf4j</artifactId>
			<version>${slf4j.version}</version>
			<scope>runtime</scope>
		</dependency>
		<dependency>
			<groupId>org.slf4j</groupId>
			<artifactId>slf4j-log4j12</artifactId>
			<version>${slf4j.version}</version>
			<scope>runtime</scope>
		</dependency>

		<dependency>
			<groupId>log4j</groupId>
			<artifactId>log4j</artifactId>
			<version>${log4j.version}</version>
			<scope>runtime</scope>
		</dependency>
	</dependencies>

	<build>
		<plugins>
			<plugin>
				<artifactId>maven-compiler-plugin</artifactId>
				<configuration>
					<source>${java.version}</source>
					<target>${java.version}</target>
					<encoding>${project.build.sourceEncoding}</encoding>
				</configuration>
			</plugin>
		</plugins>
	</build>
</project>
```
如果你只使用 MyBatis 而没有使用 Spring，在每一个方法中，我们需要手动创建 SqlSessionFactory 对象，并且从 SqlSessionFactory 对象中创建SqlSession。而且我们还要负责提交或者回滚事务、关闭 SqlSession 对象。

通过使用 MyBatis-Spring 模块，我们可以在 Spring 的应用上下文 ApplicationContext 中配置 MyBatisBeans,Spring 会负责实例化 SqlSessionFactory 对象以及创建 SqlSession 对象，并将其注入到 DAO 或者 Service类中。并且，你可以使用 Spring 的基于注解的事务管理功能，不用自己在数据访问层中书写事务处理代码了。

#### 配置 MyBatis Beans
为了让 Spring 来实例化 MyBatis 组件如 SqlSessionFactory、SqlSession、以及映射器 Mapper 对象，我们需要在 Spring 的 bean 配置文件中配置它们，假设在 applicationContext.xml 中，配置如下：
```
<beans>
	<bean id="dataSource" class="org.springframework.jdbc.datasource. DriverManagerDataSource">
		<property name="driverClassName" value="com.mysql.jdbc.Driver" />
		<property name="url" value="jdbc:mysql://localhost:3306/test" />
		<property name="username" value="root" />
		<property name="password" value="admin" />
	</bean>
	<bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
		<property name="dataSource" ref="dataSource" />
		<property name="typeAliases" value="org.freecode.domain.Student, org.freecode.domain.Tutor" />
		<property name="typeAliasesPackage" value="org.freecode.domain" />
		<property name="typeHandlers" value="org.freecode.typehandlers.PhoneTypeHandler" />
		<property name="typeHandlersPackage" value="org.freecode.typehandlers" />
		<property name="mapperLocations" value="classpath*:org/freecode/**/*.xml" />
		<property name="configLocation" value="WEB-INF/mybatisconfig.xml" />
	</bean>
</beans>
```
* 使用上述的 bean 定义，Spring 会使用如下配置属性创建一个 SqlSessionFactory 对象：
   * dataSource:它引用了 dataSource bean
   * typeAliases:它指定了一系列的完全限定名的类名列表，用逗号隔开，这些别名将通过默认的别名规则创建（将首字母小写的非无完全限定类名作为别名）。
   * typeAliasesPackage:它指定了一系列包名列表，用逗号隔开，包内含有需要创建别名的 JavaBeans。
   * typeHandlers:它指定了一系列的类型处理器类的完全限定名的类名列表，用逗号隔开。
   * typeHandlersPackage: 它指定了一系列包名列表，用逗号隔开，包内含有需要被注册的类型处理器类。
   * mapperLocations:它指定了 SQL 映射器 Mapper XML 配置文件的位置
   * configLocation:它指定了 MyBatisSqlSessionFactory 配置文件所在的位置。

#### 使用 SqlSession
   一旦 SqlSessionFactory bean 被配置，我们需要配置 SqlSessionTemplate bean，SqlSessionTemplate bean是一个线程安全的 Spring bean，我们可以从中获取到线程安全的 SqlSession 对象。由于 SqlSessionTemplate 提供线程安全的 SqlSession 对象，你可以在多个 Spring bean 实体对象中共享 SqlSessionTemplate 对象。从概念上看，SqlSessionTemplate 和 Spring 的 DAO 模块中的 JdbcTemplate 非常相似。

```
<bean id="sqlSession" class="org.mybatis.spring.SqlSessionTemplate">
	<constructor-arg index="0" ref="sqlSessionFactory" />
</bean>
```
现在我肯可以将 SqlSession bean 实体对象注射到任意的 Spring bean 实体中，然后使用 SqlSession 对象调用SQL 映射语句。

```
public class StudentDaoImpl implements StudentDao {
	private SqlSession sqlSession;
	public void setSqlSession(SqlSession session) {
		this.sqlSession = session;
	}

	public void createStudent(Student student) {
		StudentMapper mapper = this.sqlSession.getMapper(StudentMapper.class);
		mapper.insertStudent(student);
	}
}
```

如果你正在使用基于 XML 来配置 Spring beans,你可以将 SqlSession bean 实体对象注射到 StudenDaoImplbean 实体对象中，如下：

```
<bean id="studentDao" class="org.freecode.dao.StudentDaoImpl">
	<property name="sqlSession" ref="sqlSession" />
</bean>
```
如果你使用基于注解的方式配置 Spring beans，你如下将 SqlSession bean 实体对象注入到 StudentDaoImplbean 实体对象中：
```
@Repository
public class StudentDaoImpl implements StudentDao {
	private SqlSession sqlSession;
	@Autowired
	public void setSqlSession(SqlSession session) {
		this.sqlSession = session;
	}
	public void createStudent(Student student) {
		StudentMapper mapper = this.sqlSession.getMapper(StudentMapper.class);
		mapper.insertStudent(student);
	}
}
```
还有另外一种注入 Sqlsession 对象的方法，即，通过拓展继承 SqlSessionDaoSupport。这种方式让我们可以在执行映射语句时，加入任何自定义的逻辑。
```
public class StudentMapperImpl extends SqlSessionDaoSupport implements StudentMapper {

	public void createStudent(Student student) {
		StudentMapper mapper = getSqlSession().getMapper(StudentMapper.class);
		mapper.insertAddress(student.getAddress());
		//Custom logic
		mapper.insertStudent(student);
	}
}
```

```
<bean id="studentMapper" class="org.freecode.dao.StudentMapperImpl">
	<property name="sqlSessionFactory" ref="sqlSessionFactory" />
</bean>
```
在以上的这些方式中，我们注入了 SqlSession 对象，获取 Mapper 实例，然后执行映射语句。这里 Spring 会为我们提供一个线程安全的 SqlSession 对象，以及当方法结束后关闭 SqlSession 对象。
然而，MyBatis-Spring 模块提供了更好的方式，我们可以不通过 SqlSession 获取映射器 Mapper，直接注射 Sql映射器 Mapper bean。我们下节将讨论它。
#### 使用映射器
我们可以使用 MapperFactoryBean 将映射器 Mapper 接口配置成 Spring bean 实体。如下所示：

```
public interface StudentMapper {
	@Select("select stud_id as studId, name, email, phone from students where stud_id=#{id}")
	Student findStudentById(Integer id);
}
```
```
<bean id="studentMapper" class="org.mybatis.spring.mapper.MapperFactoryBean">
	<property name="mapperInterface" value="org.freecode.mappers.StudentMapper" />
	<property name="sqlSessionFactory" ref="sqlSessionFactory" />
</bean>
```
现在 StudentMapper bean 实体对象可以被注入到任意的 Spring bean 实体对象中，并调用映射语句方法，如下所示：

```

public class StudentService {
	private StudentMapper studentMapper;
	public void createStudent(Student student) {
		this.studentMapper.insertStudent(student);
	}
	public void setStudentMapper (StudentMapperstudentMapper) {
		this. studentMapper = studentMapper;
	}
}
```
```
<bean id="studentService" class="org.freecode.services. StudentService">
	<property name="studentMapper" ref="studentMapper" />
</bean>
```

分别配置每一个映射器 Mapper 接口是一个非常单调的过程。我们可以使用 MapperScannerConfigurer 来扫描包（package）中的映射器 Mapper 接口，并自动地注册。
```
<bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
	<property name="basePackage" value="org.freecode.mappers" />
</bean>
```

如果映射器 Mapper 接口在不同的包(package)中，你可以为 basePackage 属性指定一个以逗号分隔的包名列表。
* MyBatis-Spring-1.2.0 介绍了两种新的扫描映射器 Mapper 接口的方法：
   * 使用<mybatis:scan/>元素
   * 使用@MapperScan 注解（需 Spring3.1+版本）
#### <mybatis:scan />
<mybatis:scan>元素将在特定的以逗号分隔的包名列表中搜索映射器 Mapper 接口。使用这个新的 MyBatis-Spring 名空间你需要添加以下的 schema 声明：

```
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mybatis="http://mybatis.org/schema/mybatis-spring"
	xsi:schemaLocation="http://www.springframework.org/schema/beans
		http://www.springframework.org/schema/beans/spring-beans.xsd
		http://mybatis.org/schema/mybatis-spring
		http://mybatis.org/schema/mybatis-spring.xsd">
	<mybatis:scan base-package="org.freecode.mappers" />
</beans>
```

* `<mybatis:scan>`元素提供了下列的属性来自定义扫描过程：
   * annotation: 扫描器将注册所有的在 base-package 包内并且匹配指定注解的映射器 Mapper 接口。
   * factory-ref: 当 Spring 上 下 文 中 有 多 个 SqlSessionFactory 实 例 时 ， 需 要 指 定 某 一 特 定 的SqlSessionFactory 来创建映射器 Mapper 接口。正常情况下，只有应用程序中有一个以上的数据源才会使用。
   * marker-interface: 扫描器将注册在 base-package 包中的并且继承了特定的接口类的映射器 Mapper 接口
   * template-ref: 当 Spring 上 下 文 中 有 多 个 SqlSessionTemplate 实 例 时 ， 需 要 指 定 某 一 特 定 的SqlSessionTemplate 来创建映射器 Mapper 接口。正常情况下，只有应用程序中有一个以上的数据源才会使用。
   * name-generator:BeannameGenerator 类的完全限定类名，用来命名检测到的组件。
#### MapperScan
Spring 框架 3.x+版本支持使用@Configuration 和@Bean 注解来提供基于 Java 的配置。如果你倾向于使用基于Java 的配置，你可以使用@MapperScan 注解来扫描映射器 Mapper接口。@MapperScan 和<mybatis:scan/>工作方式相同，并且也提供了对应的自定义选项。

```
@Configuration
@MapperScan("org.freecode.mappers")
public class AppConfig {
	@Bean
	public DataSource dataSource() {
		return new PooledDataSource("com.mysql.jdbc.Driver","jdbc:mysql://localhost:3306/test", "root", "123456");
	}
	@Bean
	public SqlSessionFactory sqlSessionFactory() throws Exception {
		SqlSessionFactoryBeansessionFactory = new SqlSessionFactoryBean();
		sessionFactory.setDataSource(dataSource());
		return sessionFactory.getObject();
	}
}
```
* @MapperScan 注解有以下属性供自定义扫描过程使用:
   * annotationClass: 扫描器将注册所有的在 base-package 包内并且匹配指定注解的映射器 Mapper 接口。
   * markerInterface: 扫描器将注册在 base-package 包中的并且继承了特定的接口类的映射器 Mapper 接口
   * sqlSessionFactoryRef: 当 Spring 上 下 文 中 有 一 个 以 上 的 SqlSesssionFactory 时 ， 用 来 指 定 特 定SqlSessionFactory
   * sqlSessionTemplateRef: 当 Spring 上下文 中有一 个以上的 sqlSessionTemplate 时，用 来 指定特定sqlSessionTemplate
   * nameGenerator:BeanNameGenerator 类用来命名在 Spring 容器内检测到的组件。
   * basePackageClasses:basePackages()的类型安全的替代品。包内的每一个类都会被扫描。
   * basePackages:扫描器扫描的基包，扫描器会扫描内部的 Mapper 接口。注意包内的至少有一个方法声明的才会被注册。具体类将会被忽略。

> 与注入 Sqlsession 相比，更推荐使用注入 Mapper，因为它摆脱了对MyBatis API 的依赖。
 
#### 使用 Spring 进行事务管理
只使用 MyBatis，你需要写事务控制相关代码，如提交或者回退数据库操作。
```
public Student createStudent(Student student) {
	SqlSession sqlSession = MyBatisUtil.getSqlSessionFactory().openSession();
	try {
		StudentMapper mapper = sqlSession.getMapper(StudentMapper.class);
		mapper.insertAddress(student.getAddress());
		mapper.insertStudent(student);
		sqlSession.commit();
		return student;
	}catch (Exception e) {
		sqlSession.rollback();
		throw new RuntimeException(e);
	} finally {
		sqlSession.close();
	}
}

```

我们可以使用 Spring 的基于注解的事务处理机制来避免书写上述的每个方法中控制事务的冗余代码。
为了能使用 Spring 的事务管理功能，我们需要在 Spring 应用上下文中配置 TransactionManager bean 实体对象：
```
<bean id="transactionManager" class="org.springframework.jdbc. datasource.DataSourceTransactionManager">
	<property name="dataSource" ref="dataSource" />
</bean>
```

事务管理器引用的 dataSource 和 SqlSessionFactory bean 使用的 dataSource 相同。
在 Spring 中使用基于注解的事务管理特性，如下：
```
<tx:annotation-driven transaction-manager="transactionManager"/>
```
现在你可以在 Spring service bean 上使用@Transactional 注解，表示在此 service 中的每一个方法都应该在一个事务中运行。如果方法成功运行完毕，Spring 会提交操作。如果有运行期异常发生，则会执行回滚操作。另外，Spring 会将 MyBatis 的异常转换成合适的 DataAccessExceptions，这样会为特定错误上提供额外的信息。

```
@Service
@Transactional
public class StudentService {
	@Autowired
	private StudentMapper studentMapper;
	public Student createStudent(Student student) {
		studentMapper.insertAddress(student.getAddress());
		if(student.getName().equalsIgnoreCase("")) {
			throw new RuntimeException("Student name should not beempty.");
		}
		studentMapper.insertStudent(student);
		return student;
	}
}
```

下面是一个 Spring 的 applicationContext.xml 完成配置：
```
<beans>
	<context:annotation-config />
	<context:component-scan base-package="org.freecode" />
	<context:property-placeholder location="classpath:application.properties" />
	<tx:annotation-driven transaction-manager="transactionManager" />
	<bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
		<property name="dataSource" ref="dataSource" />
	</bean>
	<bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
		<property name="basePackage" value="org.freecode.mappers" />
	</bean>
	<bean id="sqlSession" class="org.mybatis.spring.SqlSessionTemplate">
		<constructor-arg index="0" ref="sqlSessionFactory" />
	</bean>
	<bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
		<property name="dataSource" ref="dataSource" />
		<property name="typeAliases" value="org.freecode.domain.Student,org.freecode.domain.Tutor" />
		<property name="typeAliasesPackage" value="org.freecode.domain" />
		<property name="typeHandlers" value="org.freecode.typehandlers.PhoneTypeHandler" />
		<property name="typeHandlersPackage" value="org.freecode.typehandlers" />
		<property name="mapperLocations" value="classpath*:com/mybatis3/**/*.xml" />
	</bean>
	<bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
		<property name="driverClassName" value="${jdbc.driverClassName}"></property>
		<property name="url" value="${jdbc.url}"></property>
		<property name="username" value="${jdbc.username}"></property>
		<property name="password" value="${jdbc.password}"></property>
	</bean>
</beans>
```
现在让我们写一个独立的测试客户端来测试 StudentService，如下：

```
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = "classpath:applicationContext.xml")
public class StudentServiceTest {
	@Autowired
	private StudentService studentService;

	@Test
	public void testCreateStudent() {
	Address address = new Address(0, "Quaker RidgeRd.", "Bethel", "Brooklyn", "06801", "USA");
	Student stud = new Student();
	long ts = System.currentTimeMillis();
	stud.setName("stud_" + ts);
	stud.setEmail("stud_" + ts + "@gmail.com");
	stud.setAddress(address);
	Student student = studentService.createStudent(stud);
	assertNotNull(student);
	assertEquals("stud_" + ts, student.getName());
	assertEquals("stud_" + ts + "@gmail.com", student.getEmail());
	System.err.println("CreatedStudent: " + student);
	}

	@Test(expected = DataAccessException.class)
		public void testCreateStudentForException(){
		Address address = new Address(0, "Quaker RidgeRd.", "Bethel", "Brooklyn", "06801", "USA");
		Student stud = new Student();
		long ts = System.currentTimeMillis();
		stud.setName("Timothy");
		stud.setEmail("stud_" + ts + "@gmail.com");
		stud.setAddress(address);
		studentService.createStudent(stud);
		fail("You should not reach here");
	}
}
```
这里在 testCreateStudent()方法中，我们为 Address 和 Student 赋上了合适的数据，所以 Address 和 Student会被分别插入到表 ADDRESSES 和 STUDENTS 中。在 testCreateStudentForException()方法我们设置了名字为Timothy，该名称在数据库中已经存在了，所以当你尝试将此 student 记录插入到数据库中，MySQL 会抛出一个 UNIQUEKEY 冲突的异常，Spring 会将此异常转换成 DataAccessException 异常，并且将插入 ADDRESSES 表中的数据回滚（rollback）掉。



<br/>
<br/>
<br/>

> 学习参考：《Java Persistence with MyBatis 3》


