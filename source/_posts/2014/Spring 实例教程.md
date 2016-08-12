----
title: Spring 实例教程
date: 2014-01-12 13:53:00
updated:
categories: 
- JavaWeb
- Spring

tags:
- Spring
----

## 构建Spring 环境
* 引入依赖
   * 下载Spring，引入dist目录下所有Jar，附加commons-logging.jar 。
   * 或者，使用Maven构建项目,如下
   ```
  <dependencies>
  <dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-context</artifactId>
    <version>3.2.5.RELEASE</version>
</dependency>
   ```
> spring-context 会将Spring 其他相关依赖引入
* 创建beans.xml ,并引入相关的Shema
**不限定名称，也可以为:ApplicationContext.xml**
```
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:aop="http://www.springframework.org/schema/aop"
  xmlns:context="http://www.springframework.org/schema/context"
  xmlns:tx="http://www.springframework.org/schema/tx"
  xsi:schemaLocation="http://www.springframework.org/schema/beans
         http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
         http://www.springframework.org/schema/context
         http://www.springframework.org/schema/context/spring-context-3.0.xsd
         http://www.springframework.org/schema/aop
         http://www.springframework.org/schema/aop/spring-aop-3.0.xsd
         http://www.springframework.org/schema/tx 
         http://www.springframework.org/schema/tx/spring-tx-3.0.xsd">
</beas>
```
> 一般情况下，Shema去官方文档里找（但是，如果你使用STS工具，可以直接创建Spring 配置文件。），如上是一个全貌，对于新的版本可能过时了。
> 如果你只使用Spring Bean 容器，你可能只需要引入`spring-beans-3.0.xsd`
> 

* 演示配置Bean 对象
   * 创建相关对象(如下一个Helloworl对象)
   ```
   package org.freecode.spring.model;
   public class HelloWorld {
       public String hello(){
       return "HelloWorld !!";
       }
   }
   ```
   * beans.xml 配置Bean
   ```
<bean id="hellWorld" class="org.freecode.spring.model.HelloWorld"></bean>  
   ```
   > 如上Bean 对象，实际等同于`HelloWorld hellWorld = new HelloWorld()`
   > 只是创建于Spring Bean容器中，也就是说HelloWorld对象交给Spring进行管理。

   * 测试
   ```
   package org.freecode.spring.model;
   
   import org.junit.Test;
   import org.springframework.beans.factory.BeanFactory;
   import org.springframework.context.support.ClassPathXmlApplicationContext;
   
   public class HelloWorldTest {
   
       //1、创建Spring Bean 工厂 (Bean 容器)
       private BeanFactory factory = new ClassPathXmlApplicationContext("beans.xml");
       @Test
       public void testHello() {
      
         //2、通过Bean 工厂 获取相应的类对象
         //getBean() 方法可以接受bean的id 或这对象class。 (都可以获取HelloWorld 对象)
         HelloWorld helloWorld = factory.getBean(HelloWorld.class);
         System.out.println(helloWorld.hello());
       }
   }
   ```

## ICO
ICO【依赖注入、控制反转】，使用ICO有两个步骤。
* 1、`beans.xml`配置相关依赖注入对象（只有交给Spring管理的对象才能进行依赖注入，如上环境测试中的Bean。）
* 2、对依赖的类完成注入（我们有如下多种注入方式）
   * 2.1、`setter` 方法注入。通过`property`元素注入（每一个依赖注入对象必须创建`getter`和`setter`方法）
   * 2.2、构造方法注入。通过`constructor-arg`元素注入
   * 2.3、自动注入 （自动装配）。通过`autowire` 属性完成注入

### IOC XML 实例
**在一个Web 项目中Service 层一般会依赖于DAO层对象，我们使用ICO完成，来演示这个实例**

#### 通过`setter`方法注入
通过IOC XML `property`属性实现注入（通过setter方法）
* Model
```
package org.freecode.spring.model;

public class User {
  private String id;
  private String name;
  private String age;
  public String getId() {
    return id;
  }
  public void setId(String id) {
    this.id = id;
  }
  public String getName() {
    return name;
  }
  public void setName(String name) {
    this.name = name;
  }
  public String getAge() {
    return age;
  }
  public void setAge(String age) {
    this.age = age;
  }
  @Override
  public String toString() {
    return "User [id=" + id + ", name=" + name + ", age=" + age + "]";
  }
}
```
* DAO
```
package org.freecode.spring.dao;

import org.freecode.spring.model.User;

public interface IUserDao {
  // 由于只是一个演示IOC,只有一个演示方法
  public void addUser(User user);
}
```
**DAO 接口实现类**
```
package org.freecode.spring.dao;
import org.freecode.spring.model.User;
public class UserDao implements IUserDao {
    public void addUser(User user) {
        System.out.println(user);
    }
}
```
* Service
```
package org.freecode.spring.service;
import org.freecode.spring.model.User;
public interface IUserService {
    public void addUser(User user);
}
```
**Service 接口实现类，注意：1、我们依赖的为DAO接口。2、并创建依赖类的`getter`和`setter`方法**
```
package org.freecode.spring.service;
import org.freecode.spring.dao.IUserDao;
import org.freecode.spring.model.User;
public class UserService implements IUserService{
    private IUserDao userDao;
    
    public IUserDao getUserDao() {
        return userDao;
    }
    
    public void setUserDao(IUserDao userDao) {
        this.userDao = userDao;
    }
    public void addUser(User user) {
        userDao.addUser(user);
    }
}  
```
* 配置bean.xml 文件，通过`property`属性注入相关依赖。
```
<bean id="userDao" class="org.freecode.spring.dao.UserDao"></bean>
     
     <bean id="userService" class="org.freecode.spring.service.UserService">
         <!-- 这里会将UserDao注入到userService中。(这就是所谓的依赖注入) -->
         <!-- 实际是通过userService中setter(IUserDao userDao)方法完成注入。(知道为什么写getter、setter方法了把) -->
         <!-- name属性为要注入的set后缀名称(setUserDao),ref属性为要注入的bean的 id -->
         <property name="userDao" ref="userDao"></property>
     </bean>  
```
* 测试类（测试IOC）
**测试通过Spring 为UserService 注入 UserDAO是否成功**
```
package org.freecode.spring.model;
import java.util.UUID;
import org.freecode.spring.service.IUserService;
import org.freecode.spring.service.UserService;
import org.junit.Test;
import org.springframework.beans.factory.BeanFactory;
import org.springframework.context.support.ClassPathXmlApplicationContext;
public class SpringTest {
    private BeanFactory factory = new ClassPathXmlApplicationContext("beans.xml");
    
    @Test
    public void testIOC(){
        IUserService userService = factory.getBean("userService",UserService.class);
        User user = new User();
        user.setId(UUID.randomUUID().toString());
        user.setName("天王盖地虎");
        user.setAge("21");
        userService.addUser(user);
    }
}
```
控制台打印如下：表示注入成功了。
```
User [id=00621890-01cf-4573-8610-7d737936459c, name=天王盖地虎, age=21]  
```
#### 通过构造函数注入
**如下，将该改为使用构造函数完成如上注入。**

* 修改 UserService  (不需要`getter`、`setter`方法了，需要一个构造函数)
```
    private IUserDao userDao;
    
    public UserService(IUserDao userDao) {
        super();
        this.userDao = userDao;
    }
    
/* //通过property 完成注入,实际是通过setter方法注入
   public void setUserDao(IUserDao userDao) {
        this.userDao = userDao;
   }
    
   public IUserDao getUserDao() {
        return userDao;
    }
*/  
```
* 修改beans.xml
```
<!-- 如下使用使用构造方法完成注入，不常用，一般情况还是使用setter实现注入 -->
     <bean id="userService" class="org.freecode.spring.service.UserService">
         <constructor-arg ref="userDao"></constructor-arg>
     </bean>  
```
* 运行测试方法`testIOC`，验证结果

####  自动注入（自动装配）
* 需要实现`setter`方法、而不是构造函数。（也就是说自动注入使用setter方法后名称来完成注入）
```
略
```
* 修改beans.xml
```
    // byName 根据Class中的setter属性名称查找beans.xml中id名称，完成注入
    <bean id="userService" class="org.freecode.spring.service.UserService" autowire="byName">
     </bean>  
```
* 执行测试方法

* `autowire`属性值
   * `default`
   **由上级标签<beans>的`default-autowire`属性决定，bean元素默认值**
   * byName
   **通过属性的名字的方式查找JavaBean依赖的对象并为其注入**
   > Spring IoC容器会在配置文件中查找对应的`id/name`属性,然后使用Setter方法将其注入
   * byType （一般不使用）
   **通过属性的类型查找JavaBean依赖的对象并为其注入。**
   > 注意： 有个两个要注入的对象，实现了同一个接口。这时，根据实现接口注入两个不同对象，就会报错，Spring不知道怎么注入二个多态对象。
   * constructor
   **通byType一样，也是通过类型查找依赖对象。与byType的区别在于它不是使用Seter方法注入，而是使用构造子注入**
   * no
   **不启用自动装配，beans元素默认值**
   

**使用Spring XML 配置IOC 选择问题**
* 1、开发中不建议使用`autowire`属性完成自动注入。
**原因：虽然他可以减少配置，但是beans文件无法直观了解类的整体面貌，所以不建议使用`autowire`**
* 2、常规开发中一般使用`property`注入，而不是构造方法注入。

### 依赖注入属性实例
**上一个实例，通过`ref` 引用一个类，将其注入，如果是具体的值呢？   使用`value`属性，完成具体值注入**
* 注入一个默认的 User Model 属性
```
 <bean id="ser" class="org.freecode.spring.model.User">
     <property name="id" value="1"></property>
     <property name="name" value="生命宛如，静静相拥的河"></property>
     <property name="age" value="21"></property>
 </bean>  
```
* 测试方法
```
    @Test
    public void testUser(){
        User user = factory.getBean("user",User.class);
        System.out.println(user);
    }  
```
> ok，`User [id=1, name=生命宛如，静静相拥的河, age=21]`

* 其他
   * 可以注入一个List对象、Set对象类，过于简单，就略了。

### 基于Annotation的注入实例
上面两个实例都是通过XML实现注入，Spring3.0以后支持注解注入，如下演示基于Annotation注入。

* 修改第一个实例XML配置，如下
```
 <?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:context="http://www.springframework.org/schema/context"
    xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-3.0.xsd">
    <!-- 开启使用注解配置 -->
    <context:annotation-config />
    <!-- 告诉Spring 去哪写包找注入Bean -->
    <context:component-scan base-package="org.freecode.srping" />
    
</beans>
> Shema 中引入了`spring-context`
```
* 通过`@component`注解将类交给Spring管理
class 类中声明`@Compent` 等价于在Beans.xml 配置当前Bean对象（`<bean id="userDao" class="org...UserDao">`）
```
@Component("userDao")  
public class UserDao implements IUserDao {
    public void addUser(User user) {
        System.out.println(user);
    }
}
```
* 依赖注入`UserDao`到`UserService`
**有如下三个注解可以完成依赖注入**
   * `@Autowired`，我们很熟悉，由Spring提供，默认`通过类型注入`。
   * `@Resource`,由J2EE提供，需要引入`javax.annotation.Resource`包，默认`通过名称注入`
   * `@Inject`，JSR330中提供,需要引入`Inject`jar。（等价于Resource）
```
package org.freecode.spring.service;
import javax.annotation.Resource;
import org.freecode.spring.dao.IUserDao;
import org.freecode.spring.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
@Component("userService")
public class UserService implements IUserService{
  
   private IUserDao userDao;
   // 使用Spring 依赖注入,它默认基于类型注入
   @Autowired
   public void setUserDao(IUserDao userDao) {
        this.userDao = userDao;
   }
    
   public IUserDao getUserDao() {
        return userDao;
    }
    
    public void addUser(User user) {
        userDao.addUser(user);
    }
}
```
* 执行测试方法
```
    private BeanFactory factory = new ClassPathXmlApplicationContext("beans.xml");
    
    @Test
    public void testIOC(){
        IUserService userService = factory.getBean("userService",UserService.class);
        User user = new User();
        user.setId(UUID.randomUUID().toString());
        user.setName("天王盖地虎");
        user.setAge("21");
        userService.addUser(user);
    }  
```
> ok, 如此简单的完成了依赖注入
* 使用`@Resouce` 注解完成注入
**我们不推荐使用`@Autowired`,而是使用`@Resouce`**
   * 引入J2EE中的`javax.anntation.resource`
   ```
           <dependency>
            <groupId>javax.annotation</groupId>
            <artifactId>javax.annotation-api</artifactId>
            <version>1.2</version>
        </dependency>
   ```
   * 将`@Autowired` 改为 `@Resouce` 即可
   ```
      // 使用J2EE提供的依赖注入完成
   @Resource
   public void setUserDao(IUserDao userDao) {
        this.userDao = userDao;
   }
   ```
   > 你可以将注入写在`setter方法`上、属性上和构造方法上。这里只是举了个`setter`的例子
   * 你可以测试了
#### 不推荐使用`@Component`完成所有Bean的创建
除了`@Component`注解以外，还有如下功能一样，名称不同的注入注解。
* `@Componentt` 作用于`公共代码层`。
* `@Repository` 作用于`持久化层(DAO)`
* `@Service` 作用于`业务层`
* `@Controller` 作用于`MVC控制层`

> 你可修改上一个实例的`@Component` 实际相符的注入类型，并完成测试。

### `scope` 实例周期
使用XML管理Bean 可以在Bean中配置`scope`属性。
或者，使用@Scope注解配置Bean的周期。
Bean 实例周期属性`scope`有四个属性。
* `singleton`
**单例模式，默认值**
* `prototype`
**多例模式**
* `request`
* `session`
> `scope`默认为单例默认。当一个对象的状态不会发生改变，使用单例。当实例对象的状态肯能改变，使用多例。
> 例如：DAO层和Service层一般都是单例，而Model 则为多例，Model中的属性状态一直在变化。Action 层则为多例（状态总是改变的）。

**注解scope** 
```
@Component
@Scope("prototype")
public class User { 
....
 
```


## AOP
AOP 直意过来为：`面向方面编程`,更为正确的叫法为：`面向切面编程`

### AOP Annotation 实例
**这个实例是建立在IOC Annotation 的基础上**
* 引入AOP依赖包，依赖如下（Spring使用的是第三方的切面库：`Aspect.jar）
   * `aopalliance.jar`
   * `aspectrt.jar`
   * `aspectjweaver.jar`
   * 或者使用Maven构建如下(其中`aopllicance`,`spring-context` 默认引入依赖)
   ```
   <dependency>
      <groupId>org.aspectj</groupId>
      <artifactId>aspectjrt</artifactId>
      <version>1.7.3</version>
    </dependency>
 
    <dependency>
      <groupId>org.aspectj</groupId>
      <artifactId>aspectjweaver</artifactId>
      <version>1.7.3</version>
    </dependency>
    
   ```
* beans.xml 引入`spring-aop shema` (主要目的自动检索或代码补全)
* 开启注解AOP 自动代理
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:context="http://www.springframework.org/schema/context"
    xmlns:aop="http://www.springframework.org/schema/aop"
    xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-3.0.xsd
        http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-3.0.xsd">
    <!-- 开启使用注解配置 -->
    <context:annotation-config />
    <!-- 告诉Spring 去哪写包找注入Bean -->
    <context:component-scan base-package="org.freecode.spring" />
    
    <!-- AOP.1、引入AOP Schema -->
    <!-- AOP.2、开启AOP自动代理 -->
    <aop:aspectj-autoproxy></aop:aspectj-autoproxy>
    
</beans>  
```
* 创建一个切面类。（代理对象）
   * 通过`@Aspect` 注解，申明为一个切面对象。
   * 声明AOP切点。声明AOP 方法的位置。这里使用`@After`方法后执行。
   * 声明`execution表达式`，表明当前的方法允许访问范围
   ```
   /**
       1、execution 表达式标示
       2、必须是 public 范围的方法
       3、* 不显示返回类型
       4、作用范围 包名下的所有类，必须add开头
       5、(..) 不限制输入类型
   execution(public * org.freecode.spring.dao.*.add*(..))
   ```
   > 如果有多个`execution` 表达式使用`||` 运算符即可。
**参照如下**
```
package org.freecode.spring.aspect;
import org.aspectj.lang.annotation.After;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.stereotype.Component;
/**
 *1、 @Component IOC注解,将当前对象交给Spring管理
 *2、@Aspect 申明这是一个切面类。(也可以理解为代理对象)
 */
@Component("logAspect")
@Aspect
public class LogAspect {
    @After("execution(public * org.freecode.spring.dao.*.add*(..))")
    public void startLog(){
        Logger.info("方法调用结束");
    }
    
    public static class Logger{
        
        public static void info(String message){
            System.out.println(message);
        }
        public static void error(String message){
            System.err.println(message);
        }
    }
}
```
* 执行测试
**结果如下，很简单吧！！**
```
User [id=d7ee1ecd-a50a-4c38-9358-52233d70af4e, name=天王盖地虎, age=21]
方法调用结束
```

### AOP 切点方法
实例中，只是使用`@After`，在方法后执行。
* AOP 切点
   * `@After`  函数调用之前执行。
   * `@Before` 函数调用之后执行。 
   * `@Around`  函数调用过程执行。（用法如下）
   ```
    @Around("execution(public * org.freecode.spring.dao.*.add*(..))")
    public void AroundLog(ProceedingJoinPoint pjp) throws Throwable{
        Logger.info("方法执行开始");
        pjp.proceed();
        Logger.info("方法执行结束");
    }  
   ```

### AOP XML 实例
**在IOC Annotation 的代码的基础上**
* 引入依赖
* 创建一个切面类
```
package org.freecode.spring.aspect;
import org.aspectj.lang.ProceedingJoinPoint;
import org.springframework.stereotype.Component;
@Component("logAspect")
public class LogAspect {
    public void startLog(){
        Logger.info("进入日志管理");
    }
    
    public void AroundLog(ProceedingJoinPoint pjp) throws Throwable{
        Logger.info("方法执行开始");
        pjp.proceed();
        Logger.info("方法执行结束");
    }
    
    public void endLog(){
        Logger.info("结束日志管理");
    }
    
    
    public static class Logger{
        
        public static void info(String message){
            System.out.println(message);
        }
        public static void error(String message){
            System.err.println(message);
        }
    }
}
```
* Spring 配置文件配置切面类
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:context="http://www.springframework.org/schema/context"
    xmlns:aop="http://www.springframework.org/schema/aop"
    xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-.0.xsd
        http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-3.0.xsd">
    <!-- 开启使用注解配置 -->
    <context:annotation-config />
    <!-- 告诉Spring 去哪写包找注入Bean -->
    <context:component-scan base-package="org.freecode.spring" />
    
    <!-- ===== 如下AOP 定义LogAspect实例 =====  -->
    
    <!-- AOP 配置 -->
    <aop:config>
        <!-- 定义切面类(1..N) -->
        <aop:aspect id="logAspect" ref="logAspect">
            <!-- 定义 execution 表达式(1..N)-->
            <aop:pointcut id="LogPointcut" 
                    expression="execution(public * org.freecode.spring.dao.*.add*(..))" />
            
            <!-- 哪种切点类型，作用于logAspect哪个方法，并引入哪个execution表达式 -->
            <aop:before method="startLog" pointcut-ref="LogPointcut"/>
            <aop:around method="AroundLog" pointcut-ref="LogPointcut"/>
            <aop:after method="endLog" pointcut-ref="LogPointcut"/>
        </aop:aspect>
    </aop:config>
</beans>
```
* 执行测试，测试结果如下
```
进入日志管理
方法执行开始
User [id=c5064ec5-bc49-4d88-8e8a-8d721807157b, name=天王盖地虎, age=21]
方法执行结束
结束日志管理  
```

## 结束
Spring 的路还有很长，IOC和AOP只是Spring最最基础的两大核心。
这就像天梯一样，满满爬。

* Spring 基于XML的IOC，用到人并不多，一般都是Annotation的。
* Spring 基于XML的AOP，更加的清楚，很多人愿意使用，同样Annotation也蛮方便的，那就折中把~ 用哪一个看心情
