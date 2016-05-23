----
title: Spring MVC 数据绑定
date: 2013-06-28 16:53:00
updated:
categories: 
- JavaWeb
- Spring MVC

tags:
- Spring MVC
----

数据绑定特性用于将用户输入（请求参数）转换为`域模型`或`同名离散数据`，由于数据绑定，HTTP请求参数，它总是`字符串`类型，可以填充不同类型的对象属性。(Srping 定义很多类型转换)。


## 数据绑定
### 离散参数
**控制器Action 方法接收请求数据为离散数据** 
* JSP/HTML
```
<form action="user-save" method="post">  
    
    <input name="name" value="姓名"/></div>  
    <input name="age" value="20"/></div>  
    <input name="income" value="100000"/>
    <input type="radio" name="isMarried" value="true" checked="checked"/>
    <input type="radio" name="isMarried" value="false"/>
    <input type="checkbox" name="interests" value="Ruby" checked="checked"/>
    <input type="checkbox" name="interests" value="Python" checked="checked"/>  
    <input type="checkbox" name="interests" value="Clojure" checked="checked"/>
    
    
    <input type="submit" value="提交表单"/> 
</form> 
```
* Spring MVC 控制器
```
    @RequestMapping(value="/user-save")
    public void saveUserInfo(String name, Integer age, Double income, Boolean isMarried, String[] interests)  
    {  
        // 请求参数 Key 与 参数名称一一对应。
        // 名字、年龄、收入、是否结婚、兴趣列表
    }  
```
### 域模型
**将用户输入转换为域模型**
* 请求参数对象User
```
public class User {  
    private String name;  
    private Integer age;  
    private Boolean isMarried;  
    private Double income;  
    private String[] interests;  
      
    public String getName() {  
        return name;  
    }  
    public void setName(String name) {  
        this.name = name;  
    }  
    public Integer getAge() {  
        return age;  
    }  
    public void setAge(Integer age) {  
        this.age = age;  
    }  
    public Boolean getIsMarried() {  
        return isMarried;  
    }  
    public void setIsMarried(Boolean isMarried) {  
        this.isMarried = isMarried;  
    }  
    public Double getIncome() {  
        return income;  
    }  
    public void setIncome(Double income) {  
        this.income = income;  
    }  
    public String[] getInterests() {  
        return interests;  
    }  
    public void setInterests(String[] interests) {  
        this.interests = interests;  
    }  
}  
```
* Spring MVC 控制器
```
 @RequestMapping(value="/user-save")
    public void saveUserInfo(User user)  
    {  
        // user 对象包含请求值
        // 名字、年龄、收入、是否结婚、兴趣列表
    }  
```
* JSP/HTML
```
<form action="user-save" method="post">  
    
    <input name="name" value="姓名"/></div>  
    <input name="age" value="20"/></div>  
    <input name="income" value="100000"/>
    <input type="radio" name="isMarried" value="true" checked="checked"/>
    <input type="radio" name="isMarried" value="false"/>
    <input type="checkbox" name="interests" value="Ruby" checked="checked"/>
    <input type="checkbox" name="interests" value="Python" checked="checked"/>  
    <input type="checkbox" name="interests" value="Clojure" checked="checked"/>
    
    
    <input type="submit" value="提交表单"/> 
</form
```