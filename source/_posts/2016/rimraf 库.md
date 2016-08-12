----
title: rimraf 库
date: 2016-03-02 22:46:00
updated:
categories: 
- Programming Language
- Nodejs
tags:
- Nodejs

----
## rimraf 介绍 与 安装

rimraf 是一个NodeJs 的库，用于不同平台下（操作系统）进行多级目录删除。 等同于 `rm -rf `

github 地址：https://github.com/isaacs/rimraf

**安装**
```
npm install rimraf
```

## API
> * rimraf(f, [opts], callback)

第一个参数将被解释为对文件的通配符匹配，如果你想禁用通配符，你可以设置`opts.disableGlob`为`false`(默认为`false`)。

略 ...

具体参考[git 地址](https://github.com/isaacs/rimraf)

- ----
> 自己也就是在使用`npm script` 的时候会用到，来帮助我递归的删除文件。