----
title: 验证码kaptcha在Web项目中应用
date: 2014-10-24 17:50:00
updated:
categories: 
- Java Web

tags:
- Java Web
----


任何项目 项目中，验证码功能是必不可少的，可能你之前都是`awt image` 生成的，现在你可以试一试kaptcha了，kaptcha 是个生成验证码的Library。
这篇文件介绍kaptcha在Web项目中的应用，并给出三个可运行的实例。

三个实例以不同的形式实现。（都是用户登陆）
* 实例 1
**Spring实例，控制器继承`KaptchaExtend`，使用默认的图形。比较简单**
* 实例 2
 **Spring实例，自定义图形实例，实例化`DefaultKaptcha`对象自定义图形。**
* 实例 3
 **Servlet实例,web.xml 中配置`com.google.code.kaptcha.servlet.KaptchaServlet`对象的映射关系，通过`init-param`元素进行图形配置**


## 环境配置
* 引入依赖
三个实例中都可以不使用Spring，只是Spring 演示比较方便。
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
        <dependency>
            <groupId>com.github.axet</groupId>
            <artifactId>kaptcha</artifactId>
            <version>0.0.8</version>
        </dependency>  
```
* web.xml
```
<?xml version="1.0" encoding="UTF-8"?>
<web-app version="3.1" 
        xmlns="http://xmlns.jcp.org/xml/ns/javaee" 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
        xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee 
            http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"> 
            
    <display-name>Kaptcha Example</display-name>
    
    <servlet>
        <servlet-name>spring</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>classpath:applicationContext.xml</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>spring</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
    
    <filter>
        <filter-name>encodingFilter</filter-name>
        <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
        <init-param>
            <param-name>encoding</param-name>
            <param-value>utf-8</param-value>
        </init-param>
    </filter>
    <filter-mapping>
        <filter-name>encodingFilter</filter-name>
        <url-pattern>/</url-pattern>
    </filter-mapping>
</web-app>
```
* applicationContext.xml
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:context="http://www.springframework.org/schema/context"
    xmlns:mvc="http://www.springframework.org/schema/mvc"
    xsi:schemaLocation="http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc-4.0.xsd
        http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.0.xsd">

    <context:annotation-config />

    <context:component-scan base-package="org.freecode" />

    <mvc:annotation-driven />

</beans>

```
## 视图（View）
**一共包含三个页面，登陆页面(login.jsp)、登陆成功(login-success.jsp)。**
* login.jsp
```
<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Insert title here</title>
</head>
<body>
<form action="login" method="post">
    <label>User: <input type="text" name="user" > </label> <br />
    <label>Password: <input type="password" name="password" ></label><br />
    <label>
        验证码  <input name="captcha" type="text" id="kaptcha">
   </label><br />
   <img src="captcha.jpg" id="captcha_img"/> <a href="#" onclick="changeCode()">看不清?换一张</a>
    
    <input type="submit" value="注册">
    
</form>
<script type="text/javascript">
    function changeCode(){
        document.getElementById("captcha_img").src="captcha.jpg";
    }
</script>
</body>
</html>  
```
* login-success.jsp
```
Success  
```



## 实例 1
**这是使用Kaptcha 最简单的实例（不自定义图片形态）**
* Controller
**控制器继承`com.google.code.kaptcha.servlet.KaptchaExtend`类。KaptchaExtend可以生成简单的图片形态。**
****
```
package org.freecode.controller;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import com.google.code.kaptcha.servlet.KaptchaExtend;
@Controller
public class LoginController extends KaptchaExtend {
    /**
     * 1、生成图片.
     * 2、Session 保存文件Key
     * 3、Response 响应图片给客户端
     */
    @RequestMapping(value = "/captcha.jpg", method = RequestMethod.GET)
    public void captcha(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        super.captcha(req, resp);
    }
    
    @RequestMapping(value = "/login", method = RequestMethod.POST)
    public String registerPost( String user,
        String password,String captcha, HttpServletRequest request) {
        
        System.out.println(String.format("用户名为：%s\n密码为：%s\n验证码:%s", user,password,captcha));
        
        /**
         * 1、获取Session 中 Text值
         * 2、验证客户端captcha是否一致
         */
        if (!captcha.equals(getGeneratedKey(request)))
            throw new RuntimeException("bad captcha");
        //转发到login-success.jsp页面
        return "login-success.jsp";
    }
}  
```
   > `captcha`方法生成一张图片,并将相关信息写入Session(包含正确文字信息).`getGeneratedKey`方法通过Session获取文字信息进行校验。

* 演示

{% asset_img 1bca8479-c940-4021-81a3-54f8c9e60bcb.png 实例1 登陆演示 %} 

## Kaptcha 可以选的配置项
你可以实例化`DefaultKaptcha`对象，配置这里参数。 
* 实例2演示，通过Spring注解的方式进行依赖注入。
* 实例3演示，在web.xml 配置Servlet `com.google.code.kaptcha.servlet.KaptchaServlet`映射关系，并配置自定义图形。
配置名称 | 描述 | 默认值
--- | --- | ---
kaptcha.GimpyEngine | 渲染引擎（自定义样式）| 默认WaterRipple
kaptcha.textproducer.font.names |    验证码文本字体样式  |默认为:new Font("Arial", 1, fontSize), new Font("Courier", 1, fontSize)  
kaptcha.textproducer.font.size |  验证码文本字符大小  |默认为:40  
kaptcha.textproducer.font.color |  验证码文本字符颜色 | 默认为:Color.BLACK  
kaptcha.image.width  |  验证码图片宽度  |默认为:200  
kaptcha.image.height  | 验证码图片高度 | 默认为:50  
kaptcha.border  | 是否有边框  | 默认为:yes  可以选(yes，no )
kaptcha.border.color |   边框颜色 |  默认为:Color.BLACK  | 
kaptcha.border.thickness |  边框粗细度|  默认为: 1  
kaptcha.textproducer.impl  |  验证码文本生成器|  默认为: DefaultTextCreator  
kaptcha.textproducer.char.string|    验证码文本字符内容范围  |默认为: abcde2345678gfynmnpwx  
kaptcha.textproducer.char.length |   验证码文本字符长度  |默认为:5  
kaptcha.textproducer.char.space |  验证码文本字符间距  |默认为:2  
kaptcha.noise.impl  |   验证码噪点生成对象  |默认为:DefaultNoise  
kaptcha.noise.color |   验证码噪点颜色   |默认为:Color.BLACK  
kaptcha.background.impl|    验证码背景生成器   |默认为:DefaultBackground  
kaptcha.background.clear.from  |  验证码背景颜色渐进|  默认为:Color.LIGHT_GRAY  
kaptcha.background.clear.to |   验证码背景颜色渐进  | 默认为:Color.WHITE  
kaptcha.producer.impl  |  验证码生成器 | 默认为: DefaultKaptcha  
kaptcha.obscurificator.impl |   验证码样式引擎 | 默认为:WaterRipple  
kaptcha.word.impl   | 验证码文本字符渲染  | 默认为:DefaultWordRenderer  


## 实例 2
**你会发现实例2和实例如此的相似**
* applicationContext.xml 创建`captcha` Bean (添加如下即可)
```
    <!-- 登陆时验证码的配置 -->
    <bean id="captchaProducer" class="com.google.code.kaptcha.impl.DefaultKaptcha">
        <property name="config">
            <bean class="com.google.code.kaptcha.util.Config">
                <!--通过构造函数注入属性值 -->
                <constructor-arg type="java.util.Properties">
                    <props>
                        <!-- 验证码宽度、高度 -->
                        <prop key="kaptcha.image.width">150</prop>
                        <prop key="kaptcha.image.height">60</prop>
                        <!-- 验证码内容范围和个数 -->
                        <prop key="kaptcha.textproducer.char.string">abcdegfynmnpwx123456789</prop>
                        <prop key="kaptcha.textproducer.char.length">5</prop>
                        <!-- 是否有边框 -->
                        <prop key="kaptcha.border">no</prop>
                        <!-- 验证码字体颜色和大小 -->
                        <prop key="kaptcha.textproducer.font.color">red</prop>
                        <prop key="kaptcha.textproducer.font.size">35</prop>
                        <!-- 验证码所属字体样式 -->
                        <prop key="kaptcha.textproducer.font.names">Arial, Courier</prop>
                        <prop key="kaptcha.background.clear.from">white</prop>
                        <prop key="kaptcha.background.clear.to">white</prop>
                        <prop key="kaptcha.obscurificator.impl">com.google.code.kaptcha.impl.ShadowGimpy</prop>
                        <prop key="kaptcha.noise.impl">com.google.code.kaptcha.impl.NoNoise</prop>
                        <!-- 噪点颜色(干扰线) -->
                        <prop key="kaptcha.noise.color">black</prop>
                        <!-- 验证码文本字符间距 -->
                        <prop key="kaptcha.textproducer.char.space">3</prop>
                    </props>
                </constructor-arg>
            </bean>
        </property>
    </bean>
</beans>  
```
> 自己去配置，如上很多废话。

* 验证码工具类(KaptchaUtils.java)
```
package org.freecode.util;
import java.awt.image.BufferedImage;
import java.io.IOException;
import javax.imageio.ImageIO;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.google.code.kaptcha.impl.DefaultKaptcha;
/**
 * 
 * @author cmp-cc
 * @mail baiwoyidao@163.com
 *
 */
public class KaptchaUtils {
    
    /**
     * 1、生成Image
     * 2、Response 到客户端
     */
    public static void captcha(DefaultKaptcha kaptchaProducer,HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setHeader("Cache-Control", "no-store, no-cache");
        resp.setContentType("image/jpeg");
        String capText = kaptchaProducer.createText();
        req.getSession().setAttribute(
                com.google.code.kaptcha.Constants.KAPTCHA_SESSION_KEY, capText);
        BufferedImage bi = kaptchaProducer.createImage(capText);
        ServletOutputStream out = resp.getOutputStream();
        ImageIO.write(bi, "jpg", out);
    }
    /**
     * 1、获取Session 文本值
     * @param req
     * @return
     */
    public static String getGeneratedKey(HttpServletRequest req) {
        HttpSession session = req.getSession();
        return (String) session
                .getAttribute(com.google.code.kaptcha.Constants.KAPTCHA_SESSION_KEY);
    }
}
```
* 控制器(LoginController2.java)
```
package org.freecode.controller;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.freecode.util.KaptchaUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import com.google.code.kaptcha.impl.DefaultKaptcha;
@Controller
public class LoginController2 {
    /**
     * Kaptcha 验证码
     */
    @Autowired
    private DefaultKaptcha kaptchaProducer;
    
    /**
     * 生成验证码
     * 
     * @param request
     * @param response
     * @throws Exception
     */
    @RequestMapping(value = "captcha2.jpg", method = RequestMethod.GET)
    public void captcha(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        KaptchaUtils.captcha(kaptchaProducer, req, resp);
    }
    
    @RequestMapping(value = "/login2", method = RequestMethod.POST)
    public String registerPost(String user, String password, String captcha,
            HttpServletRequest request) {
        System.out.println(String.format("用户名为：%s\n密码为：%s\n验证码:%s", user,
                password, captcha));
        /**
         * 1、获取Session 中 Text值 
         * 2、验证客户端captcha是否一致
         */
        if (!captcha.equals(KaptchaUtils.getGeneratedKey(request)))
            throw new RuntimeException("bad captcha");
        // 转发到login-success.jsp页面
        return "login-success.jsp";
    }
}
```
* 修改客户端（login.jsp）
   * `<img src="captcha.jpg" id="captcha_img"/>` 改为`<img src="captcha2.jpg" id="captcha_img"/>`
   * `<form action="login" method="post">` 改为`<form action="login2" method="post">`
   * `document.getElementById("captcha_img").src="captcha.jpg";`改为`document.getElementById("captcha_img").src="captcha2.jpg";`
* 演示

{% asset_img cfbeba3c-a3f0-4d7d-b5c9-bf22c0ceccef.jpg 实例2 登陆演示 %} 

{% asset_img 49ca8163-ccc5-48ef-8f4d-7981d7e0b963.png 登陆成功%}
> 看样子效果不好，间距在小一点，多一些干扰线就Ok了


## 实例 3

实例3 就略过吧！   貌似随便搜一下是可以搜到的。（实例 3 的步骤我已经介绍的很清楚了。）







