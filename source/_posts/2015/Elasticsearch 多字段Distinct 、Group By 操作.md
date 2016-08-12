----
title: Elasticsearch 多字段Distinct 、Group By 操作
date: 2015-07-17 22:33:00
updated:
categories: 
- Distributed Development
- Elasticsearch
tags:
- Elasticsearch
----

使用Elasticsearch 进行数据操作时，获取聚合信息是常规操作，那么如果使用ES进行多字段聚合操作。


ES聚合语法`aggregations` 中`terms` 可以完成单字段的`Distinct` 和 `Group by` 操作,如下
```
{
    "aggs" : {
        "groupBy" : {
            "terms" : { "field" : " client_host  " }
        }
    },
   "size":0
}
```
* Java 代码实现
```
SearchResponse sr =  client.prepareSearch(es_index)
                .setSize(0)
                .addAggregation(AggregationBuilders
                                    .terms("groupBy")
                                    .field("client_host")
                                    )
                .execute().actionGet();  
```
* 响应结果
```
{
  "took" : 1338,
  "timed_out" : false,
  "_shards" : {
    "total" : 16,
    "successful" : 16,
    "failed" : 0
  },
  "hits" : {
    "total" : 12918553,
    "max_score" : 0.0,
    "hits" : [ ]
  },
  "aggregations" : {
    "groupBy" : {
      "doc_count_error_upper_bound" : 1331,
      "sum_other_doc_count" : 12896564,
      "buckets" : [ {
        "key" : "101.40.86.140",
        "doc_count" : 6062
      }, {
        "key" : "188.11.182.230",
        "doc_count" : 4583
      }, {
        "key" : "78.20.241.66",
        "doc_count" : 1846
      }, {
        "key" : "108.26.11.12",
        "doc_count" : 1743
      }, {
        "key" : "68.20.241.67",
        "doc_count" : 1733
      }, {
        "key" : "11.159.63.124",
        "doc_count" : 1501
      }, {
        "key" : "11.159.63.13",
        "doc_count" : 1488
      }, {
        "key" : "11.159.63.110",
        "doc_count" : 1414
      }, {
        "key" : "11.159.63.3",
        "doc_count" : 1396
      }, {
        "key" : "11.159.63.100",
        "doc_count" : 1392
      } ]
    }
  }
}  
```
> key 为聚合名称，doc_count 为聚合数量

## 多字段 Group By

```
{
  "aggs": {
    "agg1": {
      "terms": {
        "field": "field1"
      },
      "aggs": {
        "agg2": {
          "terms": {
            "field": "field2"
          },
          "aggs": {
            "agg3": {
              "terms": {
                "field": "field3"
              }
            }
          }          
        }
      }
    }
  },"size":0
}
```
* Java 代码实现
```
        SearchResponse sr =  client.prepareSearch(es_index)
                                .setSize(0)
                                .addAggregation(AggregationBuilders
                                                    .terms("agg1")
                                                    .field("field1")
                                                    .subAggregation(AggregationBuilders
                                                            .terms("agg2")
                                                            .field("field3")
                                                            .subAggregation(AggregationBuilders
                                                                    .terms("aggs3")
                                                                    .field("field3")
                                                            )))
                                .execute().actionGet();  
```
>  同样响应结果属于层次聚合关系


## 多字段Distinct
这是对字段：client_ip 和 server_ip 进行`distinct` 操作
```
{
   "aggs":{
        "distinct":{
             "terms":{
                "script":"doc['client_host'].values[0] + '  '+ doc['SOURCEIP'].values[0]"
                }
           }
   },
   "size":0
}
```


* Java代码实现

```
SearchResponse sr =  client.prepareSearch(es_index)
                .setSize(0)
                .addAggregation(AggregationBuilders
                                    .terms("distinct")
                                    .script(new Script("doc['client_ip '].values[0]+' '+doc['server_ip'].values[0]"))
                                    )
                .execute().actionGet();  
```
* 响应结果如下
```
{
  "took" : 3262,
  "timed_out" : false,
  "_shards" : {
    "total" : 16,
    "successful" : 16,
    "failed" : 0
  },
  "hits" : {
    "total" : 182082,
    "max_score" : 0.0,
    "hits" : [ ]
  },
  "aggregations" : {
    "distinct" : {
      "doc_count_error_upper_bound" : 32,
      "sum_other_doc_count" : 181909,
      "buckets" : [ {
        "key" : "117.167.87.3 114.215.200.204",
        "doc_count" : 37
      }, {
        "key" : "10.159.95.158 115.28.6.58",
        "doc_count" : 19
      }, {
        "key" : "10.159.94.34 115.28.175.67",
        "doc_count" : 18
      }, {
        "key" : "188.191.209.103 52.59.247.188",
        "doc_count" : 17
      }, {
        "key" : "10.159.94.41 115.28.6.58",
        "doc_count" : 15
      }, {
        "key" : "10.159.63.32 114.55.34.111",
        "doc_count" : 14
      }, {
        "key" : "10.159.95.158 115.28.175.67",
        "doc_count" : 14
      }, {
        "key" : "10.159.63.100 114.215.200.204",
        "doc_count" : 13
      }, {
        "key" : "10.159.94.33 115.28.6.58",
        "doc_count" : 13
      }, {
        "key" : "10.159.94.76 115.28.6.58",
        "doc_count" : 13
      } ]
    }
  }
}  
```
