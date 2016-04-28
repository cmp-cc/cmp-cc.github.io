----
title: Python + OpenCV 环境配置
date: 2016-04-26 19:12:00
categories: 
- Programming Language
- Python
tags:
- Python
- 图像处理
----

OpenCV的全称是：Open Source Computer Vision Library。OpenCV是一个基于（开源）发行的跨平台计算机视觉库，可以运行在Linux、Windows和Mac OS操作系统上。它轻量级而且高效——由一系列 C 函数和少量 C++ 类构成，同时提供了Python、Ruby、MATLAB等语言的接口，实现了图像处理和计算机视觉方面的很多通用算法。

CV2是OpenCV官方的一个扩展库，属于一个Python模块，处理图像函数主要还是和CV2打交道。

安装详情参考:
http://opencv-python-tutroals.readthedocs.org/en/latest/py_tutorials/py_setup/py_setup_in_windows/py_setup_in_windows.html

## 安装步骤

### 安装Python 2.7
当前最新版OpenCV 支持Python2.7 （64bit or 32 bit）
**这里确定你已经安装了**
### 安装OpenCV

下载地址：https://sourceforge.net/projects/opencvlibrary/files/
* 选择合适的系统版本，这里选择Window，版本为opencv-3.1.0.exe。
* 安装opencv-3.1.0.exe ，选择解压目录`D:\Program-Software\Programming-Language\Python\Image\opencv`
* 配置环境变量，Path添加类似如下
```
D:\Program-Software\Programming-Language\Python\Image\opencv\build\x64\vc14\bin
```
* 将opencv\build\python\2.7\x64添加到Python27\Lib\site-packages目录（选择不同位数的版本）

### 安装Numpy
**opencv 依赖**

Pip安装
```
pip install -U numpy
```

下载安装Numpy与Window
https://sourceforge.net/projects/numpy/files/NumPy/1.8.1/numpy-1.8.1-win32-superpack-python2.7.exe/download
```
pip install numpy
```


## 安装SciPy
**opencv 依赖**
下载SciPy
https://sourceforge.net/projects/scipy/files/scipy/0.16.1/scipy-0.16.1-win32-superpack-python2.7.exe/download


## 测试
```
>>> import cv2
>>> image = cv2.imread("F:\image.png")
>>> cv2.imshow("Image",image)
>>> cv2.waitKey(0)
3
```
**它将显示图片**

