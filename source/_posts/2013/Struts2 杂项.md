----
title: Struts2 杂项
date: 2013-02-20 17:20:00
updated:
categories: 
- Java Web
- Struts2
tags:
- Struts2
----

**一个Struts2 测试用记录文件**
## 基础

* Maven 引入依赖
```
       <dependency>
            <groupId>org.apache.struts</groupId>
            <artifactId>struts2-core</artifactId>
            <version>2.3.16</version>
        </dependency>
```
* web.xml 配置Struts2入口
**web.xml 添加Struts2 调用Servlet 的过滤器**
```
    <filter>
        <filter-name>struts2</filter-name>
        <filter-class>org.apache.struts2.dispatcher.ng.filter.StrutsPrepareAndExecuteFilter</filter-class>
    </filter>
    <filter-mapping>
        <filter-name>struts2</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>
```
* 根目录创建struts.xml文件
```
<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE struts PUBLIC "-//Apache Software Foundation//DTD Struts Configuration 2.1//EN" "http://struts.apache.org/dtds/struts-2.1.dtd">


<struts>  
    <constant name="struts.devMode" value="true" />
   
    <!-- 测试类 --> 
    <package name="imageSearch" namespace="/" extends="struts-default">
        <action name="test" class="org.freecode.controller.action.SimilarAction" method="test">
            <result name="success">index.jsp</result>
        </action>
    </package>
    
</struts>      
```
* 创建`BaseAction 对象`
```
package org.freecode.controller.action;

import com.opensymphony.xwork2.ActionSupport;
import com.opensymphony.xwork2.ModelDriven;

public abstract class BaseAction<T> extends ActionSupport implements ModelDriven<T>{
    /**
     * 
     */
    private static final long serialVersionUID = 1L;

    @Override
    public abstract T getModel();
}

```
* 创建测试Action
```
package org.freecode.controller.action;

import org.freecode.controller.from.SimilarFrom;

public class SimilarAction extends BaseAction<SimilarFrom>{
    private static final long serialVersionUID = 1L;

    private SimilarFrom similarForm = new SimilarFrom();
    
    @Override
    public SimilarFrom getModel() {
        return similarForm;
    }
    
    public String test(){
        return SUCCESS; 
    }
}
```
* 测试类Form 请求参数
```
package org.freecode.controller.from;

public class SimilarFrom {
    // 请求字段
    private String searchField;
    // 搜索阈值
    private String searchThreshold;
    // 搜索内容
    private String searchContent;
    
    public String getSearchField() {
        return searchField;
    }
    public void setSearchField(String searchField) {
        this.searchField = searchField;
    }
    public String getSearchThreshold() {
        return searchThreshold;
    }
    public void setSearchThreshold(String searchThreshold) {
        this.searchThreshold = searchThreshold;
    }
    public String getSearchContent() {
        return searchContent;
    }
    public void setSearchContent(String searchContent) {
        this.searchContent = searchContent;
    }
}

```

在写两个JSP？