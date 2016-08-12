----
title: iFrame
date: 2014-12-10 11:51:00
updated:
categories: 
- Web
- HTML
tags:
- HTML
----

iFrame标记
===

---

iFrame标记（浮动帧标记）是框架的一种形式。 

### iframe 作用：
* 组件化开发的一种方式
* 解决重复代码问题

### iFrame 及其属性：
iFrame 使用格式:
```
<iframe src="URL" width="x" height="x" scrolling="[OPTION]" frameborder="x"></iframe>
```
iframe 设置文本或图形的浮动图文框或容器
* scrolling=no (YES,NO,AUTO) 是否有滚动条
* src 指定iFrame调用的类型（HTML,GIF,JPEG,Text,JSP等等）
* width、height 。iframe整体宽高。
* frameborder：宽度
示例：
```
<iframe frameborder=0 width=500 height=500 marginheight=0 marginwidth=0 scrolling=no src="content/codeSnippet.html"> </iframe>
```

### 特点
* 可以重复引用
* 引入内容，父窗体显示页面为HTML包裹。
```
//被引入片段 codeSnippet.html
<h1>Hello World</h1>
```
```
//引入代码片段还是其它，默认HTML包裹。
<iframe border=2 frameborder=0 width=500 height=500 marginheight=0 marginwidth=0 scrolling=no src="content/SCNKQ%609XS4Z4$%5B2XLLH(1%7BW.png"> </iframe>
```


### 父窗体与子窗体通信
父窗体： 包含iframe的窗体
子窗体： iframe本身。
通信：使用程序访问控制父窗体与子窗体交互，父窗体中访问子窗体或相反。

**子窗体（嵌入代码片）**
```
<!DOCTYPE html>
<html>
<head lang="en">
    <meta charset="UTF-8">
    <title></title>
</head>
<script>
    function helloChild(){
       console.log("Hello child Object");
    }
</script>
<body>
// 如果如果下一行,嵌入父窗体，默认增加html、、head、body标签
<h1 id="h1">Hello World</h1>

</body>
<script>
    // 访问控制父类对象
</script>
</html>
```
**父窗体**
```
<script>
	function helloParent(){
	    console.log("Hello parent Object");
	}
</script>

<iframe name="snippet" id="snippet"  frameborder=0 width=500 height=500 marginheight=0 marginwidth=0 scrolling=no src="content/codeSnippet.html">
</iframe>

```

#### 父窗体访问控制子窗体对象

* iframe 设置id或class 属性
父窗体中，iframe窗体为document对象的一个子对象，可以直接在脚本中访问子窗体中对象，这样只能访问控制当前iframe对象的属性信息。
```
var snippet = document.getElementById('snippet')
console.log(snippet.src)
console.log(snippet.frameBorder)
```
* iframe 设置name属性
设置name属性，将iframe视为window对象，可以访问控制iframe内部JS、HTML。
```
// 调用iframe内部JS代码和iframe DOM操作
window.onload = function(){
    snippet.helloChild();//访问内部方法。 完整写法:  document.snippet.helloChild()
    snippet.document.getElementById('h1').innerHTML = "Me too!!!"
// frames['snippet'] 等价于snippet 。frames为window元素.
// frames['snippet'].document.getElementById('h1s').innerHTML = "Me too!!!"   
}
```
>提示，注意全局命名冲突。

#### 子窗体访问控制父窗体对象
在代码片中定义JS脚本，通过parent对象访问上一级window对象。
```
    parent.helloParent();  //访问父窗体对象。  完整写法:   window.parent.helloParent();
    parent.document.getElementById('p').innerHTML = "你有良民证吗?"
```

### iFrame 组件化
将不变内容组件化，相对独立，避免重复编码，使得修改页面更加方法。

###用途
* 载入外来资源。
  结合a标签或者Script脚本,点击或输入链接，访问显示外来页面或其它资源
* 复用。
相同代码连续使用。
* 窃取显示。
外来链接。通过设置 marginwidth、marginheight、vspace、scrolling=no 、width、height 。将别人部分内容显示在自己页面。
全屏显示页面中某一部分。


### 优缺点
iFrame 标签,现在越来越不受人待见，由于它的缺点，很多原使用MVVM或JS模板引擎、Ajax取代。
缺点：
* 不利于seo
不利于搜索引擎的爬虫访问,例如：Google 不读取iFrame标签信息。
* 增加页面交互的复杂度
* 共享链接池
iframe和主页面共享链接池，浏览器对相同域的链接有限制，所以会影响页面并行加载。
* 移动端展示问题
* 重复加载问题（可避免）。
iframe等同于一个新的页面，JS/CSS 重复加载。

优点：

iframe 跨域通信
iframe WebSocket 长连接






