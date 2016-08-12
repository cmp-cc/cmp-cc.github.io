----
title: Azkaban 短信预警插件开发
date: 2016-06-09 22:53:00
updated:
categories: 
- Workflow
- Bigdata Workflow
tags:
- Workflow
- Azkaban
----

Azkaban本身具有邮件预警功能，我们可以通过设置SLA，进行邮件失败警告或成功提示。但是邮件预警一般不能及时响应处理。（我们并不会及时查看邮件）。 为增加强应急响应，开发Azkaban 短信预警插件，及时向管理员、运维人员发出警告提示。


## 短信 API
**这里采用[云片](http://www.yunpian.com/) 手机短信服务，在此基础上封装一层API，使其发短信更加容易。**

服务器端首先生成`apikey`，用于身份认证，无消亡时间。
API 接口：
```
curl -k -X POST --data "apikey=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx&mobile=18271932456&text=Azkaban 短信预警API服务" http://sms.avlyun.org/send.json
```

## Azkaban 插件开发

先吐槽：Azkaban 的文档写的稀巴烂(太多残缺，很多错误)，项目维护不积极，很多人已经投身`Airflow`。 还有LinkedIn 这家公司确定要卖掉啦~。


**Azkaban 源码提供了约定俗成预警插件写法：**
* 继承 `azkaban.executor.ExecutableFlow.Alerter` 接口，实现相关预警方法。
* `azkaban.properties`通过`alerter.plugin.dir`指定预警插件存放目录，或者默认为：`plugins/alerter`
* 插件包含`conf/plugin.properties`、`extlib`、`lib`、插件代码。
* `plugin.properties`必须包含`alerter.name`(名称)、`alerter.external.classpaths`(额外jar,就是extlib)、`alerter.class`(插件主类)



### SMS 插件编码
**原Azkaban Plugin 使用Ant构建，这里就使用Mavne 进行构建。 （效果是一模一样的）**

* 创建Maven项目，其目录结构如下

{%asset_img 232f9c5a-ec8a-43c9-8907-88a9c4d8cc80.png 项目目录结构 %}

* pom.xml 依赖及其项目构建插件
```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>org.freecode</groupId>
    <artifactId>azkaban-sms</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>jar</packaging>
    <name>azkaban-sms</name>
    <url>http://maven.apache.org</url>
    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.9</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>com.linkedin.azkaban</groupId>
            <artifactId>azkaban</artifactId>
            <version>2.5.0</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>log4j</groupId>
            <artifactId>log4j</artifactId>
            <version>1.2.16</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>org.apache.httpcomponents</groupId>
            <artifactId>httpclient</artifactId>
            <version>4.5.1</version>
        </dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.5.1</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
            <plugin>
                <artifactId>maven-assembly-plugin</artifactId>
                <version>2.6</version>
                <executions>
                    <execution>
                        <id>Azkaban-sms</id>
                        <phase>package</phase>
                        <goals>
                            <goal>single</goal>
                        </goals>
                        <configuration>
                            <descriptors> 
                                <descriptor>src/assembly/build.xml</descriptor>
                            </descriptors>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```
* 配置`src/assembly/build.xml` 文件
```
<assembly
    xmlns="http://maven.apache.org/plugins/maven-assembly-plugin/assembly/1.1.3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/plugins/maven-assembly-plugin/assembly/1.1.3 http://maven.apache.org/xsd/assembly-1.1.3.xsd">
    <id>release</id>
    <formats>
        <format>zip</format>
    </formats>
    <baseDirectory>azkaban-sms</baseDirectory>
    <fileSets>
        <fileSet>
            <directory>src/main/resources</directory>
            <outputDirectory>conf</outputDirectory>
            <includes>
                <include>plugin.properties</include>
            </includes>
        </fileSet>
        <fileSet>
            <directory>src/assembly</directory>
            <outputDirectory>extlib</outputDirectory>
            <excludes>
                <exclude>*</exclude>
            </excludes>
        </fileSet>
    </fileSets>
    <dependencySets>
        <dependencySet>
            <useProjectArtifact>true</useProjectArtifact>
            <outputDirectory>lib</outputDirectory>
            <scope>runtime</scope>
        </dependencySet>
    </dependencySets>
</assembly>  
```
* SMSAlerter 代码编写
```
package org.freecode.azkaban;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;
import org.apache.http.Consts;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;
import org.apache.log4j.Logger;
import azkaban.alert.Alerter;
import azkaban.executor.ExecutableFlow;
import azkaban.sla.SlaOption;
import azkaban.utils.Props;
import azkaban.utils.Utils;
public class SMSAlerter implements Alerter {
    private static final Logger logger = Logger.getLogger(SMSAlerter.class);
    private SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
    private CloseableHttpClient httpclient = HttpClients.createDefault();
    
    // 手机号验证
    private static final Pattern phoneValidPattern = Pattern
            .compile("1[0-9]{10}");
    // 短信API地址
    private String smsHost;
    // ApiKey
    private String smsTokenKey;
    // ApiKey
    private String smsToken;
    // 短信手机号参数名称
    private String smsPhoneKey;
    // 预警手机号
    private List<String> smsPhone;
    // 短信内容参数名称
    private String smsTextKey;
    // 测试模式 : 当为true时,只打印日志，不发送短信。
    // 当为false时,打印日志，且发送短信。
    private boolean testMode;
    public SMSAlerter(Props props) {
        /*
         * props.getString 第一个参数获取plugin.propertiy 文件获取对应值，如果没有找到使用第二默认参数
         * 
         * 这里没有设置默认值，你可以通过修改源码设置它
         */
        this.smsHost = props.getString("sms.host");
        this.smsTokenKey = props.getString("sms.token.key");
        this.smsToken = props.getString("sms.token");
        this.smsPhoneKey = props.getString("sms.phone.key", "mobile");
        // 多个手机号使用空格、,、:、#、%、& 进行分割
        this.smsPhone = props.getStringList("sms.phone", "[ ,:#%&]");
        this.smsTextKey = props.getString("sms.text.key");
        this.testMode = props.getBoolean("sms.test.model", true);
        
        /**
         * 可配置一个配置项，通知一个手机号。 提示Azkaban SMS Plugin 加载成功。 当然也可以通过日志 
         */
        //sendSMS(Arrays.asList("18271932456"), "Azkaban SMS Plugin 加载成功!");
        logger.info("Azkaban SMS Plugin 加载成功!");
    }
    // 向配置文件中的手机号发送短信
    private void sendSMS(String msg) {
        sendSMS(this.smsPhone, msg);
    }
    private void sendSMS(List<String> phoneList, String msg) {
        if (smsPhone != null) {
            logger.info(String.format("欲发送%s位联系人,分别为:%s", smsPhone.size(),
                    smsPhone.toString()));
        }
        for (String phone : phoneList) {
            if (!phoneValidPattern.matcher(phone).matches()) {
                logger.error("输入手机号无效,请确保手机号长度为11位");
                continue;
            }
            List<NameValuePair> formparams = new ArrayList<NameValuePair>();
            formparams.add(new BasicNameValuePair(this.smsTokenKey,
                    this.smsToken));
            formparams.add(new BasicNameValuePair(this.smsTextKey, msg));
            formparams.add(new BasicNameValuePair(this.smsPhoneKey, phone));
            UrlEncodedFormEntity entity = new UrlEncodedFormEntity(formparams,
                    Consts.UTF_8);
            HttpPost httpPost = new HttpPost(this.smsHost);
            httpPost.setEntity(entity);
            CloseableHttpResponse response = null;
            try {
                if (!testMode) {
                    response = httpclient.execute(httpPost);
                    logger.info(String.format("当前发送至：%s,发送状态为: %s", phone,
                            response.getStatusLine()));
                } else {
                    logger.info(String.format("当前为测试模式,欲发送至：%s", phone));
                }
                Thread.sleep(1000); // 延迟一秒
            } catch (ClientProtocolException e) {
                logger.error("failed to send message " + msg + " to " + phone,
                        e);
            } catch (IOException e) {
                logger.error("failed to send message " + msg + " to " + phone,
                        e);
            } catch (InterruptedException e) {
                logger.warn("send message interrupted ", e);
                Thread.interrupted();
            } finally {
                if (response != null) {
                    try {
                        response.close();
                    } catch (IOException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                }
            }
        }
    }
    /**
     * 
     * @param flow
     * @param status 工作流执行状态，应当为一个枚举值： SUCCESS 和 FAILD、FIRST FAILD
     */
    private void sendEmail(ExecutableFlow flow,List<String> sendList,String status) {
        List<String> phoneList = new ArrayList<>();
        for (String phone : sendList) {
            if (phoneValidPattern.matcher(phone).matches()) {
                phoneList.add(phone);
            }
        }
        logger.info(String.format("捕获Email列表为：%s,过滤手机号列表为:%s",sendList,phoneList ));
        
        StringBuffer textMsg = new StringBuffer();
        textMsg.append(String.format("Antiy Azkaban 3.0 工作流执行状态: %s \n", status));
        textMsg.append(String.format("       工作流项目名称为：%s,目前已经执行%s!\n",
                flow.getFlowId(),status));
        textMsg.append(String.format("Execution ID:%s\n", flow.getExecutionId()));
        textMsg.append(String.format("运行开始时间:%s\n", dateFormat.format(flow.getStartTime())));
        textMsg.append(String.format("运行结束时间:%s\n", dateFormat.format(flow.getStartTime())));
        textMsg.append(String.format("共耗时：%s\n",
                Utils.formatDuration(flow.getStartTime(), flow.getEndTime())));
        // 发送至全局手机配置
        sendSMS(textMsg.toString());
        // 发送至局部手机配置
        sendSMS(phoneList, textMsg.toString());
    }
    @Override
    public void alertOnSuccess(ExecutableFlow exflow) throws Exception {
        sendEmail(exflow,exflow.getExecutionOptions().getSuccessEmails(),"成功");
    }
    @Override
    public void alertOnError(ExecutableFlow exflow, String... extraReasons)
            throws Exception {
        sendEmail(exflow,exflow.getExecutionOptions().getFailureEmails(),"失败");
    }
    @Override
    public void alertOnFirstError(ExecutableFlow exflow) throws Exception {
        sendEmail(exflow,exflow.getExecutionOptions().getFailureEmails(),"First 失败");
    }
    @Override
    public void alertOnSla(SlaOption slaOption, String slaMessage)
            throws Exception {
        @SuppressWarnings("unchecked")
        List<String> emailList = (List<String>) slaOption.getInfo().get(
                SlaOption.INFO_EMAIL_LIST);
        logger.info("SAL 信息：" + emailList.toString());
        logger.info("SAL info :" + slaOption.getInfo().toString());
        logger.info("SAL type :" + slaOption.getType().toString());
        logger.info("SAL actions :" + slaOption.getActions().toString());
        List<String> phoneList = new ArrayList<>();
        for (String email : emailList) {
            if (!phoneValidPattern.matcher(email).matches()) {
                phoneList.add(email);
            }
        }
        sendSMS(phoneList, slaMessage);
        sendSMS(slaMessage);
    }
}
```
* 配置`plugin.properties` 文件
```

alerter.name=sms
alerter.external.classpaths=extlib/
alerter.class=org.freecode.azkaban.SMSAlerter

#SMSAlerter conf

# sms api host
sms.host=http://sms.avlyun.org/send.json
# 认证参数名称
sms.token.key=apikey
# 认证token
sms.token=xxxxxxxxxxxxxxxx
# 手机参数名称
sms.phone.key=mobile
# 配置全局手机，可配置多个
sms.phone=18271932456
# 短信内容参数名称
sms.text.key=text
# 是否开启测试模式（false 表示发送短信）
sms.test.model=false 
```
> 你可以需要修改部分代码，来完成与短信接口的映射。

* 构建项目
```
mvn package
```
* 查看项目构建

{%asset_img 21023a17-a161-44e4-bed3-5255ddb801f3.png Azkaban SMS构建成功%}
> `azkaban-sms-0.0.1-SNAPSHOT-release.zip` 为Azkaban SMS插件


## 部署Azkaban SMS Plugin
* `plugins`目录 创建`alerter`
```
cd /usr/local/azkaban3.0/azkaban-web-server-3.0.0/plugins
mkdir alerter
cd alerter
```
* 拷贝至`alerter`目录，解压、配置
```
unzip azkaban-sms-0.0.1-SNAPSHOT-release.zip
rm -f azkaban-sms-0.0.1-SNAPSHOT-release.zip
cd azkaban-sms/
vi conf/plugin.properties 

#配置短信API接口
#配置全局手机接收人（可以为空）
#配置是否为测试模式
```
**重新启动`Azkaban-web`，你可以通过日志`logs/azkaban-web.log` 参数执行状态**

## 配置job作业
想要启动短信预警，必须配置`alert.type`属性为`sms`，只有配置`alert.type=sms`，局部短信和全局短信才能发送，有如下两种方式配置。
* 在`job`文件中添加`alert.type=sms`
* 在图形界面执行时配置，如下：

{%asset_img ab788c20-ba61-4016-9360-2821f5a110e9.png 图形界面配置alert.type参数%}
### 配置全局短信发送
在`/plugin.properties`中通过sms.phone配置全局接收人。（每一个设置了`alerttype=sms` 的工作流作业，全局接收人都会接受到作业状态，无论成功或失败）
```
sms.phone=18271932456#15290043676#xxxxx

或者不进行设置

sms.phone=
```
### 配置局部短信发送
在执行任务时，进行配置，配置如下： （包含手机联系人、Email联系人）
{%asset_img 49c6172e-6fd4-42c5-9dae-2c5825e41855.png 任务短信配置%}

## 日志信息
* 你可以通过日志信息查看发送状态，如下在测试模式下进行短信发送。

{%asset_img 35af5fe8-f88b-4aed-8957-46d627cdfa90.png 测试模式日志信息%}




* 当然你也会看到`javax.mail.SendFailedException: Invalid Addresses;`异常信息
**这里并没有开发一个新的页面，而是在局部邮件发送，填写了联系人号码（请忽略这个异常）**
```
javax.mail.SendFailedException: Invalid Addresses;
  nested exception is:
        com.sun.mail.smtp.SMTPAddressFailedException: 500 Error: bad syntax
;
  nested exception is:
        com.sun.mail.smtp.SMTPAddressFailedException: 500 Error: bad syntax

 
```