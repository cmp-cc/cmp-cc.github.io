----
title: Ajax
date: 2013-02-16 13:43:00
categories: 
- Web
tags:
- Javascript
----


##  略略略 
随便记录一下。 日后再补充。

## XMLHttpRequest 对象
### XMLHttpRequest 对象属性

| 属性名称 | 说明 |
| --- | --- |
| onreadystatechange	| 指定当readState状态改变时使用的操作，一般用于指定具体的回调函数 |
| readyState			| 返回当前请求的状态，只读 |
| responseBody		| 将回应信息正文以unsigned byte数组的形式返回，只读 |
| responseStream		| 以Ado Stream对象的形式返回响应信息，只读 |
| responseText		| 接收以文本返回的数据，只读 |
| responseXML			| 接收以XML文档形式回应的数据，只读 |
| status				| 返回当前请求的http状态码，只读 |
| statusText			| 返回当前请求的响应行装填，只读 |

**statusText 的五种取值状体**

状体码 | 说明
--- | ---
0 | 请求没有发出（在调用open()函数之前）
1 | 请求已经建立但还没有发出（在调用send()函数之前）
2 | 请求已经发出正在处理之中(这里通常可以从响应得到内容头部)
3 | 请求已经处理，正在接受服务器的信息，响应中通常有部分数据可用，但是服务器还有完成响应	
4 | 请求已完成，可以访问服务器响应并使用它

### XMLHttpRequest 对象方法
方法名称 | 作用
--- | ---
abort()					| 取消当前所发出的请求
getAllRespnseHeaders()	| 取得所有的HTTP头信息
getResponseHeader()		| 取得一个指定的HTTP头信息
open()					| 创建一个HTTP请求，并指定请求模式，如GET请求或POST请求
send()					| 将创建的请求发送到服务器，并接受回应信息
setRequestHeader()		| 设置一个指定的请求的HTTP头信息

### Ajax 实例

```
<script type = "text/javascript">
var getAjax; // 欲初始化ajax函数
function invidate() {
    if (window.XMLHttpRequest) { // 判断浏览器类型， N 为IE
		getAjax = new XMLHttpRequest();
	} else {
		getAjax = new ActiveXObject("Misrosoft.XMLHTTP");
	}
}

function useGetAjax() {
	invidate(); // 初始化XMLHttpRequest对象
	getAjax.open("POST", "testAJax", true);
    // 以POST方式发开请求连接
	getAjax.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	getAjax.onreadystatechange = function() { // 回调函数
		if (getAjax.readyState == 4) {
		    if (getAjax.status == 200) {
		        var text = getAjax.responseText; // 接收响应信息
		        alert(text);
		        document.getElementById("ajax").innerHTML = text;

		    }
		}
    }
    getAjax.send("username=1"); // 发送请求体
}
</script>
```
