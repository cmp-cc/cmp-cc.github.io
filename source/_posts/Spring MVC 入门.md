----
title: Spring MVC 入门
date: 2014-06-10 16:53:00
updated:
categories: 
- JavaWeb
- Spring MVC
tags:
- Spring MVC
----

Struts2 用的人越来越少了呀~~~  Spring MVC的设计更加超前，使用也更加便利。




## Spring MVC 简介
* Spring MVC 是Spring Framework 中用于快速开发Web应用程序的一个模块。
* 采用MVC设计模式（模型-视图-控制器）。

## Spring 优势
* Spring MVC 采用调用Servlet中一个控制方法，控制转发到一个视图。（你不必编写多个Servlet。）
* Spring MVC 实例化控制器类，并自动填充用户输入bean。（不需要配置XML映射、不需要使用request.paremxxx 获取请求信息）
* Spring MVC 重新编辑XML配置文件，不需要重新编译或重启应用程序。
* Spring MVC 自动绑定正确类型的用户输入信息。eg：Spring MVC可以自动解析字符串并设置float类型或double 类型。
* Spring MVC 可以验证用户输入，如果输入失败可以重定向表单。可以使用声明和编码的方式。Spring MVC内置任务验证。
* Spring MVC 支持国际化和本地化。（你可以显示用户区域多国家语言）
* Spring MVC 支持多视图技术。可以是JSP、FreeMarker、Velocity、JSON数据。
* Spring MVC 作为Spring 的一部分也算是一种优势把。

> 以上几乎所有优势Struts2 都具备。 只是Spring MVC 实现方式更加简单，Struts2 同样优秀而已。


## Spring MVC 入门
### Spring MVC 入口 （DispatcherServlet）
#### 配置入口
**配置`web.xml`文件，增加Spring MVC 调度Servlet入口，全称为：`org.springframework.web.servlte.DispatcherServlet`.如下配置：**
```
<servlet>
    <servlet-name>springmvc</servlet-name>
    <servlet-class
        org.springframework.web.servlet.DispatcherServlet
    </servlet-class>
    <load-on-startup>1</load-on-startup>    
</servlet>

<servlet-mapping>
    <servlet-name>springmvc</servlet-name>
    <!-- map all requests to the DispatcherServlet -->
    <url-pattern>/</url-pattern>
</servlet-mapping>
```
> `load-on-startup`元素是可选的，如果存在，在启动应用程序时，它会在加载Servlet并调用init()方法。如果不存，当第一次请求Servlet时被加载。

#### 默认配置文件方式
**当其调度 Servlet 将使用Spring MVC的许多默认组件，此外，在初始化时，它会寻找应用程序WEB_INF目录中的配置文件，XML文件的名称必须符合如下模式:**
```
servletName-servlet.xml
```
> 如果定义一个部署描述的Servlet，且名为为SringMVC,那么需要用SpringMVC-servlet.xml文件在应用程序WEB-INF目录下
#### 自定义配置文件方式
同样，你可以告诉调度器servlet 在哪里找到Spring MVC配置文件。 您可以通过servlet声明，通过init-param元素做到这一点。如下修改默认名称和位置：
```
<servlet>
    <servlet-name>springmvc</servlet-name>
    <servlet-class>
        org.springframework.web.servlet.DispatcherServlet
    </servlet-class>
    <init-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>/WEB-INF/config/simple-config.xml</param-value>
    </init-param>
    <load-on-startup>1</load-on-startup>    
</servlet>
```

---
### 控制器接口

### Spring MVC 应用

**如下演示如何构建一个Spring MVC 项目的详细步骤**

#### 下载依赖

* 将如下依赖引入`WEB-INF\lib`目录下
   * spring-core
   * spring-beans
   * spring-context
   * spring-expression
   * spring-web
   * spring-webmvc
   * commons-looging
* 使用Maven构建项目
```
		<dependency>
			<groupId>javax.servlet</groupId>
			<artifactId>javax.servlet-api</artifactId>
			<version>3.1.0</version>
			<scope>provided</scope>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-webmvc</artifactId>
			<version>4.0.4.RELEASE</version>
		</dependency>
```
> `spring-webmvc` 会将相关依赖引入。


#### 配置web.xml和Spring MVC配置文件


##### 配置 web.xml
**同上一样，部署描述文件(web.xml) 配置如下**
```
<?xml version="1.0" encoding="UTF-8"?>
<web-app version="3.1" 
    xmlns="http://xmlns.jcp.org/xml/ns/javaee" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee 
http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd">

    <servlet>
        <servlet-name>springmvc</servlet-name>
        <servlet-class
            org.springframework.web.servlet.DispatcherServlet
        </servlet-class>
        <load-on-startup>1</load-on-startup>    
    </servlet>

    <servlet-mapping>
        <servlet-name>springmvc</servlet-name>
        <!-- map all requests to the DispatcherServlet -->
        <url-pattern>/</url-pattern>
    </servlet-mapping>

</web-app>
```
> 这里，你告诉Servlet/JSP容器(应用程序)使用Spring MVC 调度servlet映射所有URL。（通过`url-pattern`元素设置为`\`）
> 而且，配置Spring MVC配置文件必须遵守约定（命名约定 + 将配置文件放置`/WEB-INF`目录中）。

##### 配置Spring MVC配置文件
**配置springmvc-servlet.xml 文件，如下**
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.springframework.org/schema/beans
  http://www.springframework.org/schema/beans/spring-beans.xsd">
       
    <bean name="/input-product"
        class="controller.InputProductController"/>
    <bean name="/save-product" 
        class="controller.SaveProductController"/>

</beans>
```
> 在这里声明了两个控制器类，InputProductController 和 SaveProductController,映射路径为`/input-product` 和 `/save-product`。



#### 控制器
InputProductController 和 SaveProductController 为两个**旧式**的控制器,通过实现`Controller`接口,返回视图模型,如下：
> 之所以称为`旧式控制器`，是因为:这是spring2.5最初实现spring mvc 的方式。
> 现在大多数使用的控制器方式是基于注解的（Annotation-Based Controllers）。

##### InputProductController 类

```
package controller;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

public class InputProductController implements Controller {

    private static final Log logger = LogFactory.getLog(InputProductController.class);

    @Override
    public ModelAndView handleRequest(HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        logger.info("InputProductController called");
        return new ModelAndView("/WEB-INF/jsp/ProductForm.jsp");
    }
}
```
> InputProductController类中的handleRequest 方法返回一个ModelAndView对象，ModelAndView对象包含一个视图，不包含模型。这个实例，请求转发到`/WEB-INF/jsp/ProductForm.jsp`页面。

##### SaveProductController 类
```
package controller;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;
import domain.Product;
import form.ProductForm;

public class SaveProductController implements Controller {

    private static final Log logger = LogFactory
            .getLog(SaveProductController.class);

    @Override
    public ModelAndView handleRequest(HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        logger.info("SaveProductController called");
        ProductForm productForm = new ProductForm();
        // populate action properties
        productForm.setName(request.getParameter("name"));
        productForm.setDescription(request.getParameter(
                "description"));
        productForm.setPrice(request.getParameter("price"));

        // create model
        Product product = new Product();
        product.setName(productForm.getName());
        product.setDescription(productForm.getDescription());
        try {
            product.setPrice(
                    Float.parseFloat(productForm.getPrice()));
        } catch (NumberFormatException e) {
        }

        // insert code to save Product

        return new ModelAndView("/WEB-INF/jsp/ProductDetails.jsp", 
                "product", product);
    }
}
```
> SaveProductController类中handleRequest方法 创建一个ProductForm对象设置请求参数（request parameters）。
> 创建一个Product对象设置属性值。
> 【Spring MVC有更加方便的处理请求参数和处理Bean对象的方法，这里我们使用最原始的。】
>  返回ModelAndView对象包含视图路径、模型名称、模型。返回视图结果。




#### 视图 (View)
> 通常会将JSP 页面存储在`/WEB-INF/`下面,防止外部直接访问。
这里包含两个JSP页面，ProductForm.jsp和ProductDetails.jsp

##### ProductForm.jsp 页面

```
<!DOCTYPE html>
<html>
<head>
<title>Add Product Form</title>
<style type="text/css">@import url(css/main.css);</style>
</head>
<body>

<div id="global">
<form action="save-product" method="post">
    <fieldset>
        <legend>Add a product</legend>
        <label for="name">Product Name: </label>
        <input type="text" id="name" name="name" value="" 
            tabindex="1">
        <label for="description">Description: </label>
        <input type="text" id="description" name="description" 
            tabindex="2">
        <label for="price">Price: </label>
        <input type="text" id="price" name="price" tabindex="3">
        <div id="buttons">
            <label for="dummy"> </label>
            <input id="reset" type="reset" tabindex="4">
            <input id="submit" type="submit" tabindex="5" 
                value="Add Product">
        </div>
    </fieldset>
</form>
</div>
</body>
</html>
```

##### ProductDetails.jsp 页面
```
<!DOCTYPE html>
<html>
<head>
<title>Save Product</title>
<style type="text/css">@import url(css/main.css);</style>
</head>
<body>
<div id="global">
    <h4>The product has been saved.</h4>
    <p>
        <h5>Details:</h5>
        Product Name: ${product.name}<br/>
        Description: ${product.description}<br/>
        Price: $${product.price}
    </p>
</div>
</body>
</html>
```
> ProductDetails.jsp 页面显示，通过EL表达式访问Product域模型对象。

##### 测试应用
在浏览器访问如下URL
```
http://localhost:8080/your-project-name/input-product
```
> xxxx

##### 视图解析器(View Resolver)
在Spring MVC中视图解析器（View Resolver）负责视图解析映射。我们可以在配置文件中声明`viewResolver bean`，参考如下配置：
```
<bean id="viewResolver" class="org.springframework.web.servlet.
view.InternalResourceViewResolver">
    <property name="prefix" value="/WEB-INF/jsp/"/>
    <property name="suffix" value=".jsp"/>
</bean>
```
> `View Resolver` 解决前缀和后缀问题
> 如上`View Resolver Bean`配置两个属性，`prefix (前缀)` 和 `suffix （后缀）`， 这样将缩短视图路径，而不需要再写全路径`/WEB-INF/jsp/myPage.jsp`，只需要写`myPage`。

#### 修改项目
**将Spring MVC 配置文件重命名为`springmvc-config.xml`,并移至`/WEB-INF/config`目录，我们需要告诉部署描述（web.xml）文件。如下：**
```
<?xml version="1.0" encoding="UTF-8"?>
<web-app version="3.1" 
    xmlns="http://xmlns.jcp.org/xml/ns/javaee" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd">   

    <servlet>
        <servlet-name>springmvc</servlet-name>
        <servlet-class>
            org.springframework.web.servlet.DispatcherServlet
        </servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>
                /WEB-INF/config/springmvc-config.xml
            </param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>    
    </servlet>

    <servlet-mapping>
        <servlet-name>springmvc</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
</web-app>
```

**修改Spring MVC 配置文件，增加`View Resolver Bean`**
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.springframework.org/schema/beans
  http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean name="/input-product" 
            class="controller.InputProductController"/>
    <bean name="/save-product"  
            class="controller.SaveProductController"/>
    <bean id="viewResolver" 
            class="org.springframework.web.servlet.view.
InternalResourceViewResolver">
        <property name="prefix" value="/WEB-INF/jsp/"/>
        <property name="suffix" value=".jsp"/>
    </bean>
</beans>
```
**通过如下访问应用程序**
```
http://localhost:8080/your-project-name/input-product
```

#### 总结
* 介绍Spring MVC
* 如何构建一个简单的Spring MVC Web 项目


 