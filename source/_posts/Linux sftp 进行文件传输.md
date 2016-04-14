----
title: Linux sftp 进行文件传输
date: 2014-11-28 20:32:00
categories: 
- 操作系统
tags:
- Linux
----

使用Winscp 进行Window 和 Linux 之间进行文件传输确实很方便，你只需要拖拽就可以，非常方便。

Linux 与 Linux 之间进行文件传输，我们可以直接使用scp命令即可。

这里介绍 sftp 进行文件传输， 我习惯使用SecureCRT（SSH终端仿真程序）进行sftp操作。

同样，你可以使用rs、sz 进行文件传输，它只作用于单文件传输。



## sftp 基础命令

命令 | 说明
--- | ---
ascii                          | Set transfer mode to ASCII
binary                         | Set transfer mode to binary
cd path                        | Change remote directory to 'path'
detail remote-path             | Display system information about remote file or folder
ldetail local-path             | Display system information about local file or folder
lcd path                       | Change local directory to 'path'
chgrp group path               | Change group of file 'path' to 'group'
chmod mode path                | Change permissions of file 'path' to 'mode'
chown owner path               | Change owner of file 'path' to 'owner'
exit                           | Quit sftp
help                           | Display this help text
include filename               | Include commands from 'filename' Alternate: < filename
get [-a l -b] remote-path      | Download file force ascii (-a) or binary (-b) mode
ln [-s] existingpath linkpath  | Hardlink / symlink remote file
ls [options] [path]            | Display remote directory listing
lls [options] [path]           | Display local directory listing
mkdir path                     | Create remote directory
lmkdir path                    | Create local directory
mv oldpath newpath             | Move remote file
open [user@]host[:port]        | Connect to remote host
put [-a l -b] local-path       | Upload file force ascii (-a) or binary (-b) mode
pwd                            | Display remote working directory
lpwd                           | Print local working directory
quit                           | Quit sftp
rmdir path                     | Remove remote directory
lrmdir path                    | Remove local directory
rm path                        | Delete remote file
lrm path                       | Delete local file
su username                    | Substitutes the current user This is only supported with VShell for Windows 3.5 or later.
type [transfer-mode]           | Display or set file transfer mode
view remote-path               | Download and open file
version                        | Display protocol version

## 进入sftp 模式
* 命令行模式下输入 ：`sftp 用户名@IP地址` ， 然后会提示你输入密码
* 如果是SecureCRT。 `Alt+p` 或者 `File -> 链接sftp`

## sftp 基本使用
sftp主要是用来传输文件的，所以我们主要使用两个命令。
> 提示 
### 文件上传 （从本机到远程主机）

**使用 put [-Ppr] local [remote]**

**实例1： 上传单个文件**
```
// 查看Window 当前目录
sftp> lpwd
C:/Users/root/Documents

// 切换Window 上传目录
sftp> lcd d:/temp 
// 查看roles.csv文件
sftp> lls -l
 Oct 23, 2014 14:30 
 Oct 21, 2014 11:21 actors.csv
 Nov 10, 2014 11:01 ali
 Oct 21, 2014 11:19 movies.csv
 Jan 14, 2014 16:56 neo4j
 Oct 28, 2014 17:40 package.json
 Oct 21, 2014 11:21 roles.csv
 Nov 30, 2014 20:54 TV.war
 // 查看当前终端路径
sftp> pwd                
/usr/local/program/server_tool/apache-tomcat-7.0.32/webapps

// 切换到上传路径
sftp> cd ~
sftp> pwd
/home/centos

// 使用put 进行文件上传
sftp> put roles.csv ./
Uploading roles.csv to /home/centos/roles.csv
Skipping directory d:/temp
  100% 367 bytes    367 bytes/s 00:00:00     
d:/temp/roles.csv: 367 bytes transferred in 0 seconds (367 bytes/s)

// 查看，ok 成功的。
sftp> ls
roles.csv
```
**实例2： 上传文件目录**
`put -r 目录名称 目录名称` `-r` 表示文件夹。
```
// 很简单，参考实例1。 默认上传当前路径
put -r download/

```

**实例3： 上传所有文件**
* 上传当前所有文件 到 远程目录
```
put * 
```
* 上传当前所有文件及其文件夹 到 远程目录
```
put -r *
```
### 文件下载(从远程主机到本机)

**使用 get [-Ppr] remote [local]**


**关于get (文件下载)说明 和 实例 略。   参考put (文件上传) 。 两则异曲同工**
