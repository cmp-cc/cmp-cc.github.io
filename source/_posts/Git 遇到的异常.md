----
title: Git 遇到的异常
date: 2014-03-11 22:53:00
updated: 2015-12-14 17:50:00
categories: 
- 版本控制
tags:
- Git
----

**更新于 ：2015-12-14 17:50:00**



**总结 在使用Git 进行版本控制遇到错误及其相关解决方案，并持续更新**

## 1.Everything is update

### 错误信息
**git push origin master 的时候出现Everything is update**

### 解决方案
**使用git commit -am "xxxx"**
```
git commit -am "modify of part"
git origin master
```
## 2.Note about fast-forwards (! [rejected])
### 错误信息
```
$ git push origin hexo
To git@github.com:cmp-cc/cmp-cc.github.io.git
 ! [rejected]        hexo -> hexo (fetch first)
error: failed to push some refs to 'git@github.com:cmp-cc/cmp-cc.github.io.git'
hint: Updates were rejected because the remote contains work that you do
hint: not have locally. This is usually caused by another repository pushing
hint: to the same ref. You may want to first integrate the remote changes
hint: (e.g., 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

### 解决方案
**一、使用强制push的方法 （不推荐）：**
这样会使远程修改丢失，一般是不可取的，尤其是多人协作开发的时候，单人协助无所谓。
```
git push -u origin master -f 
```
---
**二、老老实实的merge 分支。（推荐）**
```
git pull origin master
git push -u origin master
```
---

**三、使用`git pull --rebase` 将本地与远程进行同步（等价于第二种）**
**`git push --rebase` 的含义**
* 把本地 repo. 从上次 pull 之后的变更暂存起來
* 恢复到上次 pull 时的状态
* 合并远端的变更到本地
* 最后再合并刚刚暂存下來的本地变更

## 3.push之后不能访问文件(文件状态为灰色)
### 错误信息
**如下，处于不可打开状态，如果你把整个项目clone下来，你会发现文件为空**

{% asset_img 4D44727A1CED48A6AF27443A6F1A36D7.png 文件显示状态 %}

### 解决方案
你可能需要了解一下`git submodule`的使用,就知道问题所在了。(git项目中的子目录存在一个git仓库)
* 将子目录中的`.git`目录删掉
* 删除子模块子目录
* 再执行`git push` 操作
```
git rm --cached ./themes/next
git add --all
git commit -m "delete child module"
git push origin master
```
可参考：http://stackoverflow.com/questions/19584255/what-does-a-grey-icon-in-remote-github-mean
