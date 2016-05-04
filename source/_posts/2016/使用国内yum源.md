----
title: 使用国内yum源
date: 2016-05-04 16:07:00
updated:
categories: 
- Operating System
- Linux

tags:
- Linux
----

**国内yum源列表 Centos6**

来源 | 地址
--- | ---
中科大 | http://centos.ustc.edu.cn/CentOS-Base.repo
搜狐 | http://mirrors.sohu.com/help/CentOS-Base-sohu.repo
网易 | http://mirrors.163.com/.help/CentOS6-Base-163.repo
阿里云| http://mirrors.aliyun.com/repo/Centos-6.repo


## 使用国内yum
系统配置yum的目录为`/etc/yum.repos.d`

* 备份系统yum配置文件
```
cd /etc/yum.repos.d
mv CentOS-Base.repo CentOS-Base.repo.bk
```
* 下载相关yum源文件（这里使用阿里云）
```
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
```
* 更新yum配置
```
yum clean all
```


## 使用yum-fastestmirror

每次用yum安装，yum-fastestmirror就会自动检查速度最快的镜像。

```
yum install yum-fastestmirror
yum clean all
```
> 通过`yum --disableplugin=fastestmirror update` 禁用此插件

## 被数落了~
**公司原来有开放的yum源，我还傻乎乎的使用别人家的。**
**Antiy: http://mirrors.avlyun.org/  提供各种系统的yum镜像，欢迎使用。**

* 修改为自家的东西
```
curl http://mirrors.avlyun.org/repo/centos6.repo > /etc/yum.repos.d/CentOS-Base.repo
yum makecache
```

> 我并没有使用yum-fastestmirror，自家的东东快的多。
