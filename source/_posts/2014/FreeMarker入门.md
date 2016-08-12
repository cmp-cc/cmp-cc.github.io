----
title: FreeMarker入门
date: 2014-07-07 16:53:00
updated:
categories: 

- JavaWeb
- FreeMarker

tags:
- FreeMarker
----
FrameMarker 模板语言: FreeMarker Template Language ( FTL )。

* FreeMarker 入门实例
   * Hello World 实例,了解Freemarkers 执行步骤
   * Types 实例，了解FreeMarker 内置类型转换

* 引入依赖
```
<dependency>
    <groupId>org.freemarker</groupId>
    <artifactId>freemarker</artifactId>
    <version>2.3.23</version>
</dependency>
```

## Hello World 实例

* 在`resources目录`创建`hello.ftl`文件
```
Hello,${name}!  
```
>`.ftl`文件作为Freemarker 模板语言文件后缀,`${name}`会替换Model中的属性值

* 编写Java程序
```
package org.freecode.ftl;
import java.io.File;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.HashMap;
import java.util.Map;
import freemarker.template.Configuration;
import freemarker.template.DefaultObjectWrapper;
import freemarker.template.Template;
import freemarker.template.TemplateException;
    
public class HelloFreemarker {
    public static void main(String[] args) 
    throws IOException, TemplateException {
        // 创建Freemarker 配置对象(模板工厂对象),并指定当前版本号。
        Configuration cfg = new Configuration(Configuration.DEFAULT_INCOMPATIBLE_IMPROVEMENTS);
        
        //选择一种Model对象包装(Object Wrapper)类型.模板获取Model中的值. 默认如下,可忽略
        cfg.setObjectWrapper(new DefaultObjectWrapper(Configuration.DEFAULT_INCOMPATIBLE_IMPROVEMENTS));
        
        // 模板目录父类目录地址
        cfg.setDirectoryForTemplateLoading(new File("src/main/resources/"));
        
        //Model 对象
        Map<String, Object> model = new HashMap<String, Object>();
        model.put("name", "world");
        
        //获取一个模板对象。 需要告诉配置实例对象加载个哪个模板
        Template template = cfg.getTemplate("hello.tfl");
        
        /*
         * 处理模板,需要两个参数：
         * 1、使用哪个Model?
         * 2、输出到什么地方?
         */
        template.process(model, new OutputStreamWriter(System.out));
    }
}  
```
* 运行程序，显示如下
```
Hello World
```
* 修改`model.put("name", "world");` 为`model.put("name", 123456789);` 查看输出
```
Hello,123,456,789!  
```
> 输出的格式取决默认的语言环境，如果在德国将看到输出为：`Hello,123.456.789!`
> Freemarker默认使用`java.text.DecimalFormat`对象数字类型进行格式化输出

## types 实例
为了精确控制对象将模型转换成文本（转换类型值到文本），我们可以使用FreeMarker提供的内置插件控制格式转换，如下：`types.ftl`
```
String: ${string?html}
Number: ${number?c}
Boolean: ${boolean?string("+++++", "-----")}
Date: ${.now?time}
Complex: ${object}
```
>`.now`是一个特殊的变量，用于处理日期和时间，`?`后跟内置插件名称

* 创建一个Java程序
```
package org.freecode.ftl;
import java.io.File;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
public class FreemarkerTypes {
  public static void main(String[] args) 
  throws IOException, TemplateException {
    Configuration cfg = new Configuration(Configuration.DEFAULT_INCOMPATIBLE_IMPROVEMENTS);
    cfg.setDirectoryForTemplateLoading(new File("src/main/resources"));
    Map<String, Object> model = new HashMap<String, Object>();
    model.put("string", "easy & fast ");
    model.put("number", new BigDecimal("1234.5678"));
    model.put("boolean", true);
    model.put("object", Locale.US);
    Template template = cfg.getTemplate("types.ftl");
    template.process(model, new OutputStreamWriter(System.out));
  }
}  
```
* 格式化实例输出如下
```
String: easy &amp; fast 
Number: 1234.5678
Boolean: +++++
Date: 10:13:59
Complex: en_US  
```
* 内置插件如何影响输出的呢？
   * 字符串：输出一个字符串，使用内置插件名称`html`,它将字符串编码为HTML，将`&`转换为`&amp;`HTML实体，它确保文本正确显示，并防止跨站脚本攻击(XSS)
   * 数字：数字对象使用内置`c`,它告诉FreeMarker将数字类型使用文本解析。
   * 布尔：这里类似一个三目表达式。FreeMarker不会去格式化布尔值，从概念上讲，`true`和`false`并没有通用的文本表示，如果我们不带任何参数(`${boolean}`),它将抛出一个异常。
   * 日期：FreeMarker没有内置处理`java.util.Date`,因为它不知道如何显示日期和时间，或者两则，通过`time`告诉FreeMarker我们要显示时间。
   * 复杂对象: 没有使用内置插件。 对于复杂对象，它默认使用`toString`返回一个字符串类型，所以可以使用内置字符串插件来处理。


