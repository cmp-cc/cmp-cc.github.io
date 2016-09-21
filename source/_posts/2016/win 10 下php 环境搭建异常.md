----
title: win10 下php 环境搭建异常处理
date: 2016-09-21 15:30:00
updated:
categories: 
- Programming Language
- Php
tags:
- Php
----
最近要看php的一个CMS系统，简单学习了一下php，零接触Php，遇到一些问题，简单总结一下。

* 在win10 上安装php，提示缺少 `msvcr110.dll`文件
   * 解决方案：
   ```
   https://download.microsoft.com/download/9/C/D/9CD480DC-0301-41B0-AAAB-FE9AC1F60237/VSU4/vcredist_x64.exe
   ```
* 运行apache httpd  出现缺少 vcruntime140.dll
   * 解决方案：
   ```
   https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x64.exe
   ```
* 运行apache ,Cannot load modules/mod_access_compat.so into server:
   * 异常详情
   ```
   httpd: Syntax error on line 72 of D:/Program-Software/Server-Tools/apache/httpd-2.4.23-win64-VC14/Apache24/conf/httpd.conf: Cannot load modules/mod_access_compat.so into server: \xd5\xd2\xb2\xbb\xb5\xbd\xd6\xb8\xb6\xa8\xb5\xc4\xc4\xa3\xbf\xe9\xa1\xa3
   ```
   * 解决方案
   ```
   由于没有安装到默认目录，httpd.conf 中 ServerRoot默认指定地址为：C\Apache24 路径。
   修改此路径为真实安装目录，打开httpd.conf 修改即可（control+h 修改所有地址）
   ```
* httpd: Could not reliably determine the server's fully qualified domain name
   * 异常详情
   ```
   D:\Program-Software\Server-Tools\apache\httpd-2.4.23-win64-VC14\Apache24\bin>httpd
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using fe80::a174:5e03:3852:dadd. Set the 'ServerName' directive globally to suppress this message
   ```
   * 解决方案：
   ```
   编辑 httpd.conf   加入一句  ServerName  localhost:80
   ```
* apache 无法解析php文件
> 需要让 apache 识别 php 模块并且用 php模块去处理 *.php 文件 ,linux 下，安装完就支持了，win 下需要自己折腾 - -
   * 解决方案
   ```
   // 切记下载完整版php (php 下载一般有两个版本)，不然没有php5apache2_4.dll文件。 (httpd.conf 配置如下即可)
   LoadFile "D:\Program-Software\Programming-Language\Php\php\php-5.5.38-Win32-VC11-x64/libeay32.dll"
   LoadFile "D:\Program-Software\Programming-Language\Php\php\php-5.5.38-Win32-VC11-x64/ssleay32.dll"
   LoadFile "D:\Program-Software\Programming-Language\Php\php\php-5.5.38-Win32-VC11-x64/libpq.dll"
   LoadModule php5_module "D:\Program-Software\Programming-Language\Php\php\php-5.5.38-Win32-VC11-x64\php5apache2_4.dll"
   PHPIniDir "D:\Program-Software\Programming-Language\Php\php\php-5.5.38-Win32-VC11-x64"
   AddType application/x-httpd-php .php
   ```
* mysql 链接异常
   * 解决方案
   ```
   在php目录下 打开php.ini
   打开：window on extension_dir
   打开: extension=php_mysqli.dll
   ```
*  时间格式化异常
   * 异常详情
   ```
   Warning: date(): It is not safe to rely on the system's timezone settings. You are *required* to use the date.timezone setting or the date_default_timezone_set() function. In case you used any of those methods and you are still getting this warning, you most likely misspelled the timezone identifier. We selected the timezone 'UTC' for now, but please set date.timezone to select your timezone
   ```
   * 解决方案
   ```
   php.ini 增加 `date.timezone = Asia/Shanghai`

   ```