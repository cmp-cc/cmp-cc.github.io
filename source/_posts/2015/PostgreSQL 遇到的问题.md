----
title: PostgreSQL 遇到的问题
date: 2015-03-11 16:53:00
updated:
categories: 
- Data Base Management System
- Postgresql

tags:
- Postgresql
----
## 格式转换
### 问题描述
**需要查询具体的某一天的数据。 由于存储方式不一样。要对数据库中的last_record_time字段（时间格式）进行转化。**

{%asset_img 9744abfd-e724-4655-ac6b-eada2768ab42.png 数据显示%}

* 使用函数：substring(string from pattern for escape)函数。
**失败,类型不匹配**
* 使用 TO_CHAR 函数 可以进行格式类型转化。
**postgresql 8.1以后有个函数可以直接接受UNIX时间戳  TO_TIMESTAMP函数 可以处理时间戳。**
```
select sample_hash,sample_crc32 from t_black as s where  TO_CHAR(s.last_record_time,'YYYY-MM-DD') = '2015-03-10'
```
* 一个统计实例
**１０年到现在的白样本，分月分统计出每个月的白灰样本数量**
```
select TO_CHAR(s.last_record_time,'YYYY-MM'),count(*) from t_black as s  group by TO_CHAR(s.last_record_time,'YYYY-MM') order by TO_CHAR(s.last_record_time,'YYYY-MM')
```