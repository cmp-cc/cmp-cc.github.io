----
title: H2 DataBase 数据库
date: 2016-4-12 17:49:00
categories: 
- 数据库
tags:
- 嵌入式数据库
- H2
----

H2 DataBase属于Java 嵌入式数据库（内存数据库），除此之外还有HyperSQL Database、 Apache Derby。

H2 貌似用的人更多一些，这篇文章只是介绍 H2 Web开发实例。

H2 生产环境几乎没有人用，他不适用高并发和大数据，并发越大插入和读取性能越低。

H2 应用场景：
* 小型内部系统
* 数据缓存
* 监控系统
* 测试环境（如：开启MySql模式）

**以上都是我YY的，没有实战，可信度30%**

## H2 DataBase 数据库

### Maven 引入H2依赖

```
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <version>1.4.191</version>
</dependency>
```
### H2 实例

**部分实例参考官网**

#### JDBC 连接

* 获取JDBC 连接
```
    private static String driver = "org.h2.Driver";
    private static String url = "jdbc:h2:./h2db";
    private static String username = "root";
    private static String password = "123456";

    public static Connection getConnection() {
        try {
            Class.forName(driver);
            // 可以不用设置户名和密码
            Connection connection = DriverManager.getConnection(url, username, password);
            return connection;
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return null;
    }  
```

* 获取JDBC连接池

```
    private static final String url = "jdbc:h2:./h2db";
    private static final String username = "root";
    private static final String password = "123456";
    
    private static JdbcConnectionPool pool = JdbcConnectionPool.create(url,username,password);
    
    static {
        pool.setLoginTimeout(1000); // 连接超时时间
        pool.setMaxConnections(50); // 最大连接数
    }
    
    /**
     * @return 获取H2 JDBC连接池
     */
    public static JdbcConnectionPool getJDBCConnectionPool(){  
        return pool;  
    }  
    
    public static Connection getConnection(){
        try {
            return pool.getConnection();
        } catch (SQLException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }finally{
            // 释放空闲连接
            pool.dispose(); 
        }
        return null;
    }
```

**jdbc:h2:./h2db 中h2db表示数据库名称,它会在当前路径中创建h2db.mv.db文件，用于记录数据库数据信息。**
**有了Connection（JDBC链接）我相信你已经无敌了。**

### H2 工具
**H2 与众不同的一点，它提供了一些工具操作**

#### 读写CVS
```

    /**
     * Write a CSV file.
     */
    static void write() throws SQLException {
        SimpleResultSet rs = new SimpleResultSet();
        rs.addColumn("NAME", Types.VARCHAR, 255, 0);
        rs.addColumn("EMAIL", Types.VARCHAR, 255, 0);
        rs.addColumn("PHONE", Types.VARCHAR, 255, 0);
        rs.addRow("Bob Meier", "bob.meier@abcde.abc", "+41123456789");
        rs.addRow("John Jones", "john.jones@abcde.abc", "+41976543210");
        new Csv().write("data/test.csv", rs, null);
    }
    /**
     * Read a CSV file.
     */
    static void read() throws SQLException {
        ResultSet rs = new Csv().read("data/test.csv", null, null);
        ResultSetMetaData meta = rs.getMetaData();
        while (rs.next()) {
            for (int i = 0; i < meta.getColumnCount(); i++) {
                System.out.println(meta.getColumnLabel(i + 1) + ": " + rs.getString(i + 1));
            }
            System.out.println();
        }
        rs.close();
    }  

```
#### 服务和脚本
**暂略吧，没什么应用场景。**

### H2 全文检索
H2 的全文检索主要使用FullText和FullTextLucene类，使用相对简单，主要使用Search() 和 SearchData()方法。

**使用H2 主要还是使用SQL操作，其他的特性也很少用。**


