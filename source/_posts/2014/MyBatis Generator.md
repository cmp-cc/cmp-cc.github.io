----
title: MyBatis Generator
date: 2014-05-11 22:53:00
updated:
categories: 
- Java Web
- MyBatis
tags:
- MyBatis
----


MyBatis 也提供了一些工具如 MyBatis Generator(http://www.mybatis.org/generator/)，可以被用来从已经存在的数据库 schema 中，产生持久化代码如数据库实体（database entities）,映射器 Mapper 接口，MapperXML 配置文件。


## MyBatis Generator 介绍

* MyBatis Generator (MBG) 是一个Mybatis的代码生成器
* 它可以将数据库表生成基础对象。(不再需要手工创建对象和配置文件)
* MBG 能够创建简单的CDUR(增删改查)。（仍然需要手写SQL和对象，用于级联查询和存储过程）

----

MyBatis 生成如下：
* 匹配表结构的Java POJO 对象， 可能包括
   * 一个和表主键匹配的类（如果存在主键）
   * 一个包含了非主键字段的类（BLOB字段除外）
   * 一个包含BLOB字段的类（如果表包含了BLOB字段）
   * 一个允许动态查询、更新和删除的类
这些类之间会有适当的继承关系。 可以配置生成器来生成不同类型的 POJO 的层次结构。 例如，您可能会选择针对每个表生成一个单独的实体对象。
* MBG在配置中为每个表简单的生成 CRUD SQL 操作。生成的SQL 语句包括：
   * insert (插入)
   * update by primary key (根据主键更新记录)
   * update by example (根据条件更新记录)
   * delete by primary key (根据主键删除记录)
   * delete by example (根据条件删除记录)
   * select by primary key (根据主键查询记录)
   * select by example (根据条件查询记录集)
   * count by example (根据条件查询记录总数)
根据表的结构，生成的这些语句会有不同的变化（例如，如果表中没有主键，那么 MBG 将不会生成update by primary key方法）。

---

* 注意
   * MBG 会自动合并重名XML文件（是合并，保留修改），从而可以反复运行，而不必担心修改丢失。
   * MBG 不会合并Java文件，它可以覆盖或保留不同命名的文件。Eclipse插件时，MBG自动合并Java文件。

## 快速入门

快速使用MBG步骤如下：
* 1、创建并填写适当的配置文件，必须包含如下：(查看 XML配置参考)
   * `<jdbcConnection>` 元素定义如何连接目标数据库
   * `<javaModelGenerator>` 元素来指定生成 Java 模型对象所属的包
   * `<sqlMapGenerator>` 元素来指定生成 SQL 映射文件所属的包和的目标项目
   * (可选) `<javaClientGenerator>` 元素来指定目标包和目标项目生成的客户端接口和类（如果您不想生成 Java 客户端代码您可以省略`<javaClientGenerator>`元素）
   * 至少一个数据库`<table>`元素
* 2、将文件保存适当的位置（例如：`\temp\generatorConfig.xml`）
* 3、执行如下命令运行MBG:
   ```
   java -jar mybatis-generator-core-x.x.x.jar -configfile \temp\generatorConfig.xml -overwrite
   ```
   > MBG使用配置文件运行，` -overwrite` 表示覆盖同名Java文件。如果有冲突，MBG会生成一个唯一的文件。（e.g MyClass.java）
* 4、MBG运行后，你需要创建或修改标准的MyBatis配置文件来使用新生成的代码。

## XML配置参考

### MyBatis Generator XML 配置参考
如下是MBG的一个XML配置文件驱动。配置文件告诉MBG：
* 如何链接到数据库
* 生成什么对象，及其如何生成
* 哪些表生成对象

**如下是MBG配置文件实例。你应当查阅每一个元素说明**
```

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE generatorConfiguration
  PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
  "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">

<generatorConfiguration>
  <classPathEntry location="/Program Files/IBM/SQLLIB/java/db2java.zip" />

  <context id="DB2Tables" targetRuntime="MyBatis3">
    <jdbcConnection driverClass="COM.ibm.db2.jdbc.app.DB2Driver"
        connectionURL="jdbc:db2:TEST"
        userId="db2admin"
        password="db2admin">
    </jdbcConnection>

    <javaTypeResolver >
      <property name="forceBigDecimals" value="false" />
    </javaTypeResolver>

    <javaModelGenerator targetPackage="test.model" targetProject="\MBGTestProject\src">
      <property name="enableSubPackages" value="true" />
      <property name="trimStrings" value="true" />
    </javaModelGenerator>

    <sqlMapGenerator targetPackage="test.xml"  targetProject="\MBGTestProject\src">
      <property name="enableSubPackages" value="true" />
    </sqlMapGenerator>

    <javaClientGenerator type="XMLMAPPER" targetPackage="test.dao"  targetProject="\MBGTestProject\src">
      <property name="enableSubPackages" value="true" />
    </javaClientGenerator>

    <table schema="DB2ADMIN" tableName="ALLTYPES" domainObjectName="Customer" >
      <property name="useActualColumnNames" value="true"/>
      <generatedKey column="ID" sqlStatement="DB2" identity="true" />
      <columnOverride column="DATE_FIELD" property="startDate" />
      <ignoreColumn column="FRED" />
      <columnOverride column="LONG_VARCHAR_FIELD" jdbcType="VARCHAR" />
    </table>

  </context>
</generatorConfiguration>
```

### MBG XML 元素说明

查看官方元素说明：http://www.mybatis.org/generator/configreference/xmlconfig.html


## 通过Maven plugin 运行MBG
运行MBG 可以使用`命令提示符`、`Ant任务`、`Maven Plugin`、`Java程序`。 这里介绍Maven 形式。

### 最简配置如下
```
       <plugins>
        ...
        <plugin>
          <groupId>org.mybatis.generator</groupId>
          <artifactId>mybatis-generator-maven-plugin</artifactId>
          <version>1.3.2</version>
        </plugin>
        ...
      </plugins>
```

### Maven 目标（Goal）和执行（Execution）

MBG Maven Plugin 可以包含一个目录: `mybatis-generator:generate` ，如下配置：
```
    <plugins>
        ...
        <plugin>
          <groupId>org.mybatis.generator</groupId>
          <artifactId>mybatis-generator-maven-plugin</artifactId>
          <version>1.3.2</version>
          <executions>
            <execution>
              <id>Generate MyBatis Artifacts</id>
              <goals>
                <goal>generate</goal>
              </goals>
            </execution>
          </executions>
        </plugin>
        ...
      </plugins>
```
>MBG插件将会绑定到Maven生命周期的 `generate-sources` 阶段。 所以他会在编译步骤之前执行。 此外注意MBG目标将绑定生成Java和XML资源文件的建立，他们都将包括在生成的JAR包内。

* 通过如下命令执行
```
mvn mybatis-generator:generate
```
* 或则 标准的Maven命令属性传递参数执行 (这条命令会是使MBG覆盖重名的文件)
```
mvn -Dmybatis.generator.overwrite=true mybatis-generator:generate
```

### MBG 参考参数
如下简单参考参数实例（大多数情况下为默认设置）：
```
        <plugins>
            <plugin>
                <groupId>org.mybatis.generator</groupId>
                <artifactId>mybatis-generator-maven-plugin</artifactId>
                <version>1.3.2</version>
                <configuration>
                    <configurationFile>src/main/resources/generatorConfig.xml</configurationFile>
                    <sqlScript>classpath:mbg/test/common/scripts/CreateDB.sql</sqlScript>
                    <jdbcDriver>org.hsqldb.jdbcDriver</jdbcDriver>
                    <jdbcURL>jdbc:hsqldb:mem:aname</jdbcURL>
                    <jdbcUserId>sa</jdbcUserId>
                    <verbose>true</verbose>
                    <overwrite>true</overwrite>
                     ....
                </configuration>
            </plugin>
        </plugins>
```

如下是参考参数，均为可选，部分默认。

参数  | 类型 | 说明
--- | --- |---
configurationFile | File |  指定配置文件的名称。默认值：`${basedir}/src/main/resources/generatorConfig.xml`
contexts  | String| 如果指定了该参数，使用逗号隔开`context`会被执行。 这些指定的`context`必须和配置文件中 `<context>` 元素的 `id` 属性一致。只有指定的这些`contextid`会被激活执行。如果没有指定该参数，所有的`context`都会被激活执行。
jdbcDriver| String  | 如果您指定了 sqlScript 参数, 当连接数据库时这里的值是JDBC驱动类的权限定名称。
jdbcPassword|   String |  如果您指定了 `sqlScript` 参数, 这是连接数据库的密码。
jdbcURL | String |  如果您指定了 `sqlScript` 参数, 这是连接数据库的`JDBC URL`
jdbcUserId|   String |  如果您指定了 `sqlScript` 参数, 这里是连接数据库的用户`id`
outputDirectory|    File  |将放置 MBG 所生成文件的目录。 这个目录是用于当` targetProject` 在配置文件中设置特殊值的"MAVEN"时使用(大小写敏感)。 默认值: `${project.build.directory}/generated-sources/mybatis-generator`
overwrite | boolean | 如果为`true`，新生成的Java文件会覆盖原有的文件。 如果没有指定该参数，存在同名的文件，MBG会给新生成的代码文件生成一个唯一的名字(例如： MyClass.java.1, MyClass.java.2 等等)。 **重要: 生成器一定会自动合并或覆盖已经生成的XML文件。** 默认值: `false`
sqlScript |String | 要在生成代码之前运行的 SQL 脚本文件的位置。 如果为空，不会执行任何脚本。 如果不为空，`jdbcDriver`, `jdbcURL` 参数必须提供。 另外如果连接数据库需要认证也需要提供`jdbcUserId` 和 `jdbcPassword` 参数。 值可以使一个文件系统的绝对路径或者是一个使用`"classpath:"`开头放在构建的类路径下的路径。
tableNames  | String  | 如果指定了该参数，逗号隔开的这个表会被运行， 这些表名必须和`<table>` 配置中的表面完全一致。只有指定的这些表会被执行。 如果没有指定该参数，所有的表都会被执行。按如下方式指定表明:  table 、schema.table 、catalog..table 等等。
verbose |   boolean|  如果指定该参数，执行过程会输出到控制台。

## 使用生成的对象
MBG生成如下类型的对象：
* Java 模型对象
* SQL映射文件（可选）
* 一个xxxByExample方法的使用类。


### Java 模型对象

* MBG 根据数据库表字段生成Java POJO 对象。（根据表特性和配置生成不同类型的实体对象）
* 如果不使用Eclipse插件，需要手工合并修改后生成的Java对象
* 任何字段配置`<ignoreColumn>`,自动生成时不会添加到Java对象中


#### 主键类
* 表中包含一个主键的字段属性,根据表的列名自动生成属性名称。可配置`<columnOverride>`属性覆盖。
* 类名默认是`<TableName>Key`,如果`<table>`元素配置domainObjectName属性，那么类名是`<domainObjectName>Key`
* This class will be generated in the hierarchical model if the table has a primary key. This class will be generated in the conditional model if the table has more then one column in the primary key. This class will not be generated in the flat model.

#### 记录类
* 表中不包含主键、BLOB字段属性.如果这个类集成了主键类，MBG会根据表的列名自动生成属性名称。可通过`columnOverride`属性覆盖属性名称。
* 类名默认是`<TableName>`,如果`<table>`配置了`domainObjectName`属性，类名为`<domainObjectName>`
* This class will be generated in the hierarchical model if the table has non-BLOB and non-primary key columns. This class will be generated in the conditional model if the table has non-BLOB and non-primary key columns, or if there is only one primary key column or one BLOB column. This class is always generated in the flat model.

#### BLOB 记录类
* 表中包含BLOB字段属性，如果表中只存在一个字段，该类将继承基础类，或将继承主键类。（注意：MBG 不支持表中只包含BLBO列）MBG 根据表列名自动生成属性名称，可以配置`<columnOverride>`属性覆盖
* BLOB 记录类调用`selectByPrimaryKey`或`selectByExampleWithBLOBs`方法返回BLOB字段值.
* 类名默认是`<TableName>WithBLOBs`,如果`<table>`配置了`domainObjectName`属性那么类名是`<domainObjectName>WithBLOBs`.
* 如果表中存在一个BLOB列将生成`hierarchical 模式`实体对象，如果表中存在多个BLOB列将生成`conditional 模式`实体对象。 BLOB记录类不会生`flat 模式` 实体对象

#### Example 类

* Example类用来处理MBG动态查询功能. 下列条件方法用于动态生成WHERE子句:
   * selectByExample
   * selectByExampleWithBLOBs
   * deleteByExample
   * countByExample
   * updateByExample
* Example类不继承任何实体对象
* 类名默认是`<TableName>Example`,如果`<table>`配置了`domainObjectName`属性那么类名是`<domainObjectName>Example`.
* 如果方法被启动Example类将生成任何*ByExample方法.注意:如果表中有非常多的字段该类可能很大,但 DAO生成的XML是比较小的. 如果您不需要使用动态WHERE子句,您可以禁用生成这些方法.

### SQL 映射文件
* MBG生成SQL映射文件遵循 MyBatis和IBatis DTD规范。
* MBG按照配置表生成SQL映射文件，在表的基础上还包含了不同的标签和属性配置。
* 表名就是SQL映射文件的命名控制。（前提是数据库支持schema 和 catalog）
* 你需要手工将生成`xxxMapper.xml` 加入到`mybatis-conf.xml`文件。 或者使用Spring的自动扫描。（注入）

#### 结果集(Result Map)

* resultMap元素（结果集对象）用于数据库表列映射Java对象的属性，不包括如下情况：
   * 任何列配置`<ignoreColumn>`属性将被会被忽略
   * 任何BLOB字段


* 配置`<columnOverride>`属性覆盖默认的属性和JDBC类型
* 对与自定义连接查询结果集**继承一个结果集**是一种常见的用法。对于其他连接查询也想使用（继承）该结果集。在MBG自动生成的时候需要配置前缀.详见`<table>`元素`alias`配置前缀，这样可以区分表中相同字段
* 如果`table`存在BLOB字段且配置了`enableSelectByExample`、`enableSelectByPrimaryKey`属性,MBG会生成BLOB结果集,table默认这两个配置都是true所以大部分情况下都会生成resultMap.


#### Where条件SQL语句
* This element contains a reusable where clause that is used by the "by example" methods. The where clause will not include any BLOB fields if they exist in the table. Most databases do not support BLOB fields in the WHERE clause.

* This element will be generated if any of the "by example" statements are enabled.


#### 其他
略，请参考官方文档。 官方文档这一部分写的也太烂了。


### Java 客户端对象

* MBG 生成几种类型的Java客户端对象，使得Java的客户端对象更容易与生成的XML进行交互
* 生成Java客户端对象是可选的。通过配置`<javaClientGenerator>` MyBatis 3 生成Java客户端对象类型：
   * XMLMAPPER 与 支持MyBatis3.x的映射


#### 通用DAO方法
根据表的特性，以及配置选项，Java客户端自动生成如下方法：
   * countByExample
   * deleteByPrimaryKey
   * deleteByExample
   * insert
   * insertSelective
   * selectByPrimaryKey
   * selectByExample
   * selectByExampleWithBLOBs
   * updateByPrimaryKey (否更新BLOB字段需要重写方法)
   * updateByPrimaryKeySelective (只更新参数类非空字段)
   * updateByExample (否更新BLOB字段需要重写方法)
   * updateByExampleSelective (只更新参数类非空字段)


对于包含BLOB的表,MBG通过生成不同的对象和方法使您更容易使用BLOB字段,是否忽略它们,这取决于具体情况.

#### XMLMAPPER 客户端
XMLMAPPER客户端是将接口方法映射到生成的XML映射文件中.例如,MBG自动生成的接口名为`MyTableMapper.`您可以如下使用该接口:
```
  SqlSession sqlSession = sqlSessionFactory.openSession();

  try {
    MyTableMapper mapper = sqlSession.getMapper(MyTableMapper.class);
    List<MyTable> allRecords = mapper.selectByExample(null);
  } finally {
    sqlSession.close();
  }
```

#### Example 用法

略，实际项目中很少用。 一般不会生成Example 对象。