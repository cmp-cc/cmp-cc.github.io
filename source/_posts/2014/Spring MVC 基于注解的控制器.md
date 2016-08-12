----
title: Spring MVC 基于注解的控制器
date: 2014-07-14 16:53:00
updated: 
categories: 
- JavaWeb
- Spring MVC

tags:
- Spring MVC
----

Spring MVC 提供了两种配置Controller（控制器）的方式
* 基于XML的方式。（Spring 2.5 引入）
* 基于Annotation的方式。



## Spring MVC Annotation 类型
使用基于注解的Controller有几个（两个）优点：
* 1、一个控制器类可以处理多个actions,(相比之下，实现Controller接口的控制器只能处理一个action)，也就是说,相关的actions可以写在同一个控制器类，从而减少应用程序类的数量。
* 2、基于注解的控制器请求映射文件不需要存储到配置文件中，使用`RequestMapping`注解类型标注请求处理（request-handling）方法。

Spring MVC 有两个比较重要的注解类型，Controller 和 RequestMapping 注解类型，和一些不太热门的注解类型。


### Controller 注解类型
`org.springframework.stereotype.Controller`注解类型标注一个Java类，告诉Spring 该类是一个控制器。注解@Controller 实例如下：
```
package com.example.controller;

import org.springframework.stereotype;
...

@Controller
public class CustomerController {
    
    // request-handling methods here

}
```

Spring 使用扫描机制，查找应用程序中所有基于注解的控制器，为了保证Spring能够找到控制器，需要做两件事：
* 1、在Spring MVC配置文件中声明`spring-context` Schema
```
<beans 
    ...
    xmlns:context="http://www.springframework.org/schema/context"
    ... 
>
```
* 2、其次在配置文件中使用`<component-scan/>`元素
```
<context:component-scan base-package="basePackage"/>
```

整合配置文件显示如下：
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:p="http://www.springframework.org/schema/p"
    xmlns:context="http://www.springframework.org/schema/context"
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context.xsd">

    <context:component-scan base-package="com.example.controller"/>

</beans>
```

### RequestMapping 注解类型

在控制器类中写请求处理方法，对于每一个将要处理的Action，你要告诉Spring，使用哪些方法处理哪些Action，可以使用`org.springframework.web.bind.annotation.RequestMapping`注解类型映射URI到Action 方法。

RequestMapping 注解类型，顾名思义，用于映射一个请求到一个方法（请求处理方法）。 可以使用@RequestMapping注解到一个方法或一个类。

如下控制器类中实现RequestMapping类型注解方法的实例。
```
package com.example.controller;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
...

@Controller
public class CustomerController {
    
    @RequestMapping(value = "/input-customer")
    public String inputCustomer() {

        // do something here

        return "CustomerForm";
    }
}
```
> RequestMapping 注解中使用value属性指定URI映射到一个方法。如上使用`http://domain/context/input-customer`访问这个Action。

value 是@RequestMapping 默认的属性，如果使用**唯一属性**，可以省略value属性名称，如下等价。
```
@RequestMapping(value = "/input-customer")
@RequestMapping("/input-customer")
```
@RequestMapping 除value以外还有其他属性值，如下processOrder方法只能调用HTTP POST 和 PUT方法。
```
  @RequestMapping(value="/process-order",
            method={RequestMethod.POST, RequestMethod.PUT})
    public String processOrder() {
    
        // do something here

        return "OrderForm";
    }
```
如果method属性不存在，请求处理方法将处理所有HTTP方法。
同样你可以指定HTTP唯一的请求方法。
```
@RequestMapping(value="/process-order", method=RequestMethod.POST)
```
@RequestMapping 类型可以标注一个控制器类,这种情况，方法级别的请求映射将被视为响度与类级别的请求，参考如下：deleteCustomer方法
```
...
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
@RequestMapping("/customer")
public class CustomerController {

    @RequestMapping(value="/delete",
            method={RequestMethod.POST, RequestMethod.PUT})
    public String deleteCustomer() {

        // do something here

        return ...;
    }
```
> 由于控制器类映射使用`/customer` 和 deleteCustomer方法使用`/delete`,该Action方法使用`http://domain/context/customer/delete`访问。

### 写请求处理方法
一个请求处理方法（action）可以有多个参数类型，以及各种返回类型。如下实例，你可能需要在方法中访问HttpSession对象，需要添加HttpSession到形参中，Spring将传递正确的对象类型：
```
@RequestMapping("/uri")
public String myMethod(HttpSession session) {
    ...
    session.addAttribute(key, value);
    ...
}
```
或者，你需要访问 `Locale`和`HttpServletRequest`对象,你需要在方法中包含这两个参数:
```
@RequestMapping("/uri")
public String myOtherMethod(HttpServletRequest request, 
        Locale locale) {
    ...
    // access Locale and HttpServletRequest here
    ...
}
```

---

如下是可以出现在请求处理方法参数的参数类型列表：
* `javax.servlet.ServletRequest` or `javax.servlet.http.HttpServletRequest`
* `javax.servlet.ServletResponse` or `javax.servlet.http.HttpServletResponse`
* `javax.servlet.http.HttpSession`
* `org.springframework.web.context.request.WebRequest` or `org.springframework.web.context.request.NativeWebRequest`
* `java.util.Locale`
* `java.io.InputStream` or `java.io.Reader`
* `java.io.OutputStream` or `java.io.Writer`
* `java.security.Principal`
* `HttpEntity<?> parameters`
* `java.util.Map` / `org.springframework.ui.Model` / `org.springframework.ui.ModelMap`
* `org.springframework.web.servlet.mvc.support.RedirectAttributes`
* `org.springframework.validation.Errors` / `org.springframework.validation.BindingResult`
* `Command` or `form objects`
* `org.springframework.web.bind.support.SessionStatus`
* `org.springframework.web.util.UriComponentsBuilder`
* Types annotated with `@PathVariable`, `@MatrixVariable`, `@RequestParam`, `@RequestHeader`, `@RequestBody`, or `@RequestPart`.

---

`org.springframework.ui.Model`类型是一个特别重要的类型，它包含一个`Map`，每次请求处理方法被调用，Spring MVC 创建一个`Model`对象，并填充这个`Map`和潜在对象。

请求处理方法可以返回这些对象之一：
* 一个`ModelAndView`对象
* 一个`Model`对象
* 一个`Map`,包含model属性
* 一个`View`对象
* 一个`String(字符串)`，表示视图逻辑名称。
* `void`
* 一个`HttpEntity`或`ResponseEntity`对象，提供访问Servlet 响应(Servlet response)的HTTP 请求头(http header)和请求内容(http contents)
* 一个`Callable`
* 一个`DeferredResult`
* 其他任何返回类型. 在这种情况下, 返回值将被视为model属性到一个view


### 使用基于注解的控制器
* Maven 引入Spring MVC 依赖
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
* 部署描述文件（web.xml）配置Spring MVC 调度 Servlet 入口 和 Spring MVC配置文件路径。
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
        <!--URL模式为/表示所有请求，包含静态资源请求 -->
        <url-pattern>/</url-pattern>
    </servlet-mapping>
</web-app>
```
* 配置Spring MVC 配置文件（springmvc-config.xml）。
> 为了让静态资源得到处理,需要在Spring MVC 配置文件中添加多个`<resources/>`
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
        http://www.springframework.org/schema/context/spring-context.xsd">
    <!-- 告诉Spring MVC Controller 包的路径 -->
    <context:component-scan base-package="controller"/>
    <!-- 启动注解，允许SpringMVC 调度静态资源 -->
    <mvc:annotation-driven/>

    <!-- 处理静态资源，告诉Spring MVC 哪些静态资源需要servlet 调度 -->
    <!-- 声明/CSS目录下的所有文件是可见的 -->
    <mvc:resources mapping="/css/**" location="/css/"/>
    <!-- 在应用程序中的所有目录允许显示.html文件 -->
    <mvc:resources mapping="/*.html" location="/"/>
    
     <!-- 访问路径前缀后缀处理 -->
    <bean id="viewResolver"  class="org.springframework.web.servlet.view.InternalResourceViewResolver">
        <property name="prefix" value="/WEB-INF/jsp/"/>
        <property name="suffix" value=".jsp"/>
    </bean>
</beans>
```
> 如果没有`<annotation-driven/>`，`<mvc:resources/>`元素防止调用任何控制器。如果不使用`resources`元素将不需要`<annotation-driven/>`元素

* 控制器类
基于注解的控制器类可以包含多个请求处理方法，例如：ProductController 类包含`inputProduct`和`saveProduct`。
```
package controller;
import java.math.BigDecimal;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import domain.Product;
import form.ProductForm;

@Controller
public class ProductController {

    private static final Log logger = LogFactory.getLog(ProductController.class);

    @RequestMapping(value="/input-product")
    public String inputProduct() {
        logger.info("inputProduct called");
        return "ProductForm";
    }

    @RequestMapping(value="/save-product")
    public String saveProduct(ProductForm productForm, Model model) {
        logger.info("saveProduct called");
        // no need to create and instantiate a ProductForm
        // create Product
        Product product = new Product();
        product.setName(productForm.getName());
        product.setDescription(productForm.getDescription());
        try {
            product.setPrice(new BigDecimal(productForm.getPrice()));
        } catch (NumberFormatException e) {
        }

        // add product

        model.addAttribute("product", product);
        return "ProductDetails";
    }
}
```
>注意 `saveProduct` 的参数是`org.springframework.ui.Model`.用于添加视图属性模型，这里添加一个Product Model。可以通过`HttpServletRequest`访问该实例。

* 视图
这里有两个JSP视图页面，ProductForm.jsp和ProductDetails.jsp页面
**ProductForm.jsp**
```
<!DOCTYPE HTML>
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
        <p>
            <label for="name">Product Name: </label>
            <input type="text" id="name" name="name" 
                tabindex="1">
        </p>
        <p>
            <label for="description">Description: </label>
            <input type="text" id="description" 
                name="description" tabindex="2">
        </p>
        <p>
            <label for="price">Price: </label>
            <input type="text" id="price" name="price" 
                tabindex="3">
        </p>
        <p id="buttons">
            <input id="reset" type="reset" tabindex="4">
            <input id="submit" type="submit" tabindex="5" 
                value="Add Product">
        </p>
    </fieldset>
</form>
</div>
</body>
</html>
```
**ProductDetails.jsp**
```
<!DOCTYPE HTML>
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

> 这里你已经可以通过`http://localhost:8080/your-project-name/input-product` 访问这个Spring MVC 实例。

### 依赖注入@Autowired 和 @Service

使用Spring的依赖注入，获取注入Spring MVC的控制器依赖最简单的方法是使用`@Autowired`注解，`@Autowired`注解到一个字段或方法。
该`@Autowired`注解类型属于`org.springframework.beans.factory.annotation`包

为了使依赖被发现，该类必须使用@Service注解，它属于`org.springframework.stereotype`包，`@Service`注解类型表示该类是一个服务，此外，需要在配置文件添加`<component-scan/>`扫描依赖基础包
```
<context:component-scan base-package="dependencyPackage"/>
```

Spring MVC 依赖注入实例，参考如下：被修改的 ProductController2 类
```
package controller;
import java.math.BigDecimal;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import domain.Product;
import form.ProductForm;
import service.ProductService;

@Controller
public class ProductController {

    private static final Log logger = LogFactory
            .getLog(ProductController.class);

    @Autowired
    private ProductService productService;

    @RequestMapping(value = "/input-product")
    public String inputProduct() {
        logger.info("inputProduct called");
        return "ProductForm";
    }

    @RequestMapping(value = "/save-product", method = RequestMethod.POST)
    public String saveProduct(ProductForm productForm, 
            RedirectAttributes redirectAttributes) {
        logger.info("saveProduct called");
        // no need to create and instantiate a ProductForm
        // create Product
        Product product = new Product();
        product.setName(productForm.getName());
        product.setDescription(productForm.getDescription());
        try {
            product.setPrice(new BigDecimal(productForm.getPrice()));
        } catch (NumberFormatException e) {
        }

        // add product
        Product savedProduct = productService.add(product);
        
        redirectAttributes.addFlashAttribute("message", 
                "The product was successfully added.");
        return "redirect:/product_view/" + savedProduct.getId();
    }

    @RequestMapping(value = "/view-product/{id}")
    public String viewProduct(@PathVariable Long id, Model model) {
        Product product = productService.get(id);
        model.addAttribute("product", product);
        return "ProductView";
    }
}
```
> 如上ProductController实例 productService字段增加@Autowired注解进行依赖注入

ProductService接口和ProductServiceImpl实现类，如下
```
package service
import domain.Product;
public interface ProductService {
    Product add(Product product);
    Product get(long id);
}
```

```
package service;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;
import org.springframework.stereotype.Service;
import domain.Product;

@Service
public class ProductServiceImpl implements ProductService {

    private Map<Long, Product> products = 
            new HashMap<Long, Product>();
    private AtomicLong generator = new AtomicLong();

    public ProductServiceImpl() {
        Product product = new Product();
        product.setName("JX1 Power Drill");
        product.setDescription(
                "Powerful hand drill, made to perfection");
        product.setPrice(new BigDecimal(129.99));

        add(product);
    }

    @Override
    public Product add(Product product) {
        long newId = generator.incrementAndGet();
        product.setId(newId);
        products.put(newId, product);
        return product;
    }

    @Override
    public Product get(long id) {
        return products.get(id);
    }
}
```
SpringMVC 基于注解的配置文件，参考如下:
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
        http://www.springframework.org/schema/context/spring-context.xsd">
    <context:component-scan base-package="controller"/>
    <context:component-scan base-package="service"/>    
    <mvc:annotation-driven/>
    <mvc:resources mapping="/css/**" location="/css/"/>
    <mvc:resources mapping="/*.html" location="/"/>
    
    <bean id="viewResolver" class="org.springframework.web.servlet.view.InternalResourceViewResolver">
        <property name="prefix" value="/WEB-INF/jsp/"/>
        <property name="suffix" value=".jsp"/>
    </bean>
</beans>
```
### 重定向和闪存属性
如果你是一个经验丰富的Servlet/JSP 程序员，你肯定知道`请求转发(request forward)`和`请求重定向(request redirect)`的区别:
* 相比而言，`forward` 比 `redirect`更快，因为`重定向`需要往返服务器，而`转发`不需要。
* 然后，有些情况重定向是首选。（eg: 你需要重定向到一个外部站点,你不能使用转发，yes！）

通常默认情况使用`转发`，`转发`到一个视图或者转发到一个控制。有时候需要重定向（避免重复提交表单）
```
return "redirect:/view-product/" + savedProduct.getId();
```
> 如上使用`重定向`替代`转发`操作。

众所周知，`转发`可以很容易的将属性添加到模型对象，属性值将用于视图展示,由于,`重定向`是往返于服务器，`重定向`将丢失所有模型。
Spring3.1及其更高版本提供一种重定向时保留值，称为闪flash attributes（闪存属性）

* 如下ProductController类中saveProduct方法展示`flash attributes`
```
@RequestMapping(value = "save-product", method = RequestMethod.POST)
public String saveProduct(ProductForm productForm, 
        RedirectAttributes redirectAttributes) {
    logger.info("saveProduct called");
    // no need to create and instantiate a ProductForm
    // create Product
    Product product = new Product();
    product.setName(productForm.getName());
    product.setDescription(productForm.getDescription());
    try {
        product.setPrice(new BigDecimal(productForm.getPrice()));
    } catch (NumberFormatException e) {
    }

    // add product
    Product savedProduct = productService.add(product);
    
    redirectAttributes.addFlashAttribute("message", 
            "The product was successfully added.");

    return "redirect:/view-product/" + savedProduct.getId();
}
```

### 请求参数与路径变量
请求参数和路径变量作为URL的一部分，它将发送到服务器进行访问。key=value形式的请求参数由`&`符号分割，如下：productId的URL请求参数为3
```
http://localhost:8080/annotated2/view-product?productId=3
```
在servlet编程，你获取请求参数的值通过HttpServletRequest的getParameter方法
```
String productId = httpServletRequest.getParameter("productId");
```
Spring MVC 有更加简单的方法检索请求参数，使用`org.springframework.web.bind.annotation.RequestParam`注解类型来注解到请求参数，例如：如下的方法将捕获请求参数productId
```
public void sendProduct(@RequestParam int productId)
```
路径变量类似与请求参数，他没有key值，eg:`/view-product/productId`
* 如下使用路径变量
```
@RequestMapping(value = "/view-product/{id}")
public String viewProduct(@PathVariable Long id, Model model) {
    Product product = productService.get(id);
    model.addAttribute("product", product);
    return "ProductView";
}
```
要使用路径变量，需要使用`@RequestMapping`注解的value属性设置一个变量。如下RequestMapping注解定义变量为id
```
@RequestMapping(value = "/view-product/{id}")
```
然后，在方法中添加同名变量于`@PathVariable`注解,当调用方法，`id`值作为URL请求的一部分。

---

你可以在你的请求映射方法上使用多路径变量，例如：如下两个不同的路径变量，`userId`和`orderId`
```
@RequestMapping(value = "/view-product/{userId}/{orderId}")
```
>访问`viewProduct 方法`的`路径变量`, 使用`http://localhost:8080/you-project-name/view-product/1` 

使用路径变量有事有一个小问题：在某些情况下，可能会产生混淆浏览器，如下：
```
http://example.com/context/abc
```
> 浏览器会认为`abc` 是一个action.(yes！，他确实是一个action),`http://example.com/context`为上下文路径。
> 如果访问一个静态文件,它应当是这样的:`http://example.com/context/logo.png`。 但是`http://example.com/context/abc/1` 跳转到一个JSP。JSP 包含`<img src="logo.png"/>`,访问这个图片，你会发现它访问的是`http://example.com/abc/logo.png`. 它找错了上下文路径？

我们可以使用JSTL标签，解决这个问题(解析正确URL)：
```
 <c:url value="/img/logo.png"/>
```
为了避免CSS 文件 或 JS 文件出现未找到情况，同样受用(貌似无所谓)
```
<style type="text/css">@import url("<c:url value="/css/main.css"/>");</style>
```

## @ModelAttribute

我们知道，Spring MVC 每处理一个请求处理方法（action） 都会创建一个Model 对象，你可以在`请求处理方法`添加Model参数。
`@ModelAttribute`注解可以装饰Model的实例化对象。
`@ModelAttribute`可以注解在参数或方法中,它将会检索或创建一个Model对象。如下:`submitOrder方法`
```
@RequestMapping(method = RequestMethod.POST)
public String submitOrder(@ModelAttribute("newOrder") Order order,
    Model model) { 
   ...
}
```
`Order`  创建实例化并添加至Model 对象，Model对应属性值为`newOrder`。如果没有定义key的名称，那么类型的名称将会添加到Model中。
例如，如下`action`，每次被访问,都会创建实例化`Order`对象，设置属性key为`order`并添加到`Model`中，
```
public String submitOrder(@ModelAttribute Order order, Model model)
```

---

第二个用法:`@ModelAttribute`标注一个非请求处理方法，在同一个控制器内带`@ModelAttribute`的方法每次进行请求处理方法调用都会触发该方法。
带`@ModelAttribute`的方法会在请求处理方法之前被调用，它将返回一个对象或`void类型`。如果返回一个对象，该对象会被自动添加到请求处理方法的Model中。
如下返回对象实例：
```
@ModelAttribute
public Product addProduct(@RequestParam String productId) {
    return productService.get(productId);
}
```
如果注解方法返回`void`，则还必须添加一个Model参数，并添加自己的实例，如下：
```
@ModelAttribute
public void populateModel(@RequestParam String id, Model model) er);
    model.addAttribute(new Account(id));
} 
```



