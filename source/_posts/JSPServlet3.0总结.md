----
title: JSP/Servlet3.0总结
date: 2013-02-05 19:53:00
categories: 
- Java Web 
tags:
- JSP/Servlet
----

总结下一JSP/Servlet3.0，记性不好，记录一下，容易反查。


## JSP
### JSP 注释
#### 一种显示注释和三种隐式注释
JSP中有两种注释方式：
   * 显示注释 
   **显示注释就是HTML注释方式**
   ```
    <!-- 注释内容 -->
   ```
   * 隐式注释
   **JSP 注释方式**
   ```
   <%-- 注释内容 --%>
   ```
   **单行注释**
   ```
   <%
   // 注释内容
   %>
   ```
   **多行注释**
   ```
   <%
   /*
   1.注释内容
   2.注释内容
   */
   %>
   ```
#### 显示注释和隐式注释的区别
Servlet渲染页面的过程如下：
> JSP -> Servlet -> HTML

显示注释和隐式注释的区别:
**渲染为HTML页面后，显示注释的内容会显示到页面中，而隐式注释不会显示到页面中。**

### Scriptle 脚本片段
我们将JSP中写Java代码片段（代码块）理解为Scriptle 脚本片段 。Scriptle 脚本片段我们考虑如下三种情况：
* 局部代码块
**通过`<% Java %>` 进行局部代码编写**
```
<%
StringBuffer sb = new StringBuffer();
// TODO
%>
```
* 全局变量和方法
**通过`<%！ Java %>` 进行全局代码编写**
```
<%!
String user = "root";
String password = "123456";
%>
```
* 输出
**这里的输出要理解为渲染，它并不是将内容输出到控制台，而是渲染到页面上。  （特别说明）**
**输出有两种方式**
   * 通过`<%= 内容 %>` 进行内容输出
   ```
   <%=
   "<p>cmp-cc.github.io 是一个Blog </p>"
   %>  
   ```
   * 通过`<% out.println("内容") %>` 进行内容输出
   ```
   <% 
   out.println("cmp-cc.github.io 是一个Blog");
   %>
   ```

### Scriptlet 标签
HTML 中有Tag标签，每一标签有它特殊的含义和用途，JSP同样可以引入标签，我们称为：Scriptlet 标签 。
Scriptlet 标签是用来取代<%%> 这种形式，使得页面展示更加友好。
  
吧啦吧啦！！！！  （一大堆使用Scriptlet 标签 取代 <%%> 的好处）。
  
Scriptlet 标签基本写法：
**这里是JSP标签，很多标签的写法是一致的**
```
<jsp:scriptle>
            
</jsp:scriptle>
```

### JSP指令
  JSP指令用来设置与整个JSP页面相关的属性，它并不直接产生任何可见的输出,而只是告诉引擎如何处理其余JSP页面。
  
其一般语法形式为：  <%@ 指令名称 属性="值" %>
  
三种命令指令分别是
* page 
**设定整个JSP网页的静态属性**
* include
**include指令用来向当前页面插入一个静态文件的内容。这个文件可以是JSP、HTML、文本或是Java程序**
* taglib 
**使用标签库定义新的自定义标签，在JSP页面中启用定制行为**


#### page 指令 （页面指令）
作用： 设定整个JSP网页的静态属性
语法：键值对，空格分割。 
```
<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
```
**page指令属性**
属性 | 说明
--- | ---
autoFlush |满缓冲刷新，否异常 默认true
buffer |指定输出模式缓冲流，none 无，指定数值，大于此值，与上一起用，默认大于8kb
contentType |定义字符编码和页面响应MIME类型：contentType="text/html;charset=GBK"
errorPage |错误跳转页面errorPage="error.jsp" 与isErrorPage同用
extends| 定义JSP页面产生的Servlet 类的扩展， extends=""
import |import="java.util.*"
info |此JSP信息 info="info.exe"
isErrorPage| 设置true或false
isThreadSafe| 此页面是否是线程安全的，true，表示一个JSP页面可以处理多个用户，false， 一次只能处理一个用户。
language |用来定义使用的脚本语言, language="java"
pageEncoding| JSP页面的字节编码 pageEncoding="utf-8"
session |指定所在页面是否参与HTTP对话，默认:true

**实例代码**
* 引入ArrayList 和 StringTokenizer
```
<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList,java.util.StringTokenizer;" %>
```

#### include （包含指令）
**包含指令的用法非常简单，因为它只有一个属性**
作用： include指令用来向当前页面插入一个静态文件的内容。这个文件可以是JSP、HTML、文本或是Java程序
语法：
```
<%@include file="文件路径"%>
```

**注意：**
1、include 属于静态包含。（先包含后处理）
2、如果直接以文件名开头,指的是正在使用的JSP文件所在的路径,如果以/开头,指的是正在使用的JSP文件上下的路径关系(相对于WEB应用的根目录。)

**实例**
* index.jsp 引入 home.jsp
```
<%@ include file="home.jsp"%>
```

####  taglib （标签指令）
当页面引用了用户自定义标签时，taglib指令用于引用自定义标签库，并指定标签的前缀。
JSP内置的标签，我们称为JSP标签。

作用：使用标签库定义新的自定义标签，在JSP页面中启用定制行为。
语法：
```
<%@ taglib uri="URIToTagLibrary" prefix="tagPrefix" %>
```
**taglib 指令属性**
属性 | 说明
--- | ---
uri | 定位标签库描述符的位置。唯一标识和前缀相关的标签库描述符，可以使用绝对或相对URL。
tagDir | 指示前缀将被用于标识在WEV-INF/tags目录下的标签文件。
prefix | 标签的前缀，区分多个自定义标签。不可以使用保留前缀和空前缀，遵循XML命名空间的命名约定。

**实例**
* 引入JSTL 标签库
```
<taglib uri="http://java.sun.com /jsp/jstl/core" prefix="c" />
```

### JSP 内置标签

**JSP 一共有13个内置标签，他们用于完成不同的功能**




### JSP 内置对象

#### JSP 九种内置对象
**JSP 内置九种内置对象，你并不需要使用include 去引入它**

对象名称 | 作用
--- | ---
pageContext | JSP的页面容器
request    | 得到用户的请求信息
response | 服务器向用户的回应信息
session |	用来保存内一个用户信息
application | 表示所有用户的共享信息
config	| 服务器配置，可以去的初始值参数页面输出
out		| 页面输出
page	| 表示从页面中表示出来的一个Servlet实例
exception	| 表示JSP页面所发生异常，在错误页面才起作用

#### JSP 四种属性范围
**这里涉及JSP页面请求的生命周期,  暂略**
作用范围名称 | 说明
--- | ---
page	| 只在一个页面中保存属性，跳转之后无效。（使用pageContext表示）
request	| 再一次请求中保存属性，服务器跳转后依然有效。
session	| 再一次会话范围中保存，无论何种跳转都可以使用，但是新开浏览器无法使用。
application	| 在整个服务器上保存，所有用户都可以使用。


### JSP JavaBean
**JSP 使用使用JavaBean，除了可以使用<%User user = new User();%>的方式，大多数使用`<jsp:useBean>`标签**


## Servlet
**这里简单总结**
### Servlet 基础

#### 生命周期
Servlet 生命周期如下：
> 加载 -> 初始化 -> 服务 -> 销毁 -> 卸载

#### 内置方法
方法名称 | 说明
--- | ---
init()				| Servlet初始化调用
init(ServletConfig)	| Servlet初始化调用，ServletConfig读取配置信息
service()				    | Servlet服务，一般不会直接覆写此方法，而是使用doGet()或doPost()方法
destroy()				| Servlet销毁时调用

#### web.xml 配置Servlet，并附加初始值
```
<servlet>				      				 定义<servlet>
    <servlet-name>xxxx</servlet-name>        与servlet-mapping对应
    <servlet-class>			       			 定义包.类名称
		com.xxx.xxx.xxxx
	</servlet-class>
	<init-param>							 配置参数
		<param-name>ref</param-name>	     参数名称		可多个
		<param-value>值</param-value>	     参数内容
	</init-param>
</servlet>
<servlet-mapping>				             映射路径
	<servlet-name>xxxx</servlet-name>	     与servlet相对应
	<url-pattern>/xxx</url-pattern>		     页面映射路径
</servlet-mapping>
```
**Servlet 获取初始值**
```
Congif.getinitParameter（"ref"）取出
```
#### 获取HttpSession、ServletContext 实例
```
getSession（）					// 返回当前session
getSession（boolean）				// 返回当前session，是否新建。
getServletContext（）				// 取得ServletContext对象
```
#### 请求转发与重定向
##### 请求转发与重定向的区别
* 请求转发
**调用者与被调用者之间共享相同的request对象和response对象，他们属于同一个访问请求和响应过程，我们可以称之为`服务器跳转`**
* 重定向 
**调用者与被调用者,不共享属性和方法，等同于点击一个URL。 我们称之为`客户端跳转`**
##### 请求转发与重定向的用法
* 重定向（客户点跳转）
```
response.sendRedirect（"success.jsp"）;
```
* 请求转发（服务端跳转）
**有两个方法用于请求转发**
   * forward(req,res);				页面跳转    
   ```
   request.getRequestDispatcher("success.jsp").forward(request,response);
   ```
   * include(req.res)				页面包含
   ```
   request.getRequestDispatcher("main.jsp").include(request, response);
   ```
#### forward 和 include 区别
* forward方法是把请求的内容转发到另外的一个servlet.
* include是把另一个servlet处理过后的结果内容拿过来.
### Servlet 过滤器
Servlet 自定义过滤器需要两个步骤
* 1、实现Filter接口
   * Filter 方法
    方法名称 | 说明
    --- | ---
   init（FilterConfig）| 过滤器初始化
   doFilter(req,res)	|  完成过滤操作，然后通过FilterChain传递
   destroy() | 过滤器消亡，执行方法
   * 实例
   ```
    private String encodeString;

	//初始化方法
	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
		// 获取Web.xml 中配置的属性值
		encodeString=filterConfig.getInitParameter("encoding");
	}
    //filter 要实现的功能
	@Override
	public void doFilter(ServletRequest request, ServletResponse response,
			FilterChain chain) throws IOException, ServletException {
		System.out.println("begin");
		// 设置字符集
		request.setCharacterEncoding(encodeString);
		
		//继续向下执行，如果还有其他filter继续调用其他filter，没有的话将消息发送给服务器或客户端
		chain.doFilter(request, response);
		System.out.println("end");
	}
	//Filter注销方法
	@Override
	public void destroy() {
	
	}
   ```
* 2、配置Web.xml
```
<filter>
    <filter-name>encodeFilter</filter-name>
    <filter-class>io.github.cmp-cc.filter.encodeFilter</filter-class>
</filter>
<filter-mapping>
    <filter-name>encodeFilter</filter-name>
    <url-pattern>*.jsp</url-pattern>
</filter-mapping>
```
> url-pattern指定匹配模式


### Servlet 监听器

#### 监听器类型

类型 | 接口名称 | 说明
--- | --- | ---
application | ServletContextListener | 上下文状态监听器：监听应用容器启动和消亡
application |  ServletContextAttributeListener | 上下文属性监听器：监听增删改变换
session | HttpSessionListener | 状态监听器： 监听一次会话（Session）启动和消亡
session | HttpSessionAttributeListener| Session 属性监听：监听增删改变换
session | HttpSessionBindingListener | Session 对象绑定监听：Session绑定对象触发和消亡
request | ServletRequestListener| 请求监听器：监听一个请求（Request）启动和消亡
request | ServletRequestAttributeListener| Request 属性监听：监听增删改变换

#### 监听器的方法
application 监听
* ServletContextListener 
方法名称 | 作用
--- | ---
contextInitialized(ServletContextEvent) | 容器启动时触发
contextDestroyed（ServletContextEvent）| 容器销毁时触发

ServletContextEvent参数 常用方法
getServletContext() 取得ServletContext对象



* ServletContextAttributeListener 
方法名称 | 作用
--- | ---
attributeAdded(HttpSessionBindingEvent)| 增加属性触发
attributeRemoved(HttpSessionBindingEvent)| 删除属性触发
attributeReplaced(HttpSessionBindingEvent) | 替换属性(重复设置)时触发

session 监听
* HttpSessionListener
方法名称 | 作用
--- | ---
sessionCreated(HttpSessionEvent)| session创建时调用
sessionDestroyed(HttpSessionEvent) | session销毁时调用
* HttpSessionAttributeListener
方法名称 | 作用
--- | ---
attributeAdded（ServletContexArribute）| 增加属性触发
attributeRemoved(ServletContexArribute)| 删除属性触发
attributeReplaced(ServletContexArribute) | 替换属性(重复设置)时触发
* HttpSessionBindingListener
方法名称 | 作用
--- | ---
valueBound(HttpSessionBindingEvent) | 绑定对象到session时触发
valueUnbound(HttpSessionBindingEvent) | 从session中移除对象时触发

request 监听
* ServletRequestListener
方法名称 | 作用
--- | ---
requestInitialized(ServletRequestEvent) | 请求开始时调用
requestDestroyed(ServletRequestEvent)| 请求结束时调用
* ServletRequestAttributeListener
方法名称 | 作用
--- | ---
attributeAdded(ServletRequestAttributeEvent) | 增加属性触发
attributeRemoved(ServletRequestAttributeEvent) | 删除属性触发
attributeReplaced(ServletRequestAttributeEvent) | 替换属性(重复设置)时触发

#### 监听器实例

#### web.xml 配置监听器
**如此简单**
```
<listener>
   <listener-class>io.github.cmp-cc.listener.RquestCountListener</listener-class>
</listener>
```



#### Servlet 


## EL 表达式




### 其他
#### 静态包含 与 动态包含的区别
* 写法
   * 静态包含
   静态包含就是使用包含指令
   ```
   <%@include file="文件路径"%>
   ```
   * 动态包含
   使用JSP标签 <jsp:include>



注意：include指令元素和行为元素主要有两个方面的不同点。
1.include指令是静态包含，执行时间是在编译阶段执行，引入的内容为静态文要，在编译成servlet时就和包含者融合到一起。所以file不能是一个变量，也不能在file后接任何参数。
2.include行为是动态包含，执行时间是在请求阶段执行，引入的内容在执行页面时被请求时动态生成再包含到页面中。

