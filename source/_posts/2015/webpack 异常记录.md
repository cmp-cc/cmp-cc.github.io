----
title: Webpack 异常记录
date: 2015-04-19 19:50:00
updated:
categories: 
- Project Build
- Webpack

tags:
- Webpack
----
### 导入 `bootstrap.css` 异常

#### 描述与错误信息
* app.js 引入`import 'bootstrap/dist/css/bootstrap.css'`
* webpack url-loader 配置如下：
```
module: {
    loaders: [
        {test: /\.css$/, loader: 'style-loader!css-loader'},
        {test: /\.(png|jpg)$/, loader: 'url-loader?limit=8192'},
        {
            test: /\.js$/,
            exclude: /node_modules/,
            loader: "babel-loader",
            query: {
                presets: ['es2015']
            }
        }
    ]
}
```
* 打包，异常信息如下：
```
ERROR in ./~/bootstrap/dist/fonts/glyphicons-halflings-regular.eot
Module parse failed: D:\Work-Repository\Coding-Repository\IDEAs\CorrelationSystem\node_modules\bootstrap\dist\fonts\glyphicons-halflings-regular.eot Unexpected character '�' (1:0)
....

ERROR in ./~/bootstrap/dist/fonts/glyphicons-halflings-regular.woff
Module parse failed: D:\Work-Repository\Coding-Repository\IDEAs\CorrelationSystem\node_modules\bootstrap\dist\fonts\glyphicons-halflings-regular.woff Unexpected character ' ' (1:4)
...

ERROR in ./~/bootstrap/dist/fonts/glyphicons-halflings-regular.woff2
Module parse failed: D:\Work-Repository\Coding-Repository\IDEAs\CorrelationSystem\node_modules\bootstrap\dist\fonts\glyphicons-halflings-regular.woff2 Unexpected character ' ' (1:4)
....

ERROR in ./~/bootstrap/dist/fonts/glyphicons-halflings-regular.svg
Module parse failed: D:\Work-Repository\Coding-Repository\IDEAs\CorrelationSystem\node_modules\bootstrap\dist\fonts\glyphicons-halflings-regular.svg Unexpected token (1:0)
```
#### 解决方案
* 安装 `file-loader`
```
npm install file-loader --save-dev
```
* `webpack.config.js` 配置
```
module: {
    loaders: [
        {test: /\.css$/, loader: 'style-loader!css-loader'},
        {test: /\.(png|jpg)$/, loader: 'url-loader?limit=8192'},
        {
            test: /\.(png|jpg|jpeg|gif|svg|woff|woff2|ttf|eot)(\?v=\d+\.\d+\.\d+)?$/,
            loader : 'file-loader'
        },
        {
            test: /\.js$/,
            exclude: /node_modules/,
            loader: "babel-loader",
            query: {
                presets: ['es2015']
            }
        }
    ]
}
```
