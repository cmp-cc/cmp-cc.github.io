----
title: Webpack入门实例
date: 2015-02-11 08:50:00
updated:
categories: 
- Project Build
- Bower
tags:
- Bower
----

## Bower 介绍
### 它是什么
**Bower是一个客户端技术的软件包管理器，它可用于搜索、安装和卸载如JavaScript、HTML、CSS之类的网络资源**

### 为什么使用
* **节约时间。**每次我需要安装jQuery的时候，我都需要去jQuery网站下载包或使用CDN版本。但是有了Bower，我只需要输入一个命令。它会安装在本地计算机上，通过info命令去查看任意库的信息。
*  **脱机工作。**它有自己的Library仓库，如同Maven（Java 项目构建工具）一样，它存在于用户主目录下.bower下。方便Library管理，避免重复下载。
*  **项目依赖清晰。**创建一个项目依赖文件(bower.json)，这个文件里你可以指定所有客户端的依赖关系，任何时候你需要弄清楚你正在使用哪些库，都可以查阅这个文件。
*  **让升级变得简单。**只需要运行一个命令，bower会自动更新所有有关新版本的依赖关系。

### 需要准备什么
**在使用Bower之前，你需要安装NodeJS、Git、NPM（安装NodeJS时，默认安装）**


## Bower 入门
### 安装Bower
```
npm install -g bower
```
###  使用`bower help`查阅所有命令
```
Usage:

    bower <command> [<args>] [<options>]
Commands:

    cache                   Manage bower cache
    help                    Display help information about Bower
    home                    Opens a package homepage into your favorite browser
    info                    Info of a particular package
    init                    Interactively create a bower.json file
    install                 Install a package locally
    link                    Symlink a package folder
    list                    List local packages - and possible updates
    login                   Authenticate with GitHub and store credentials
    lookup                  Look up a package URL by name
    prune                   Removes local extraneous packages
    register                Register a package
    search                  Search for a package by name
    update                  Update a local package
    uninstall               Remove a local package
    unregister              Remove a package from the registry
    version                 Bump a package version
Options:

    -f, --force             Makes various commands more forceful
    -j, --json              Output consumable JSON
    -l, --log-level         What level of logs to report
    -o, --offline           Do not hit the network
    -q, --quiet             Only output important information
    -s, --silent            Do not output anything, besides errors
    -V, --verbose           Makes output more verbose
    --allow-root            Allows running commands as root
    -v, --version           Output Bower version
    --no-color              Disable colors
See 'bower help <command>' for more information on a specific command.
```

### 包的安装
**使用 `bower install`命令. Bower将安装包到`bower_components/.`目录下**
```
bower install <package>
```
**Bower可以读取四种不同源**
```
bower install jquery   //registered package  

bower install desandro/masonry  //github别名自动解析git库

bower install git://github.com/user/package.git  //Git endpoint

bower install http://example.com/script.js //URL
```
**实例： 安装包 jquery**
```
bower install jquery

它将自动下载，并生成如下结构。

└─bower_components
    └─jquery
        ├─dist
        └─src
         .....


通过如下进行生产使用

<script type="text/javascript" src="bower_components/jquery/jquery.min.js"></script>
```
**想要指定具体的版本通过`#`. eg: `bower install bootstrap#3.3.5`**
### 基本命令
#### 所有包的列表
`bower list`命令罗列包的列表。它会检查`bower_components`目录下的包，然后会显出来，并告诉你当前最新版本。
```
bower F:\test\bower
└─┬ bootstrap#3.3.5 extraneous (latest is 4.0.0-alpha)
  └── jquery#2.1.4 (3.0.0-alpha1+compat available)
```
### 包的搜索
**1、使用 `http://bower.io/search/` 查找包名称。**
**2、`bower search`命令进行包的搜索**
**输入`bower search bootstrap`，结果如下**
```
Search results:

    bootstrap git://github.com/twbs/bootstrap.git
    angular-bootstrap git://github.com/angular-ui/bootstrap-bower.git
    bootstrap-sass-official git://github.com/twbs/bootstrap-sass.git
    sass-bootstrap git://github.com/jlong/sass-bootstrap.git
    bootstrap-datepicker git://github.com/eternicode/bootstrap-datepicker.git
    bootstrap-select git://github.com/silviomoreto/bootstrap-select.git
    angular-ui-bootstrap-bower git://github.com/angular-ui/bootstrap-bower
    angular-ui-bootstrap git://github.com/angular-ui/bootstrap.git
    bootstrap-daterangepicker git://github.com/dangrossman/bootstrap-daterangepicker.git
    bootstrap-timepicker git://github.com/jdewit/bootstrap-timepicker
    bootstrap-switch git://github.com/nostalgiaz/bootstrap-switch.git
    bootstrap-css git://github.com/jozefizso/bower-bootstrap-css.git
    select2-bootstrap-css git://github.com/t0m/select2-bootstrap-css.git
    eonasdan-bootstrap-datetimepicker git://github.com/Eonasdan/bootstrap-datetimepicker.git
    seiyria-bootstrap-slider git://github.com/seiyria/bootstrap-slider.git
    angular-bootstrap-colorpicker git://github.com/buberdds/angular-bootstrap-colorpicker.git
    bootstrap-multiselect git://github.com/davidstutz/bootstrap-multiselect.git
    bootstrap.css git://github.com/bowerjs/bootstrap.git
    bootstrap-datetimepicker git://github.com/tarruda/bootstrap-datetimepicker.git
    angular-bootstrap-datetimepicker git://github.com/dalelotts/angular-bootstrap-datetimepicker
    bootstrap-modal git://github.com/jschr/bootstrap-modal.git
    bootstrap-tour git://github.com/sorich87/bootstrap-tour.git
    bootstrap-tagsinput git://github.com/TimSchlechter/bootstrap-tagsinput.git
    bootstrap-additions git://github.com/mgcrea/bootstrap-additions.git
    bootstrap-file-input git://github.com/grevory/bootstrap-file-input.git
    angular-bootstrap-switch git://github.com/frapontillo/angular-bootstrap-switch.git
    bootstrap-social git://github.com/lipis/bootstrap-social.git
    twbs-bootstrap-sass git://github.com/twbs/bootstrap-sass
    ember-addons.bs_for_ember git://github.com/ember-addons/bootstrap-for-ember.git
    jasny-bootstrap git://github.com/jasny/bootstrap.git
```

### 包的信息
可以使用`info` 命令来查看特定包的所有信息，eg: `bower info bootstrap` 结果如下:
```
bower                            retry Request to https://bower.herokuapp.com/packages/bootstrap failed with ECONNRESET, retrying in 1.3s
bower bootstrap#*           not-cached git://github.com/twbs/bootstrap.git#*
bower bootstrap#*              resolve git://github.com/twbs/bootstrap.git#*
bower bootstrap#*             download https://github.com/twbs/bootstrap/archive/v3.3.5.tar.gz
bower bootstrap#*              extract archive.tar.gz
bower bootstrap#*             resolved git://github.com/twbs/bootstrap.git#3.3.5

{
  name: 'bootstrap',
  description: 'The most popular front-end framework for developing responsive, mobile first projects on the web.',
  keywords: [
    'css',
    'js',
    'less',
    'mobile-first',
    'responsive',
    'front-end',
    'framework',
    'web'
  ],
  homepage: 'http://getbootstrap.com',
  license: 'MIT',
  moduleType: 'globals',
  main: [
    'less/bootstrap.less',
    'dist/js/bootstrap.js'
  ],
  ignore: [
    '/.*',
    '_config.yml',
    'CNAME',
    'composer.json',
    'CONTRIBUTING.md',
    'docs',
    'js/tests',
    'test-infra'
  ],
  dependencies: {
    jquery: '>= 1.9.1'
  },
  version: '3.3.5'
}
....
```
>提示：通过`bower info <package>#<version>` 查看具体版本信息。eg:`bower info bootstrap#3.3.5`

### 包的卸载
**使用`uninstall` 命令进行包的卸载，eg:bower uninstall jquery**
**如果希望将`bower.json`中的jquery依赖也删除掉，可以使用`bower uninstall jquery --save`**

## 创建包管理文件
### bower.json
** `bower.json`是Bower默认的清单文件,它与NodeJS中的`package.json`文件和Ruby的`Gemfile`文件非常相似**
**通过`bower init` 初始化`bower.json`文件**
```
bower init
```
项目目录下载创建`.bowerrc` 将指定生成管理目录（bower_compinents）的位置和名称。如下：
```
{
    "directory": "app/components"
}
```

### bower.json规范
**bower.json[配置详情](https://github.com/bower/spec/blob/master/json.md)**

### 保持依赖
使用`bower install <package> --save` 安装<package>并追加至bower.json文件中Dependencies属性下
```
bower install <package> --save             //或者 bower install <package> -S
```
使用`bower install <package> --save-dev` 安装<package>并追加至bower.json文件devDependencies属性下
```
bower install <package> --save-dev   //或者 bower install <package> -D

```

     
>`-P` 依赖将不会被安装        
>提示： 下次部署项目的时候，只需要执行`bower install` ,它便会下载所有项目依赖包。

### 注册略
参考：http://bower.io/docs/creating-packages/#bowerjson



>bower.json文件中。包的依赖如：`"backone" : "~1.1.2"` 中`~` 表示X版本，指小版本，不限制第三位参数,小版本升级可以是~1.1.4。


## API
### 使用 `cache`
**每次安装完包，就会增加到缓存中**
```
bower cache list    //查看所有缓存包
bower install <package> --offline //离线安装<package> 
bower cache clean //清除所有缓存
```
### 其他略

## 版本控制
### 修改版本
通过`bower version`命令来修改版本
```
bower version 0.0.1   //修改版本 或者 增加版本  
bower version patch   //小修改功能时使用。  v 0.0.2
bower version minor  //小版本时使用。 v 0.1.2
bower version major  //大版本时使用。 v 1.1.2
```
**其它略，有需求，请参考官方文档**

## 基本操作
### 常用命令
```
$ bower install jquery --save 添加依赖并更新bower.json文件
$ bower cache clean 安装失败清除缓存
$ bower install storejs 安装storejs
$ bower uninstall storejs 卸载storejs
$ bower uninstall storejs --save 卸载依赖并更新bower.json文件

//使用离线缓存，避免重复下载
$ bower cache list    //查看所有缓存列表
$ bower install bootstrap --offline --save     //离线下载，并追加依赖到bower.json
```

### 基本命令
```
npm update -g bower //更新bower

//help命令详情
cache:bower缓存管理
help:显示Bower命令的帮助信息
home:通过浏览器打开一个包的github发布页
info:查看包的信息
init:创建bower.json文件
install:安装包到项目
link:在本地bower库建立一个项目链接
list:列出项目已安装的包
lookup:根据包名查询包的URL
prune:删除项目无关的包  //检查bower.json 中的依赖列表，删除本地没有依赖的包
register:注册一个包
search:搜索包
update:更新项目的包    //先修改bower.json    eg: jquery:'>=1.9'
uninstall:删除项目的包

```
### 发布github
1. `bower init` name: xxxx
2. 在github创建资源库xxxx
3. 将本地项目提交至github
```
git init
git add .
git commit -m "this is ??"
git remote add origin https://github.com/cmp-cc/xxxx
git push -u origin master
```
4. 注册到bower官方类库
bower register nodejs-bower git@github.com:cmp-cc/xxxx.git
5. 查询自己的包
```
bower search bower-test
```