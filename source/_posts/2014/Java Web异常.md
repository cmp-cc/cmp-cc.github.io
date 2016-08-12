----
title: Java Web异常
date: 2014-10-10 20:05:17
updated:
categories: 
- Java Web
tags:
- Java Web
----

记录一下Java Web 遇到的一些异常情况.

## org.apache.catalina.LifecycleException
### 异常信息
**使用Spring MVC 启动的时候发生**
```
严重: ContainerBase.addChild: start: 
org.apache.catalina.LifecycleException: Failed to start component [StandardEngine[Catalina].StandardHost[localhost].StandardContext[/upload2]]
	at org.apache.catalina.util.LifecycleBase.start(LifecycleBase.java:154)
	at org.apache.catalina.core.ContainerBase.addChildInternal(ContainerBase.java:724)
	at org.apache.catalina.core.ContainerBase.addChild(ContainerBase.java:700)
	at org.apache.catalina.core.StandardHost.addChild(StandardHost.java:714)
	at org.apache.catalina.startup.HostConfig.deployDescriptor(HostConfig.java:581)
	at org.apache.catalina.startup.HostConfig$DeployDescriptor.run(HostConfig.java:1686)
	at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
	at java.util.concurrent.FutureTask.run(FutureTask.java:266)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
	at java.lang.Thread.run(Thread.java:744)
Caused by: java.lang.NoClassDefFoundError: org/springframework/web/context/request/async/CallableProcessingInterceptor
	at java.lang.Class.getDeclaredFields0(Native Method)
	at java.lang.Class.privateGetDeclaredFields(Class.java:2570)
	at java.lang.Class.getDeclaredFields(Class.java:1903)
	at org.apache.catalina.util.Introspection.getDeclaredFields(Introspection.java:106)
	at org.apache.catalina.startup.WebAnnotationSet.loadFieldsAnnotation(WebAnnotationSet.java:258)
	at org.apache.catalina.startup.WebAnnotationSet.loadApplicationServletAnnotations(WebAnnotationSet.java:137)
	at org.apache.catalina.startup.WebAnnotationSet.loadApplicationAnnotations(WebAnnotationSet.java:65)
	at org.apache.catalina.startup.ContextConfig.applicationAnnotationsConfig(ContextConfig.java:331)
	at org.apache.catalina.startup.ContextConfig.configureStart(ContextConfig.java:770)
	at org.apache.catalina.startup.ContextConfig.lifecycleEvent(ContextConfig.java:302)
	at org.apache.catalina.util.LifecycleSupport.fireLifecycleEvent(LifecycleSupport.java:117)
	at org.apache.catalina.util.LifecycleBase.fireLifecycleEvent(LifecycleBase.java:90)
	at org.apache.catalina.core.StandardContext.startInternal(StandardContext.java:5083)
	at org.apache.catalina.util.LifecycleBase.start(LifecycleBase.java:150)
	... 10 more
Caused by: java.lang.ClassNotFoundException: org.springframework.web.context.request.async.CallableProcessingInterceptor
	at org.apache.catalina.loader.WebappClassLoader.loadClass(WebappClassLoader.java:1324)
	at org.apache.catalina.loader.WebappClassLoader.loadClass(WebappClassLoader.java:1177)
	... 24 more
```

### 解决方案：

* 引入[PayPal Core](http://mvnrepository.com/artifact/com.paypal.sdk/paypal-core) 到`WEB-INF\lib` 或Maven依赖。
* 参考：
`http://stackoverflow.com/questions/18404916/failed-to-start-component-standardenginecatalina-standardhostlocalhost-stan`


## VerifyError

### 错误详情
本地使用jetty 运行，进行数据访问是ok的。  部署到服务器（tomcat）中出现如下异常。
```
java.lang.VerifyError: (class: org/jboss/netty/channel/socket/nio/NioWorkerPool, method: newWorker signature: (Ljava/util/concurrent/Executor;)Lorg/jboss/netty/channel/socket/nio/AbstractNioWorker;) Wrong return type in function
	org.elasticsearch.transport.netty.NettyTransport.createClientBootstrap(NettyTransport.java:349)
	org.elasticsearch.transport.netty.NettyTransport.doStart(NettyTransport.java:277)
	org.elasticsearch.common.component.AbstractLifecycleComponent.start(AbstractLifecycleComponent.java:68)
	org.elasticsearch.transport.TransportService.doStart(TransportService.java:170)
	org.elasticsearch.common.component.AbstractLifecycleComponent.start(AbstractLifecycleComponent.java:68)
	org.elasticsearch.client.transport.TransportClient$Builder.build(TransportClient.java:159)
	com.EsUtil.SecObjectFactory_814.makeObject(SecObjectFactory_814.java:49)
	org.apache.commons.pool.impl.GenericObjectPool.addObject(GenericObjectPool.java:1691)
	com.EsUtil.ESconnectionPool_814.addObject(ESconnectionPool_814.java:47)
	com.EsUtil.ESconnectionPool_814.<init>(ESconnectionPool_814.java:32)
	com.EsUtil.ESUtil.<clinit>(ESUtil.java:14)
	com.action.SimilarAction.<init>(SimilarAction.java:79)
	sun.reflect.NativeConstructorAccessorImpl.newInstance0(Native Method)
	sun.reflect.NativeConstructorAccessorImpl.newInstance(NativeConstructorAccessorImpl.java:62)
	sun.reflect.DelegatingConstructorAccessorImpl.newInstance(DelegatingConstructorAccessorImpl.java:45)
	java.lang.reflect.Constructor.newInstance(Constructor.java:422)
	java.lang.Class.newInstance(Class.java:442)
```

### 解决方案
设置Tomcat JVM 启动参数.`vi /bin/catalina.sh` 添加如下：
```
export JAVA_OPTS="-XX:-UseSplitVerifier"
```