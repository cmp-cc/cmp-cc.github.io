----
title: Mysql 异常及其解决方案
date: 2013-05-17 12:53:00
updated: 2016-05-04 16:33:00
categories: 
- Data Base Management System
- Mysql

tags:
- Mysql
----

**记录遇到过的Mysql错误，及其解决方案，持续更新**

## ERROR 1130
**本地链接远程Mysql 数据库异常**
### 错误信息
```
1130: Host 192.168.12.153 is not allowed to connect to this MySQL server
```
### 解决方案
**开启远程访问权限**

```
mysql -u root -p -h localhost -P 3306

use mysql

// 所有IP，均可访问
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'IDENTIFIED BY '123456' WITH GRANT OPTION;

// 如下指定特定IP，同样可以指定用户，及其密码
// GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.10.72'IDENTIFIED BY '123456' WITH GRANT OPTION;

// 所有IP
//GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'WITH GRANT OPTION;

FLUSH PRIVILEGES;
```

> 参看doc：http://dev.mysql.com/doc/refman/5.1/en/adding-users.html
> http://dev.mysql.com/doc/refman/5.7/en/grant.html

## ERROR 1045
### 错误信息

**使用root 且密码正确，无法登陆，**
```
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
```

### 解决方案
**由于是root用户无法登陆，需要先打开无密码登陆**

* 解决1045错误
```
update user set authentication_string=PASSWORD('123456') where user='root' and host='localhost';

```



## ERROR 1406 (22001)`和`ERROR 1366 (HY000)`
### 错误信息
**导入数据出现`ERROR 1406 (22001):`和`ERROR 1366 (HY000)` 错误**

{% asset_img e8a266cd-6e44-4a0b-967d-4cd707c1f23e.png 错误详情 %}
### 解决方案：
命令行窗口默认为GBK编码,而SQL文件为UTF-8,进行数据导入，它并不买账。 即便你使用"set names utf8;",也是无效的,这是系统编码问题。有如下两种解决方案。
* 使用图形化界面进行SQL导入，非常容易。（sqlyog之类的图形工具）
*  进行如下操作
    * 启动CMD(Window 命令行工具) -> 输入chcp 65001 -> 它将进入utf-8模式。
    * mysql -u root -p  进行SQL 控制台 -> source f:/xx/xx.sql 进行数据导入
    * 如果你想在改为GBK模式。 输入:chcp 936

{% asset_img dd1f2b82-0c9c-49fe-885d-f5e20619c8f1.png 执行成功信息 %}
## ERROR 1045 (28000)
### 错误信息
```
ERROR 1045 (28000): Access denied for user 'root'@'localhost'
```
### 解决方案
**如果不是root用户出现1045，直接使用root 对象该用户进行授权即可**
* 使用 mysql -u root 无密码登陆。
```
// 关闭mysql
service mysqld stop
vi /etc/my.cnf
// 将skip-grant-tables 添加至末尾,并保存
service mysqld start
```
* 重新设置密码
```
//选择数据库
use mysql
// 设置密码。  5.7 相比5.5 user表中password字段改为authentication_string。如下
update user set authentication_string=PASSWORD('123456') where user='root' and host='localhost';
//更新权限表
flush privileges;
```
* 关闭无密码
```
// 关闭数据库
//删除skip-grant-tables 
//开启数据库
```

## ERROR 1820 (HY000)
### 错误信息
```
ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.
```
### 解决方案
重设密码，如下：localhost
```
SET PASSWORD = PASSWORD('localhost');
```

