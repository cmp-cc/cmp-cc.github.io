----
title: Maven 服务器插件Jetty
date: 2013-11-16 8:54:00
categories: 
- Project Build
- Maven
tags:
- Maven
----

一个常规的Java Web 你需要部署到Tomcat中，使用Maven构建Web项目使用Jetty 容器，使运行Java Web项目更加方便。

## Jetty 完整性配置
```
    <properties>
        <webapp.port>8083</webapp.port>
        <webapp.stopPort>9090</webapp.stopPort>
        <webapp.path>/</webapp.path>
    </properties> 
```


```
            <plugin>
                <groupId>org.mortbay.jetty</groupId>
                <artifactId>jetty-maven-plugin</artifactId>
                <version>8.1.13.v20130916</version>
                <configuration>
                    <webAppConfig>
                        <contextPath>${webapp.path}</contextPath>
                        <defaultsDescriptor>webdefault.xml</defaultsDescriptor>
                    </webAppConfig>
                    <connectors>
                        <connector implementation="org.eclipse.jetty.server.nio.SelectChannelConnector">
                            <port>${webapp.port}</port>
                            <maxIdleTime>60000</maxIdleTime>
                        </connector>
                    </connectors>
                    <reload>automatic</reload>
                    <scanIntervalSeconds>0</scanIntervalSeconds>
                    <!-- stopPort>${webapp.stopPort}</stopPort -->
                    <systemProperties>
                        <systemProperty>
                            <name>org.mortbay.util.URI.charset</name>
                            <value>UTF-8</value>
                        </systemProperty>
                    </systemProperties>
                    <jvmArgs>-Xmx512m -XX:PermSize=128m -XX:MaxPermSize=256m
                        -Dfile.encoding=UTF-8</jvmArgs>
                </configuration>
                <executions>
                    <execution>
                        <id>start-jetty</id>
                        <phase>pre-integration-test</phase>
                        <goals>
                            <goal>run</goal>
                        </goals>
                        <configuration>
                            <scanIntervalSeconds>0</scanIntervalSeconds>
                            <daemon>true</daemon>
                        </configuration>
                    </execution>
                    <execution>
                        <id>stop-jetty</id>
                        <phase>post-integration-test</phase>
                        <goals>
                            <goal>stop</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>  
```

* 运行命令 `jetty:run`
* 停止运行`jetty:stop`

## Jetty 可配置参数
* scanIntervalSeconds 表示扫时间，避免重复运行，它会自动检测是否修改项目文件
* jvmArgs JVM 堆栈大小
* port 端口号
* contextPath 项目路径
