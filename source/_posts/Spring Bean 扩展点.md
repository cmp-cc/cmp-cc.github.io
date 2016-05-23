----
title: Spring Bean 扩展点
date: 2014-08-111 23:53:00
updated:
categories: 

- JavaWeb
- Spring

tags:
- Spring
----



* BeanFactoryPostProcessor
* PropertyPlaceholderConfigurer 




## PropertyPlaceholderConfigurer 
它用于配置环境变量、系统属性、等变量。
PropertyPlaceholderConfigurer 是BeanFactoryPostProcessor（Bean工厂后置处理器）的一个实现
通过Spring Bean 配置，将properties文件装配到一个对象中。
**在设置数据源的时候（C3P0、DBCP），`BasicDataSource`对象继承了`PropertyPlaceholderConfigurer` 完成`properties`注入**

### 实例
* properties 文件（jdbc.properties）

```
jdbc.driverClass=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://127.0.0.1:3306/cmpcc?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
jdbc.username=root
jdbc.password=123456  
```
* `PropertyPlaceholderConfigurer `配置Bean
```
    <bean id="propertyConfigurer"
        class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
        <property name="locations">
            <list>
                <value>classpath:jdbc.properties</value>
            </list>
        </property>
        <property name="fileEncoding">
            <value>UTF-8</value>
        </property>
        <property name="ignoreResourceNotFound" value="true" />
        <property name="searchSystemEnvironment" value="true" />
        <property name="systemPropertiesModeName" value="SYSTEM_PROPERTIES_MODE_OVERRIDE" />
    </bean>  
```

### 在开发中的应用。
用于配置站点信息、系统属性、环境变量等
* 

* 系统属性工具类
**用于保存配置属性，继承PropertyPlaceholderConfigurer**
```
public class PropertyUtils extends PropertyPlaceholderConfigurer {

	public static final Logger logger = Logger.getLogger(PropertyUtils.class);

	private static Map<String, String> propertyMap;

	@Override
	protected void processProperties(
			ConfigurableListableBeanFactory beanFactoryToProcess,
			Properties props) throws BeansException {
		super.processProperties(beanFactoryToProcess, props);
		propertyMap = new HashMap<String, String>();
		
		for(Entry<Object, Object> entry : props.entrySet()){
			propertyMap.put(entry.getKey().toString(), entry.getValue().toString());
		}
	}

	public static String getValue(String name) {
		String value = propertyMap.get(name);
		if (StringUtils.isBlank(value)) {
			return "";
		} else {
			return value;
		}
	}
}
```
* beans.xml 配置
```
    <bean id="propertyConfigurer" class="org.freecode.util.PropertyUtils">
        <property name="locations">
            <list>
                <value>classpath:systemconfig.properties</value>
            </list>
        </property>
    </bean>  
```
* systemconfig.properties
```
#超级管理员
system.admin=admin
#存储方式（server | local）
system.storage=server
#数据库配置
jdbc.driverClass=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://127.0.0.1:3306/systemname?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
jdbc.username=root
jdbc.password=123456
jdbc.initialPoolSize=2
jdbc.minPoolSize=2
jdbc.maxPoolSize=5
```




## BeanFactoryPostProcessor