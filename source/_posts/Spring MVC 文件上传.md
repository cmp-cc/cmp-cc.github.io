----
title: Spring MVC 文件上传
date: 2014-07-15 13:53:00
updated:
categories: 

tags:
- Spring MVC
----
之间学过Servlet 文件上传 ，然后Struts2 的文件上传，现在Spring MVC文件上，这就是所谓的技术更新？
之间看过一篇文档说Spring提供的文件上传快一些？



Spring MVC 有两种方法解决文件上传问题
* 使用`Apache Commons FileUpload` 组件
* 采用Servlet3.0 或更高版本。
> Serlvet3.0 内置文件上传功能，不需要引入`Commons FileUpload`组件,貌似很少人用内置的,还是错觉 - -!

## 客户端设置
想要文件上传，必须将HTML中`form`元素的`enctype`属性设置为`multipart/form-data`,参考如下：
```
<form action="action" enctype="multipart/form-data" method="post">
    <input type="file" name="fieldName"/>
    <input type="submit" value="Upload"/>
</form>
```
> `form`表单必须包含至少一个类型为`file`的`input`元素

## MultipartFile 接口

Spring MVC 处理文件非常容易，上传文件的所有信息被包裹在`MultipartFile`中。（这点，我认为比Struts2 优雅）
我们需要在域模型（Model） 中引入`MultipartFile`属性

`MultipartFile` 接口，参考方法详细列表
方法 | 描述
--- | ---
getBytes| 返回文件的字节数组
getContentType | 返回文件的内容类型
getInputStream | 返回文件内容的InputStream
getName	| 返回form表单中name的名称
getOriginalFilename |返回原始文件的名称。
getSize|	返回一个long类型的文件字节大小
isEmpty	|上传文件是否为空 
tranferTo|	将上传文件保存为一个`java.io.File`

* `tranferTo` 方法演示，保存上传文件
```
File file = new File(...);
multipartFile.transferTo(file);
```
## Commons FileUpload 文件上传

* 引入 Commons FileUpload 组件
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
			<version>4.0.0.RELEASE</version>
		</dependency>
                <dependency>
			<groupId>javax.servlet</groupId>
			<artifactId>jstl</artifactId>
			<version>1.2</version>
			<scope>runtime</scope>
		</dependency>
                <!-- commons fileupload -->
	   <dependency>
			<groupId>commons-fileupload</groupId>
			<artifactId>commons-fileupload</artifactId>
			<version>1.3.1</version>
		</dependency>
```
> `commons-fileupload` 默认引入`commons-io` 

* Spring MVC 配置`multipartResolver` Bean
```
<bean id="multipartResolver"   class="org.springframework.web.multipart.commons.CommonsMultipartResolver">
    <property name="maxUploadSize" value="2000000"/>
</bean>
```
* 域模型（请求 Model） 
`Product Model`包含一个`List<MultipartFile>`文件列表。
```
package domain;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import org.springframework.web.multipart.MultipartFile;

public class Product implements Serializable {
    private String name;

    private String description;
    private BigDeciimal price;
    private List<MultipartFile> images;

    // ... getter/setter
}
```
* 控制器（Controller）
```
package controller;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.multipart.MultipartFile;
import domain.Product;

@Controller
public class ProductController {

    private static final Log logger = 
        LogFactory.getLog(ProductController.class);

    @RequestMapping(value = "/input-product")
    public String inputProduct(Model model) {
        model.addAttribute("product", new Product());
        return "ProductForm";
    }

    @RequestMapping(value = "/save-product")
    public String saveProduct(HttpServletRequest servletRequest,
            @ModelAttribute Product product, 
            BindingResult bindingResult, Model model) {

        List<MultipartFile> files = product.getImages();
        List<String> fileNames = new ArrayList<String>();
        if (null != files && files.size() > 0) {
            for (MultipartFile multipartFile : files) {

                String fileName = multipartFile.getOriginalFilename();
                fileNames.add(fileName);

                File imageFile = new File(servletRequest.getServletContext()
                        .getRealPath("/image"), fileName);
                try {
                    multipartFile.transferTo(imageFile);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return "ProductDetails";
    }
}
```
* Spring MVC 配置文件配置
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:p="http://www.springframework.org/schema/p"
    xmlns:mvc="http://www.springframework.org/schema/mvc" 
    xmlns:context="http://www.springframework.org/schema/context"
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/mvc
        http://www.springframework.org/schema/mvc/spring-mvc.xsd     
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-
context.xsd">

    <context:component-scan base-package="controller" />
    <mvc:annotation-driven />
    <mvc:resources mapping="/css/**" location="/css/" />
    <mvc:resources mapping="/*.html" location="/" />
    <mvc:resources mapping="/image/**" location="/image/" />

    <bean id="viewResolver"
            class="org.springframework.web.servlet.view.InternalResourceViewResolver">
        <property name="prefix" value="/WEB-INF/jsp/" />
        <property name="suffix" value=".jsp" />
    </bean>
	
    <bean id="multipartResolver" 
    		class="org.springframework.web.multipart.commons.CommonsMultipartResolver">
        <property name="maxUploadSize" value="5000000000"/>
    </bean>
</beans>
```
> 在`CommonsMultipartResolver`Bean注入`maxUploadSize`属性，限定最大上传文件，如果没有这个值，将没有最大限制（无穷大）
> 设置文件没有大小限制，并不意味可以上传任意大小的文件，如果一个文件非常大，上传会花费很长时间，甚至到服务器超时。
> 处理非常大的文件，可以考虑`HTML5 File API`,使用切片文件，分别上传。

* JSP 页面
   **文件上传页面和信息显示页面**
   * ProductForm.jsp 页面
   ```
   <%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
   <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
   <!DOCTYPE html>
   <html>
   <head>
   <title>Add Product Form</title>
   <style type="text/css">@import url("<c:url value="/css/main.css"/>");</style>
   </head>
   <body>
   
   <div id="global">
   <form:form commandName="product" action="save-product" method="post" enctype="multipart/form-data">
       <fieldset>
           <legend>Add a product</legend>
           <p>
               <label for="name">Product Name: </label>
               <form:input id="name" path="name" cssErrorClass="error"/>
               <form:errors path="name" cssClass="error"/>
           </p>
           <p>
               <label for="description">Description: </label>
               <form:input id="description" path="description"/>
           </p>
           <p>
               <label for="price">Price: </label>
               <form:input id="price" path="price" cssErrorClass="error"/>
           </p>
           <p>
               <label for="image">Product Image: </label>
               <input type="file" name="images[0]"/>
           </p>
           <p id="buttons">
               <input id="reset" type="reset" tabindex="4">
               <input id="submit" type="submit" tabindex="5" value="Add Product">
           </p>
       </fieldset>
   </form:form>
   </div>
   </body>
   </html>
   ```
     > 该页面将跳转至`ProductDetails.jsp`页面
   * ProductDetails.jsp 页面
   ```
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
   <!DOCTYPE html>
   <html>
   <head>
   <title>Save Product</title>
   <style type="text/css">@import url("<c:url value="/css/main.css"/>");</style>
   </head>
   <body>
   <div id="global">
       <h4>The product has been saved.</h4>
       <p>
           <h5>Details:</h5>
           Product Name: ${product.name}<br/>
           Description: ${product.description}<br/>
           Price: $${product.price}
           <p>Following files are uploaded successfully.</p>
           <ol>
           <c:forEach items="${product.images}" var="image">
               <li>${image.originalFilename}
               <img width="100" src="<c:url value="/image/"/>
               ${image.originalFilename}"/>
               </li>
           </c:forEach>
           </ol>
       </p>
   </div>
   </body>
   </html>
   ```
* 测试文件上传
```
http://localhost:8080/your-project-name/input-product
```
   
## Servlet 3 文件上传
**在上一个实例的基础上，修改**

* 不需要在引入`Commons File` 组件
* 需要使用`javax.servlet.http.Part` 接口，必须使用`@MultipartConfig`注解声明文件上传。

`@MultipartConfig`  注解属性列表详情。（所有属性均可选）


属性 | 描述
--- | ---
max-file-size | 上传文件最大大小。超过指定值的文件将被拒绝(抛出IllegalStateException异常)。默认值为-1，表示无穷大。
max-request-size| 最大文件请求大小,超过指定值时,抛出IllegalStateException异常。默认值为-1,表示无穷大。
location | 指定上传文件存放目录。当指定location后，我们调用Part.Writer(String fileName)方法时，可以不指定文件路径。如果指定路径，将覆盖location路径。
file-size-threshold| 当文件大小超过指定阈值大小时，将写入磁盘。默认值为0，任意大小的文件作为临时文件写入磁盘。

* web.xml 配置 MultipartConfig

**DispatcherServlet**处理所有的Action请求，你不需要在Spring MVC Controller (Serlvet)上添加`@MultipartConfig`注释，配置如下即可。
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
			<param-value>/WEB-INF/config/springmvc-config.xml</param-value>
		</init-param>
        <load-on-startup>1</load-on-startup>
		<multipart-config>
		    <max-file-size>20848820</max-file-size>
		    <max-request-size>418018841</max-request-size>
		    <file-size-threshold>1048576</file-size-threshold>
		</multipart-config>            
	</servlet>

    <servlet-mapping>
        <servlet-name>springmvc</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
</web-app>
```
> 可以不进行`multipart-config`配置，它将使用默认值。
* Spring MVC 配置文件中配置`multipart`
```
<bean id="multipartResolver" 
        class="org.springframework.web.multipart.support.StandardServletMultipartResolver">
</bean>
```
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:p="http://www.springframework.org/schema/p"
    xmlns:mvc="http://www.springframework.org/schema/mvc"
    xmlns:context="http://www.springframework.org/schema/context"	
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/mvc
        http://www.springframework.org/schema/mvc/spring-mvc.xsd     
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-
context.xsd">

    <context:component-scan base-package="controller" />
    <mvc:annotation-driven />

    <mvc:resources mapping="/css/**" location="/css/" />
    <mvc:resources mapping="/*.html" location="/" />
    <mvc:resources mapping="/image/**" location="/image/" />
    <mvc:resources mapping="/file/**" location="/file/" />

    <bean id="viewResolver"
        class="org.springframework.web.servlet.view.
InternalResourceViewResolver">
        <property name="prefix" value="/WEB-INF/jsp/" />
        <property name="suffix" value=".jsp" />
    </bean>
	
    <bean id="multipartResolver"
        class="org.springframework.web.multipart.support.
StandardServletMultipartResolver">
    </bean>
</beans>
```
> `multipart` 有多种实现方式，请参考官方文档。
* 测试
```
http://localhost:8080/your-project-name/input-product
```

## 总结
* 使用Spring MVC 进行文件上传，无论是`Commons File`组件还是Servlet内置。`MultipartFile`接口都将包裹文件信息。