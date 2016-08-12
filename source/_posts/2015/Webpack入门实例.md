----
title: Webpack入门实例
date: 2015-04-17 19:50:00
updated:
categories: 
- Project Build
- Webpack

tags:
- Webpack
----

> 参照官网


## 欢迎
这个简短的教程将指导您完成一个简单的实例

你将学习：
* 如何安装 `webpack`
* 如何使用 `webpack`
* 如何使用 `webpack loaders 特性`
* 如何使用 `webpack development server`

## 安装 Webpack
首先你需要安装[node.js](https://nodejs.org/)
```
npm install webpack -g
```
> 这使得`webpack`命令是可用的

## 设置编译
首先创建一个空的目录
创建如下文件
* 添加`entry.js`
```
document.write("It works.");
```
* 添加`index.html`
```
<html>
    <head>
        <meta charset="utf-8">
    </head>
    <body>
        <script type="text/javascript" src="bundle.js" charset="utf-8"></script>
    </body>
</html>
```
* 然后运行如下
```
webpack ./entry.js bundle.js
```
它将编译你的文件,并创建`bundle`文件
如果成功，显示如下：
```
Hash: ca188ee5789bb780fcec
Version: webpack 1.12.9
Time: 79ms
    Asset     Size  Chunks             Chunk Names
bundle.js  1.42 kB       0  [emitted]  main
   [0] ./entry.js 28 bytes {0} [built]
```
* 浏览器打开`index.html`，它将显示`It works`
```
// 浏览器
It works.
```
## 模块化引入
下一步，我们将移动一些代码到一个额外的文件。
* 添加`content.js`
```
module.exports = "It works from content.js.";
```
* 修改 `entry.js` 为如下
```
document.write(require("./content.js"));
```
* 重新编译
```
webpack ./entry.js bundle.js
```
* 浏览器打开，将显示文本：`It works from content.js.`
```
// 浏览器
It works from content.js.
```
> webpack 将分析你的entry文件依赖于哪些其他文件，这些也文件（称为模块）包含在bundle.js.webpack会给每一个模块一个唯一ID标示，防止bundle.js文件访问所有模块。

## 第一个Loader
我们想要在我们的应用中添加Css文件.
`webpack`本身 只能处理JavaScript 文件，所以我们需要`css-loader`去处理CSS文件，在`CSS`文件中应用样式,我们也需要`style-loader`.
运行`npm install css-loader style-loader` 安装`loaders` (只是本地安装，无需`-g`) ，`loaders` 存在于 `node_modules`目录中。
**使用他们**
* 添加`style.css`
```
body {
    background: yellow;
}
```
* 修改`entry.js`为如下：
```
require("!style!css!./style.css");
document.write(require("./content.js"));
```
* 重新编译，并浏览器打开，会发现增加了黄色背景
```
// 浏览器打开，背景：黄色

It works from content.js.
```
> By prefixing loaders to a module request, the module went through a loader pipeline. These loaders transform the file content in specific ways. After these transformations are applied, the result is a JavaScript module.

## 绑定Loaders
我们不想写如此长的`requires` : `require("!style!css!./style.css");`
我们在Loaders中绑定文件扩展名，只需要写:`require("./style.css")`
* 修改`entry.js` 文件
```
  require("./style.css");
  document.write(require("./content.js"));
```
* 然后编译如下
```
webpack ./entry.js bundle.js --module-bind 'css=style!css'
```
> 有些环境可能需要双引号: `–module-bind "css=style!css"`

*  我们将看到同样结果
```
// 浏览器打开，背景：黄色

It works from content.js.
```
## 配置文件
我们想要移除配置项到一个配置文件中，如下：
* 添加 webpack.config.js
```
module.exports = {
    entry: "./entry.js",
    output: {
        path: ".",
        filename: "bundle.js"
    },
    module: {
        loaders: [
            { test: /\.css$/, loader: "style!css" }
        ]
    }
};
```
* 现在可以运行它
```
webpack
```
* 编译如下：
```
Version: webpack 1.12.9
Time: 379ms
    Asset     Size  Chunks             Chunk Names
bundle.js  10.7 kB       0  [emitted]  main
chunk    {0} bundle.js (main) 8.86 kB [rendered]
    [0] ./tutorials/getting-started/config-file/entry.js 65 bytes {0} [built]
    [1] ./tutorials/getting-started/config-file/style.css 943 bytes {0} [built]
    [2] ../~/css-loader!./tutorials/getting-started/config-file/style.css 201 bytes {0} [built]
    [3] ../~/css-loader/lib/css-base.js 1.51 kB {0} [built]
    [4] ../~/style-loader/addStyles.js 6.09 kB {0} [built]
    [5] ./tutorials/getting-started/config-file/content.js 45 bytes {0} [built]
```
> `webpack 命令行` 尝试在当前目录加载`webpack.config.js`文件

## 格式化输出
**美化输出: 项目的编译可能需要更长的时间，所以，我们要显示某种进度条和颜色**
我们可以通过如下实现
```
webpack --progress --colors
```
## Watch 模式
观察模式： 我们不希望每次更改后手动重新编译... 开启监听模式，它会自定检测变化文件，并加载，减少编译时间
```
webpack --progress --colors --watch
```
webpack 可以缓存没有变化的模块。
> 当使用`watch mode`,`webpack`安装文件观察到的所有文件，这只作用在编译过程。如果检测到任何变化，它会再次编译。当缓存是开启的，`webpack` 在内存中保存所有模块，如果它没有被改变，将重复使用。

## 开发服务器
`mock server` 是重要的，`webpack`中的`mock 服务器环境` 基于`nodejs`，而不依赖于其他语言。
```
npm install webpack-dev-server -g
```
```
webpack-dev-server --progress --colors
```
这里在`localhost:8080`绑定一个小的`Express 服务器`，供静态资源完成自动编译，它会自定编译（SockJS），并自动更新浏览器页面，在浏览器中打开`http://localhost:8080/webpack-dev-server/bundle`
> The dev server uses webpack’s watch mode. It also prevents webpack from emitting the resulting files to disk. Instead it keeps and serves the resulting files from memory.



