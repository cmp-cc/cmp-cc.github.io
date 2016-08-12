----
title: Yum 不可用，解决方案
date: 2015-11-14 16:53:00
updated:
categories: 
- Operating System
- Linux
tags:
- Linux
----


可能是谁，误删了服务器部分资源导致。
- ---
使用yum，发现如下异常错误。

```
[root@salt ~]# yum
There was a problem importing one of the Python modules
required to run yum. The error leading to this problem was:

   libsasl2.so.2: cannot open shared object file: No such file or directory

Please install a package which provides this module, or
verify that the module is installed correctly.

It's possible that the above module doesn't match the
current version of Python, which is:
2.6.6 (r266:84292, Jul 23 2015, 15:22:56) 
[GCC 4.4.7 20120313 (Red Hat 4.4.7-11)]

If you cannot solve this problem yourself, please go to 
the yum faq at:
  http://yum.baseurl.org/wiki/Faq
```

傻逼的我，下了一些`rpm`,也没有解决实际问题。
```
rpm -ivh cyrus-sasl-lib-2.1.23-15.el6_6.2.i686.rpm glibc-2.12-1.192.el6.i686.rpm nss-softokn-freebl-3.14.3-23.el6_7.i686.rpm db4-4.7.25-20.el6_7.i686.rpm glibc-common-2.12-1.192.el6.i686.rpm libcap-2.16-5.5.el6.i686.rpm tzdata-2016c-1.el6.noarch.rpm libattr-2.4.44-7.el6.i686.rpm 
```
仔细分析： yum 是python 写的。 执行yum失败，意味着缺失`libsasl2.so.2`库，只需要找一个`libsasl2.so.2`库，即可解决问题。 找了一个包含`libsasl2.so.2`的机器
```
scp /usr/lib64/libsasl2.so.2 root@192.168.12.153:/usr/lib64/
```

解决了。

