----
title: Postfix 邮件服务器
date: 2015-01-17 09:11:00
updated:
categories: 
- Operating System
- Linux

tags:
- Linux
----

配置Postfix 使用`国内邮箱SMTP`代发

## Postfix 配置

> 保证系统包含` cyrus-sasl-devel cyrus-sasl-plain cyrus-sasl cyrus-sasl-lib cyrus-imapd` 
> 如果没有通过yum安装

* 安装Postfix
```
yum install postfix 
```
> 系统一般默认安装postfix，你可能需要卸载`sendmail`

* `vi /etc/postfix/main.cf` 添加如下
```
# sets 163 as relay
relayhost = [smtp.163.com]:25

#  use tls
smtp_use_tls = yes

# use sasl when authenticating to foreign SMTP servers
smtp_sasl_auth_enable = yes

# path to password map file
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd

# list of CAs to trust when verifying server certificate
# smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
smtp_tls_CAfile = /etc/pki/tls/certs/ca-bundle.crt

# eliminates default security options which are imcompatible
smtp_sasl_security_options = noanonymous
```
* `vi /etc/postfix/sasl_passwd`
```
[smtp.163.com]:25  baiwoyidao@163.com:xxxx
```
> [mail.host]:port 用户邮箱:密码

* 执行如下命令
```
// 重载配置
sudo postmap /etc/postfix/sasl_passwd
/etc/init.d/postfix reload

// 重新启动Postfix服务
 /etc/init.d/postfix restart

或者
service postfix restart
```
* 测试：给指定邮箱发送邮件
```
echo "hello world cmp-cc" | mail -s Postfix_Test_Mail 452143877@qq.com
```

* 如果找不到`ca-certificates.crt`文件
```
cd /etc/ssl/certs
ln -s ca-bundle.crt ca-certificates.crt
```
> `/etc/ssl/certs` 中有`.pen`的证书也是可以使用的。

* 当无法接收短信，查看异常信息
```
cd /var/spool/mail
vi root
```