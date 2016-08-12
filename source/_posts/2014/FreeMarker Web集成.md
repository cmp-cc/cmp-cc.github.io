----
title: FreeMarker Web集成
date: 2014-07-15 22:53:00
updated:
categories: 
- JavaWeb
- FreeMarker

tags:
- FreeMarker
----

**已更新**

FreeMarker 操作流程（其实开发中肯定不是这样的~~~！！）
* init : 在Servlet `init()`方法中创建`Configuration` 对象
* service: 在服务层填充Model，实例化模板
* controller: 指定输出到servlet PrintWriter中或者生成静态页面

> FreeMarker 提供如上行为(直接将ftl文件转换为文本信息，类似JSP)，我们只需要配置FreeMarker Servlet 进行渲染即可。
> 同样你可以实现自己的Servlet 操作FreeMarker的行为


## Servlet 集成

使用FreeMarker的Servlet创建一个简单的项目实例。

* 引入依赖
```
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>javax.servlet-api</artifactId>
            <version>3.1.0</version>
        </dependency>
        <dependency>
            <groupId>org.freemarker</groupId>
            <artifactId>freemarker</artifactId>
            <version>2.3.23</version>
        </dependency>  
```
* 目录基本结构

{%asset_img dce51fbe-0642-47b6-b35a-b5024d288632.png 目录结构%}
* 配置 `web.xml`
```
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
    version="3.0">
    <welcome-file-list>
        <welcome-file>index.html</welcome-file>
    </welcome-file-list>
    <!-- FREEMARKER SERVLET CONFIGURATION -->
    <servlet>
        <servlet-name>freemarker</servlet-name>
        <servlet-class>
            freemarker.ext.servlet.FreemarkerServlet
        </servlet-class>
        <init-param>
            <param-name>TemplatePath</param-name>
            <param-value>/WEB-INF/freemarker</param-value>
        </init-param>
        <init-param>
            <param-name>NoCache</param-name>
            <param-value>true</param-value>
        </init-param>
        <init-param>
            <param-name>ContentType</param-name>
            <param-value>text/html; charset=UTF-8</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>freemarker</servlet-name>
        <url-pattern>*.ftl</url-pattern>
    </servlet-mapping>
    <servlet>
        <servlet-name>HelloFreemarkerServlet</servlet-name>
        <servlet-class>org.freecode.ftl.HelloFreemarkerServlet
        </servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>HelloFreemarkerServlet</servlet-name>
        <url-pattern>/HelloFreemarkerServlet</url-pattern>
    </servlet-mapping>
</web-app>
```
* 目录基本结构

{%asset_img c1b083f7-d483-4112-a1a3-14c638c358be.png 目录结构%}
* 创建一个控制器 `HelloFreemarkerServlet`
```
package org.freecode.ftl;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
public class HelloFreemarkerServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;
  
  @Override
  protected void service(HttpServletRequest request,  HttpServletResponse response)
  throws ServletException, IOException {
    // Populated model in request attributes
    request.setAttribute("message", request.getParameter("message"));
    // Dispatch to Freemarker Servlet
    request.getRequestDispatcher("hello.ftl").forward(request, response);    
  }
}  
```
* FreeMarker 页面 `WEB-INF/freemarker/hello.ftl`
```
<html>
    <head>
        <title>Freemarker MVC Example</title>
    </head>
    <body>
        <form action="HelloFreemarkerServlet" method="post">
            Message: <input type="text" name="message"><br/>
            <button type="submit">Submit</button>
        </form>
        <br/>
        <#if message??>${message?html}</#if>
    </body>
</html>  
```
* 创建一个欢迎页面`index.html`
```
<html>
<head>
<title>Freemarker MVC Integration Test Page</title>
</head>
 
<body>
  <a href="HelloFreemarkerServlet">Servlet Example</a><br/>
</body>
</html>  
```
* 访问页面
```
http://localhost:8080/ftl_servlet
```


## Spring MVC 集成
* 引入依赖
```
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>javax.servlet-api</artifactId>
            <version>3.1.0</version>
        </dependency>
        <dependency>
            <groupId>org.freemarker</groupId>
            <artifactId>freemarker</artifactId>
            <version>2.3.23</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-webmvc</artifactId>
            <version>4.2.6.RELEASE</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context-support</artifactId>
            <version>4.2.6.RELEASE</version>
        </dependency>  
```
* 配置 `web.xml`
```
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
    version="3.0">
    
    <servlet>
           <servlet-name>springMvc</servlet-name>
        <servlet-class>
           org.springframework.web.servlet.DispatcherServlet
        </servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>classpath:applicationContext.xml</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>springMvc</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
</web-app>  
```
* 配置applicationContext.xml文件
**如下配置FreeMarker的最小配置**
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:context="http://www.springframework.org/schema/context"
	xmlns:mvc="http://www.springframework.org/schema/mvc"
	xsi:schemaLocation="http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc-4.2.xsd
		http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
		http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.2.xsd">

	<context:component-scan base-package="org.freecode.ftl" />
	<mvc:annotation-driven />
	
        <!-- FreeMarker的配置 -->
	<bean id="freemarkerConfig" class="org.springframework.web.servlet.view.freemarker.FreeMarkerConfigurer">
		<property name="templateLoaderPath" value="/WEB-INF/freemarker/" />
	</bean>
	
        <!-- 处理静态资源 -->
	<mvc:resources mapping="/*.html" location="/" />

         <!-- 配置 FreeMarker视图解析器 -->
	<bean id="viewResolver"  class="org.springframework.web.servlet.view.freemarker.FreeMarkerViewResolver">
		<property name="cache" value="true" />
		<property name="prefix" value="" />
		<property name="suffix" value=".ftl" />
	</bean>
	
</beans>
```
* 创建 HelloController
```
package org.freecode.ftl;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
@Controller
public class HelloController {
  @RequestMapping("/hello")
  public String hello(@ModelAttribute("message") String message) {
    return "hello-spring";
  }
  
  /**
   * 欢迎页面
   */
  @RequestMapping(value ="/", method =RequestMethod.GET)
  public String index(){
      return "redirect:/index.html";
  }
} 
```
* FreeMarker 页面 `WEB-INF/freemarker/hello-spring.ftl`
```
<html>
    <head>
        <title>Freemarker MVC Example</title>
    </head>
    <body>
        <form action="hello" method="post">
            Message: <input type="text" name="message"><br/>
            <button type="submit">Submit</button>
        </form>
        <br/>
        <#if message??>${message?html}</#if>
    </body>
</html>  
```
* 欢迎页面 index.html 
```
<html>
<head>
<title>Freemarker MVC Integration Test Page</title>
</head>
 
<body>
    <a href="hello">Spring MVC Example</a><br/>
</body>
</html>  
```

### FreeMarker 详细配置

**如下是一个详细Spring MVC 集成FreeMarker的详细配置，**
```
    <!-- FreeMarker的配置 -->
    <bean id="freeMarkerConfigurer"  class="org.springframework.web.servlet.view.freemarker.FreeMarkerConfigurer">
        <property name="templateLoaderPaths" value="/WEB-INF/freemarker/" />
        <property name="defaultEncoding" value="UTF-8" />
        <property name="freemarkerSettings">
            <props>
                <prop key="incompatible_improvements">2.3.23</prop>
                <prop key="template_exception_handler">rethrow</prop>
                <prop key="default_encoding">UTF-8</prop>  
                <prop key="template_update_delay">10</prop>
                <prop key="url_escaping_charset">UTF-8</prop>
                <prop key="locale">zh_CN</prop>
                <prop key="boolean_format">true,false</prop>
                <prop key="time_format">HH:mm:ss</prop>
                <prop key="datetime_format">yyyy-MM-dd HH:mm:ss</prop>
                <prop key="date_format">yyyy-MM-dd</prop>
                <prop key="number_format">#.##</prop>
                <prop key="whitespace_stripping">true</prop>
            </props>
        </property>
    </bean>
    <!-- 配置 FreeMarker视图解析器 -->
    <bean id="viewResolver"  class="org.springframework.web.servlet.view.freemarker.FreeMarkerViewResolver">
        <property name="viewClass"
            value="org.springframework.web.servlet.view.freemarker.FreeMarkerView"></property>
        <property name="cache" value="false" />
        <property name="prefix" value="" />
        <property name="suffix" value=".ftl" /><!--可为空 -->
        <property name="contentType" value="text/html;charset=utf-8" />
        <property name="exposeRequestAttributes" value="true" />
        <property name="exposeSessionAttributes" value="true" />
        <property name="exposeSpringMacroHelpers" value="true" />
    </bean>  
```
