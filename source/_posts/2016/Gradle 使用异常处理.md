----
title: Gradle 使用异常处理
date: 2016-05-30 14:43:00
updated:
categories: 
- Project Build
- Gradle
tags:
- Gradle
----
**Gradle 使用遇到的异常及其解决方案，持续更新**

##  -Xlint:unchecked
### 异常描述
```
:azkaban-common:compileJava  
C:\Users\root\.gradle\caches\modules-2\files-2.1\com.google.guava\guava\13.0.1\d6f22b1e60a2f1ef99e22c9f5fde270b2088365\guava-13.0.1.jar(com/google/common/util/concurrent/Monitor.class): 警告: 无法找到类型 'GuardedBy' 的注释方法 'value()': 找不到javax.annotation.concurrent.GuardedBy的类文件
C:\Users\root\.gradle\caches\modules-2\files-2.1\com.google.guava\guava\13.0.1\d6f22b1e60a2f1ef99e22c9f5fde270b2088365\guava-13.0.1.jar(com/google/common/util/concurrent/Monitor.class): 警告: 无法找到类型 'GuardedBy' 的注释方法 'value()'
C:\Users\root\.gradle\caches\modules-2\files-2.1\com.google.guava\guava\13.0.1\d6f22b1e60a2f1ef99e22c9f5fde270b2088365\guava-13.0.1.jar(com/google/common/util/concurrent/Monitor.class): 警告: 无法找到类型 'GuardedBy' 的注释方法 'value()'
C:\Users\root\.gradle\caches\modules-2\files-2.1\com.google.guava\guava\13.0.1\d6f22b1e60a2f1ef99e22c9f5fde270b2088365\guava-13.0.1.jar(com/google/common/util/concurrent/Monitor.class): 警告: 无法找到类型 'GuardedBy' 的注释方法 'value()'
C:\Users\root\.gradle\caches\modules-2\files-2.1\com.google.guava\guava\13.0.1\d6f22b1e60a2f1ef99e22c9f5fde270b2088365\guava-13.0.1.jar(com/google/common/util/concurrent/Monitor.class): 警告: 无法找到类型 'GuardedBy' 的注释方法 'value()'
C:\Users\root\.gradle\caches\modules-2\files-2.1\com.google.guava\guava\13.0.1\d6f22b1e60a2f1ef99e22c9f5fde270b2088365\guava-13.0.1.jar(com/google/common/util/concurrent/Monitor.class): 警告: 无法找到类型 'GuardedBy' 的注释方法 'value()'
C:\Users\root\.gradle\caches\modules-2\files-2.1\com.google.guava\guava\13.0.1\d6f22b1e60a2f1ef99e22c9f5fde270b2088365\guava-13.0.1.jar(com/google/common/util/concurrent/Monitor.class): 警告: 无法找到类型 'GuardedBy' 的注释方法 'value()'
C:\Users\root\.gradle\caches\modules-2\files-2.1\com.google.guava\guava\13.0.1\d6f22b1e60a2f1ef99e22c9f5fde270b2088365\guava-13.0.1.jar(com/google/common/util/concurrent/Monitor.class): 警告: 无法找到类型 'GuardedBy' 的注释方法 'value()'
C:\Users\root\Desktop\笔记\Azkaban\Resources\azkaban-new\azkaban-master\azkaban-common\src\main\java\azkaban\executor\ExecutorInfo.java:109: 警告: [EqualsHashCode] Classes that override equals should also override hashCode.
    public boolean equals(Object obj)
                   ^
    (see http://errorprone.info/bugpattern/EqualsHashCode)
注: 某些输入文件使用了未经检查或不安全的操作。
注: 有关详细信息, 请使用 -Xlint:unchecked 重新编译。
9 个警告  
```

### 解决方案
参考：http://stackoverflow.com/questions/18689365/how-to-add-xlintunchecked-to-my-android-gradle-based-project

Gradle 添加如下配置，可消除Java编译警告
```
/**
 * Gradle wrapper task.
 * 当前的Gradle 版本
 */
task wrapper(type: Wrapper) {
  gradleVersion = '2.13'
} 
 
allprojects {
    gradle.projectsEvaluated {
        tasks.withType(JavaCompile) {
            options.compilerArgs << "-Xlint:unchecked" << "-Xlint:deprecation"
        }
    }
}

```


