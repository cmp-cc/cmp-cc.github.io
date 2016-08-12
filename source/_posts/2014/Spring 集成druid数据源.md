----
title: Spring 集成druid数据源
date: 2014-06-11 00:53:00
updated:
categories: 

- JavaWeb
- Spring

tags:
- Spring
----

Druid 是Alibaba的一个数据库连接池，相比Druid 相比C3p0 或 DBCP 更加高效，Druid的常规配置可参考如下。


* pom.xml 引入`druid`

* Spring Bean.xml
```
    <bean name="dataSource" class="com.alibaba.druid.pool.DruidDataSource" init-method="init" destroy-method="close">
        <property name="url" value="${jdbc_url}" />
        <property name="username" value="${jdbc_username}" />
        <property name="password" value="${jdbc_password}" />
    
        <property name="initialSize" value="0" />        
        <property name="maxActive" value="20" />    
        <property name="maxIdle" value="20" />
        <property name="minIdle" value="0" />        
        <property name="maxWait" value="60000" />
        
        <property name="validationQuery" value="${validationQuery}" />
        <property name="testOnBorrow" value="false" />
        <property name="testOnReturn" value="false" />
        <property name="testWhileIdle" value="true" />
        <property name="timeBetweenEvictionRunsMillis" value="60000" />
        <property name="minEvictableIdleTimeMillis" value="25200000" />
        <property name="removeAbandoned" value="true" />
        <property name="removeAbandonedTimeout" value="1800" />
        <property name="logAbandoned" value="true" />
        <property name="filters" value="mergeStat" />
    </bean>


    <bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource" />
    </bean>  

   <context:property-placeholder location="classpath:config.properties" />  
```
* config.properties
```
jdbc_url=jdbc:oracle:druid_test:@localhost:1521:orcl
jdbc_username=root
jdbc_password=123456
```