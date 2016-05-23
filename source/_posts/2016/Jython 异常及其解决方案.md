----
title: Jython 异常及其解决方案
date: 2016-05-18 17:26:00
updated:
categories: 
- Programming Language
- Jython
tags:
- Jython
----

Jython 确实很少玩，也记录一下异常信息和解决方案把,如果以后有涉及，持续更新。

## cp0

### 异常信息
```
console: Failed to install '': java.nio.charset.UnsupportedCharsetException: cp0.  
```
### 解决方案
```
eclipse.ini 设置 -Dpython.console.encoding=UTF-8

或者

Window -> Preferences -> Java -> installed JRES -> Edit 设置如下：
Default VM arguments: -Dpython.console.encoding=UTF-8
```

{% asset_img  6c1429b8-0e58-4c24-b2c4-58e63a4b771e.png JVM 设置%}

## No module named site
### 异常信息
```
ImportError: Cannot import site module and its dependencies: No module named site
Determine if the following attributes are correct:
  * sys.path: ['C:\\Users\\root\\.m2\\repository\\org\\python\\jython\\2.7.0\\Lib', '__classpath__', '__pyclasspath__/']
    This attribute might be including the wrong directories, such as from CPython
  * sys.prefix: C:\Users\root\.m2\repository\org\python\jython\2.7.0
    This attribute is set by the system property python.home, although it can
    be often automatically determined by the location of the Jython jar file

You can use the -S option or python.import.site=false to not import the site module
```

### 解决方案
```
	static {
		System.setProperty("python.import.site", "false");
	}
```