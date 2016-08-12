----
title: Neo4j Cypher 中文参考手册
date: 2015-11-05 12:53:00
updated:
categories: 
- Data Base Management System
- Neo4j
tags:
- Neo4j
----

## 写入语句
### 创建 （Create）
#### 创建点




**创建一个或多个节点（Node），每个节点拥有多个属性和多个标签（Label），并返回他们的信息**
```
create (n:Person:Rich{name:'Ms.Kile',country:'UK'}),(m:Person:Destitute {name:'Kelao',country:'CN'}) return n,m
```
#### 创建关系
**查找两个点，创建他们的关联关系,并增加一个到多个属性值。**
```
Match (n:Person),(m:Person) where n.name = 'Ms.Kile' and m.name = 'Kelao' create (n) -[r:Know{name: n.name + '->' + m.name}]->(m) return r
```
#### 创建Path

**创建一个完整的Path**
```
create p = (n{name:'Andres'}) - [:WORKS_AT]->(neo)<-[:WORKS_AT]-(m{name:'Michael'}) return p
```


#### 带参数的创建

可以创建节点的时候附加参数信息(Parameters)，参数信息中可以包含属性信息（properties）。
但是在当前Neo4j 2.x 浏览器中还不支持Cypher的参数化，不过，你可以使用`:POST`语法来实现这一点。

**Refer to the documentation for more information on Cypher queries via REST API.**

http://docs.neo4j.org/chunked/milestone/rest-api-cypher.html

我们尝试在浏览器中完成如下操作。（但这并不是推荐的做法）

```
:POST /db/data/transaction/commit {
    "statements": [
        {
            "statement": "MATCH (u:User {name:{username}}) RETURN u.name as username",
            "parameters": {
                "username": "my name"
            }
        }
    ]
}
```
创建带有标签的节点，属性使用参数化（Parameters）。
```
:POST /db/data/transaction/commit 
{
  "statements": [
    {
      "statement": "CREATE (n:Person { props }) RETURN n",
      "parameters": {
        "props": {
          "name": "Andres",
          "position": "Developer"
        }
      }
    }
  ]
}
```
创建多个节点，属性信息使用参数化。
```
旧的API方式
:POST /db/data/transaction/commit 
{
  "statements": [
    {
      "statement": "CREATE (n:Person { props }) RETURN n",
      "parameters": {
        "props": [
          {
            "name": "Andres",
            "position": "Developer"
          },
          {
            "name": "Michael",
            "position": "Developer"
          }
        ]
      }
    }
  ]
}

新的PAI方式
:POST /db/data/transaction/commit 
{
  "statements": [
    {
      "statement": "UNWIND { props } AS map CREATE (n:Person ) SET n = map return n",
      "parameters": {
        "props": [
          {
            "name": "Andres",
            "position": "Developer"
          },
          {
            "name": "Michael",
            "position": "Developer"
          }
        ]
      }
    }
  ]
}
```

由于使用POST请求，并不会显示可视化。你尝试查询创建的节点。
```
match (n:Person) where n.position = "Developer" return n
```
----------------
 
  
 
实际情况的使用：
Cypher支持参数化，提交为JSON，可以使用REST API如下：
http://docs.neo4j.org/chunked/milestone/rest-api-cypher.html
或者使用嵌入式（embedded）API，如下
http://docs.neo4j.org/chunked/milestone/tutorials-cypher-parameters-java.html

** 实例如下：**
来源： <http://stackoverflow.com/questions/22276795/how-do-you-use-parameters-with-neo4j>
Example request
```
POST http://localhost:7474/db/data/cypher
Accept: application/json; charset=UTF-8
Content-Type: application/json 

{
  "query" : "MATCH (x {name: {startName}})-[r]-(friend) WHERE friend.name = {name} RETURN TYPE(r)",
  "params" : {
    "startName" : "I",
    "name" : "you"
  }
} 
```
Example response
```
200: OK
Content-Type: application/json; charset=UTF-8

{
  "columns" : [ "TYPE(r)" ],
  "data" : [ [ "know" ] ]
}
```

### 移除 （Remove）
**Remove关键字用于移除图中元素中的属性和标签(Labels)。**
![cypher-remove](http://neo4j.com/docs/stable/images/cypher-remove-graph.svg)

执行如下命令删除Neo4j中的所有数据以便测试。

```
MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r

```
构造上图关系。
```
create (i:Swedish{name:'Andres',age:36}),(j:Swedish{name:'Tobias',age:25}),(k:Swedish:German{name:'Peter',age:31}),
(i)-[:KNOWS]->(j),
(i)-[:KNOWS]->(k)
return i,j,k
```
#### 移除属性

```
match (andres{name:'Andres'}) remove andres.age return andres

```

#### 移除一个节点的多个Label

```
match (n{name:'Peter'}) remove n:German:Swedish return n
```


### 删除（Delete）
**Delete关键字用于删除图元素-----nodes, relationships or paths**
想要移除属性（properties ）和标签（labels）使用`Remove`
>在删除节点（Node）之前，一定要先删除关系（Relationships）或者使用`DETACH DELETE`语句删除.

![cypher-delete](http://neo4j.com/docs/stable/images/cypher-delete-graph.svg)

构造如上图关系,他们额外增加相同Label。然后回显他们。

```
create (j:Useless{name:'Andres',age:36}),(k:Useless{name:'Tobias',age:25}),(l:Useless{name:'Peter',age:34}),
(j)-[:KNOWS]->(k),
(j)-[:KNOWS]->(l)
return j,k,l
```
#### 删除所有KNOWS关系
```
match ()-[r:KNOWS]-() delete r
```
#### 删除所有带Useless标签的节点
```
match (n: Useless) delete n
```
##### 删除所有的节点和边
```
MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r

版本2.3 以后可以使用如下方式：

MATCH (n) DETACH DELETE n
```
#### 删除属性为Andres的点和链接的关系
```
MATCH (n { name: 'Andres' })-[r]-() DELETE n, r

版本2.3 以后可以使用如下方式：

MATCH (n { name:'Andres' }) DETACH DELETE n
```
### 更新（Set）
**Set用于更新Label、Node或者Relationships上面的属性。**
同样可以使用基于map的参数化设置属性
![cypher-set](http://neo4j.com/docs/stable/images/cypher-set-graph.svg)

执行如下命令删除Neo4j中的所有数据以便测试。
```
MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r

```

构造如上图的节点关系图
```
create (i{name:'Stefan'}),(j{name:'Emil'}),(k:Swedish{name:'Andres',age:36,hungry:true}),(m{name:'Peter',age:34}),
(i)-[:KNOWS]->(k),
(j)-[:KNOWS]->(m),
(k)-[:KNOWS]->(m)
return i,j,k,m
```


#### 给其中一个节点增加属性
```
MATCH (n { name: 'Andres' })SET n.surname = 'Taylor'RETURN n
```
#### 移除一个属性
正常情况下使用`Remove`移除属性，有的时候为了方便使用set命令，比如属性来自参数。

```
MATCH (n { name: 'Andres' })SET n.name = NULL RETURN n
```
#### 使用map添加属性
```
MATCH (peter { name: 'Peter' })SET peter += { hungry: TRUE , position: 'Entrepreneur' } retrun peter
```
#### 使用参数化设置属性
具体关系参数化参考:Create
```
:POST /db/data/transaction/commit
{
  "statements": [
    {
      "statement": "MATCH (n { name: 'Stefan' }) SET n.surname = { surname } RETURN n",
      "parameters": {
        "surname": "Taylor"
      }
    }
  ]
}
查看这个节点

match (n{name:'Stefan'}) return n
```
##### 使用参数化重设多个属性

```
:POST /db/data/transaction/commit{
  "statements": [
    {
      "statement": "MATCH (n { name: 'Stefan' }) SET n= { props} RETURN n",
      "parameters": {
        "props": {
          "name": "Andres",
          "position": "Developer"
        }
      }
    }
  ]
}

match (n{name:'Andres'}) return n
```
#### 设置多个属性
```
match (n{name:'Andres'}) set n.porition = 'Beijing',n.surname = 'Taylor' return n
```

#### 在节点上设置多个标签
```
match (n{name:'Andres'}) set n:German:Bossman return n
```
### 循环（Foreach）
**Foreach 是对集合数据进行操作（eg:更新）**


## 暂停更新
**公司放弃Neo4j 在项目中的应用**

