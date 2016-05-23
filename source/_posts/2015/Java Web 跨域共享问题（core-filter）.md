----
title: Java Web 跨域共享问题（core-filter）
date: 2015-01-11 18:10:00
updated:
categories: 
- Java Web
tags:
- Java Web
----

需要部分前后端分离，首先要解决跨越问题，虽然可以使用`jsoup`，但无法解决ajax 文件上传问题（iframe方法是一个例外）。

**使用`jsoup script` 解决跨域问题有点..... 不爽**


参考：http://software.dzhuvinov.com/cors-filter.html 提供的解决方案


**如下演示如何使用`core-filter`来解决跨域问题， 不是在每一个`action reqeust` 设置允许跨域**

## Maven 引入依赖
```
<dependency>
	<groupId>com.thetransactioncompany</groupId>
	<artifactId>cors-filter</artifactId>
	<version>2.5</version>
</dependency>
<dependency>
	<groupId>com.thetransactioncompany</groupId>
	<artifactId>java-property-utils</artifactId>
	<version>1.10</version>
</dependency>
```
## 添加Cores 配置到web.xml
XML 声明CORS过滤
```
<filter>
    <filter-name>CORS</filter-name>
    <filter-class>com.thetransactioncompany.cors.CORSFilter</filter-class>
</filter>
```
或者使用变种的CORS过滤器，它可以自动检测更改配置文件，并重新配置CORS过滤器，声明如下:
```
<filter>
    <filter-name>CORS</filter-name>
    <filter-class>com.thetransactioncompany.cors.autoreconf.AutoReconfigurableCORSFilter</filter-class>
</filter>
```
声明过滤器Mapper ，说明哪些URL启动跨越请求( cross-domain-request ),如下 作用于所有URL:
```
<filter-mapping>
        <filter-name>CORS</filter-name>
        <url-pattern>/*</url-pattern>
</filter-mapping>
```
> 注意：默认情况是CORS Filter采用public access的跨源资源共享策略，允许通过包括用户凭据/cookies在内安全机制的全部跨站请求。这一默认配置其实适用于大多数情况，因为CORS本来就不是以增强服务端安全性为主要目标的；CORS的基本意向是保护浏览器端的数据安全，即保护浏览器上合法运行的JavaScript应用及其用户凭据信息例如cookies数据不会泄露。





## web.xml 完整实例
```
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://java.sun.com/xml/ns/j2ee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd"
         version="2.4">

	<display-name>CORS demo</display-name>
	
	<description>Simple CORS demo</description>
	
	<servlet>
		<!-- Some servlet -->
		<servlet-name>HelloWorld</servlet-name>
		<servlet-class>com.thetransactioncompany.cors.demo.HelloWorldServlet</servlet-class>
	</servlet>
	
	<servlet-mapping>
		<!-- Some servlet mapping -->
		<servlet-name>HelloWorld</servlet-name>
		<url-pattern>/cors-resource.html</url-pattern>
	</servlet-mapping>
	
	<filter>
		<!-- The CORS filter with parameters -->
		<filter-name>CORS</filter-name>
		<filter-class>com.thetransactioncompany.cors.CORSFilter</filter-class>
		
		<!-- Note: All parameters are options, if omitted the CORS 
		     Filter will fall back to the respective default values.
		  -->
		<init-param>
			<param-name>cors.allowGenericHttpRequests</param-name>
			<param-value>true</param-value>
		</init-param>
		
		<init-param>
			<param-name>cors.allowOrigin</param-name>
			<param-value>*</param-value>
		</init-param>
		
		<init-param>
			<param-name>cors.allowSubdomains</param-name>
			<param-value>false</param-value>
		</init-param>
		
		<init-param>
			<param-name>cors.supportedMethods</param-name>
			<param-value>GET, HEAD, POST, OPTIONS</param-value>
		</init-param>
		
		<init-param>
			<param-name>cors.supportedHeaders</param-name>
			<param-value>*</param-value>
		</init-param>
		
		<init-param>
			<param-name>cors.exposedHeaders</param-name>
			<param-value>X-Test-1, X-Test-2</param-value>
		</init-param>
		
		<init-param>
			<param-name>cors.supportsCredentials</param-name>
			<param-value>true</param-value>
		</init-param>
		
		<init-param>
			<param-name>cors.maxAge</param-name>
			<param-value>3600</param-value>
		</init-param>

	</filter>

	<filter-mapping>
		<!-- CORS Filter mapping -->
		<filter-name>CORS</filter-name>
		<url-pattern>/cors-resource.html</url-pattern>
	</filter-mapping>

</web-app>

```

参考：
http://www.2cto.com/kf/201604/503408.html