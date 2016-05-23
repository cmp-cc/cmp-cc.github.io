----
title: Struts2 Action
date: 2013-02-28 23:51:00
updated:
categories: 
- JavaWeb
- Struts2
tags:
- Struts2
----

**这几东东，之前都学过了，无聊翻了翻官方文档，觉得写的很好，简单修改下实例，记录一下**


Struts2 的Action，一共包含三个部分
* 模型驱动（Model Driven）
* Action 链 （Action Chaining）
* Action 事件监听 （ActionEventListener）


## Model Driven
### 说明
* 如果一个Action 类实现`com.opensymphony.xwork2.ModelDriven`接口，那么它需要从getModel()方法中返回`请求参数对象`。 那么Struts 将会填充此对象的请求参数的Model。一旦执行该操作，这个对象将被放置到值栈的顶部。**验证也将应用于这个Model，不是Action中**。 `VisitorFieldValidator`注解，可以用于验证域模型（Model）。
* 要在Action中使用`模型驱动`,确保`模型驱动拦截器（Model Driven Interceptor）`应用于Action. 这个拦截器是`defaultStack`默认拦截器的一部分.

### 实例

* Action Class
```
public class ModelDrivenAction implements ModelDriven<Gangster> { 

    private  Gangster  gengster = new Gangster();

    public Gangster getModel() {
        return gengster;
    }

    public String execute() throws Exception {
        return SUCCESS;
    }
}
```
* Gangster.java  Model (请求参数模型)
```
public class Gangster implements Serializable {
    private String name;
    private int age;
    private String description;
    private boolean bustedBefore;
 
    public int getAge() {
        return age;
    }
    public void setAge(int age) {
        this.age = age;
    }
    public boolean isBustedBefore() {
        return bustedBefore;
    }
    public void setBustedBefore(boolean bustedBefore) {
        this.bustedBefore = bustedBefore;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
}
```
* JSP 访问Action 作用于Gangster
```
<s:form action="modelDrivenResult" method="POST" namespace="/modelDriven">   
    <s:textfield label="Gangster Name" name="name" />
    <s:textfield label="Gangster Age"  name="age" />
    <s:checkbox  label="Gangster Busted Before" name="bustedBefore" />
    <s:textarea  cols="30" rows="5" label="Gangster Description" name="description" />           
    <s:submit />
</s:form>
```


## Action chain

这里没有什么好说的，`Struts.xml` 中的`result type`为`chain`，这样可以进行Action之间跳转。（本质是请求转发）
略

## Action 事件监听
也略了。