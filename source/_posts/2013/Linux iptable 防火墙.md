----
title: Linux iptable 防火墙
date: 2013-11-25 23:23:00
categories: 
- Operating System
- Linux
tags:
- Linux
----

**Linux 环境下，默认使用的防火墙都是用iptable，同样也是服务器名称**

## iptable 服务
**iptable 基本服务命令**
```
service  iptables  start           开启防火墙
service  iptables  stop           关闭防火墙
service  iptables  restart        重启防火墙
service  iptables save            保持iptable 配置
service  iptables  status        查看防火墙状态
```

## iptable 基本语法

### 防火墙处理数据4中方式
* ACCEPT
允许数据包通过
* DROP
直接丢弃数据包，不给予响应
* REJECT
拒绝数据包通过，给予响应
* LOG
`/var/log/messages`文件记录日志信息


### iptable 参数

参数缩写 | 参数全称 | 参数解释
--- |---|---
-A  |  --append  | 在指定链的末尾添加一条新的规则
-D  |  --delete  | 删除指定链中的某一条规则，可以按规则序号和内容删除
-I  |  --insert  | 在指定链中插入一条新的规则，默认在第一行添加
-R  |  --replace |   修改、替换指定链中的某一条规则，可以按规则序号和内容替换
-L  |  --list    |   列出指定链中所有的规则进行查看
-E  |  --rename-chain |  重命名用户定义的链，不改变链本身
-F  |  --flush  | 清空
-N  |  --new-chain | 新建一条用户自己定义的规则链
-X  |  --delete-chain | 删除指定表中用户自定义的规则链
-P  |  --policy|  设置指定链的默认策略
-Z  |  --zero |  将所有表的所有链的字节和数据包计数器清零
-n  |  --numeric | 使用数字形式显示输出结果
-v  |  --verbose | 查看规则表详细信息的信息
-V  |  --version | 查看版本
-h  |  --help | 获取帮助


## 常用命令
```
iptables -L -n    // 查看防火墙配置
iptables -nL --line-number  // 查看iptables规则及编号
```

### 开放一个端口
**开启8000端口**
```
iptables -I INPUT -p tcp --dport 8000 -j ACCEPT
```
### 删除一个规则 
删除一个开放的端口规则
```
iptables -L -n --line-number     // 查看规则编号

iptables -D INPUT 2  // 删除指定规则编号，如 2
```


### 只开放某个端口
**只开放80端口**
```
iptables -A INPUT -p tcp –dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp –sport 80 -j ACCEPT
```
### 禁止某个IP地址
**禁止192.168.12.13访问**
```
iptables -A INPUT -p tcp -s 192.168.12.13 -j DROP
```

### 关闭所有的 INPUT FORWARD OUTPUT

关闭所有的INPUT FORWARD、 OUTPUT的所有端口
```
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
```


## 手工配置iptable
### iptable 配置文件
iptable配置文件默认地址为：`/etc/sysconfig/iptables`
```
vi /etc/sysconfig/iptables
```
执行如上命令显示如下iptables配置信息：
```
# Firewall configuration written by system-config-firewall
# Manual customization of this file is not recommended.
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 6379 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 7474 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
```

### 开放特定端口
如下开放1517端口，将其复制到iptable 配置文件中。
```
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 1517 -j ACCEPT
```
然后执行如下
```
serivce iptables save       保持防火墙设置
service iptables restart     重启防火墙
```



 