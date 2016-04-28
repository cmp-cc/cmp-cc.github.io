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

## pull没有更新（ See git-pull(1) for details ）

### 错误信息
**这个算不上错误，问题是这样的：你有两个分支A 和 B。当前分支为B，你执行git pull 操作，他却pull了A而不是B**
```
$ git pull
remote: Counting objects: 174, done.
remote: Compressing objects: 100% (95/95), done.
remote: Total 174 (delta 61), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (174/174), 251.93 KiB | 206.00 KiB/s, done.
Resolving deltas: 100% (61/61), done.
   69cc25b..1b24763  master     -> origin/master
There is no tracking information for the current branch.
Please specify which branch you want to merge with.
See git-pull(1) for details

    git pull <remote> <branch>

If you wish to set tracking information for this branch you can do so with:

    git branch --set-upstream-to=origin/<branch> stream
```
### 解决方案
**进行本地分支和远程分支关联**
`git branch --set-upstream-to=origin/<branch> master`
```
git branch --set-upstream-to=origin/stream stream
```

参考：http://www.tbdazhe.com/archives/238


## Unlink of file 'xxx' failed. Should I try again?

### 错误信息
```
error: refusing to lose untracked file at 'stream/next/bower.json'
error: refusing to lose untracked file at 'stream/next/_config.yml'
error: refusing to lose untracked file at 'stream/next/README.md'
error: refusing to lose untracked file at 'stream/next/.jshintrc'
error: refusing to lose untracked file at 'stream/next/.javascript_ignore'
error: refusing to lose untracked file at 'stream/next/.hound.yml'
error: refusing to lose untracked file at 'stream/next/.gitignore'
error: refusing to lose untracked file at 'stream/next/.editorconfig'
error: refusing to lose untracked file at 'stream/next/.bowerrc'
Unlink of file 'stream/next' failed. Should I try again? (y/n)
```

### 解决方案
出现这种问题，通常意味这有一个进程仍在使用特定的文件，急需要关闭其它程序，然后在尝试执行`git pull`

参考：http://stackoverflow.com/questions/10181057/unlink-of-file-failed