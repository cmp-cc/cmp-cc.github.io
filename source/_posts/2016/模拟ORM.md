----
title: 模拟ORM
date: 2016-04-14 18:34:00
categories: 
- Programming Language
- Java
tags:
- Java
----


有时候做一些展示用的项目，或者是测试项目，可能并不会去引入Hibernate 等这类ORM框架，这显的小题大做。但是没有ORM框架方便的特性，又感觉一只手绑在背后，好把！ 实现一些简单的ORM特性。



## SQL Mapping Java

### 整体实体关系映射

类型名称|	显示长度|	数据库类型|	JAVA类型|	JDBC类型索引(int)
 --- |        ---    |   ---     |   ---   |    ---          		 	 
VARCHAR|	L+N	|VARCHAR|	java.lang.String|	12	 
CHAR|	N|	CHAR|	java.lang.String|	1	 
BLOB|	L+N|	BLOB|	java.lang.byte[]|	-4	 
TEXT	|65535|	VARCHAR	|java.lang.String|	-1	  
INTEGER|	4|	INTEGER UNSIGNED|	java.lang.Long|	4	 
TINYINT	|3	|TINYINT UNSIGNED|	java.lang.Integer|	-6	 
SMALLINT|	5|	SMALLINT UNSIGNED|	java.lang.Integer|	5	 
MEDIUMINT|	8|	MEDIUMINT UNSIGNED|	java.lang.Integer|	4	 
BIT	|1|	BIT	|java.lang.Boolean|	-7	 
BIGINT|	20|	BIGINT UNSIGNED	|java.math.BigInteger|	-5	 
FLOAT|	4+8|	FLOAT	|java.lang.Float|	7	 
DOUBLE|	22|	DOUBLE	|java.lang.Double|	8	 
DECIMAL	|11|	DECIMAL|	java.math.BigDecimal|	3	 
BOOLEAN	|1	|TINYINT UNSIGNED|	java.lang.Integer|	-6	  
ID	|11|	PK (INTEGER UNSIGNED)|	java.lang.Long|	4	 
DATE|	10	|DATE|	java.sql.Date|	91	 
TIME|	8|	TIME|	java.sql.Time	|92	 
DATETIME|	19|	DATETIME|	java.sql.Timestamp	|93	 
TIMESTAMP|	19	|TIMESTAMP|	java.sql.Timestamp	|93	 
YEAR	|4	|YEAR|	java.sql.Date	|91






### MySQL 实体类型映射
MySQL Type Name|	Return value of GetColumnClassName	| Returned as Java Class
--- | --- | ---
BIT(1) (new in MySQL-5.0)	|BIT	|java.lang.Boolean
BIT( > 1) (new in MySQL-5.0)	|BIT|	byte[]
TINYINT	|TINYINT	|java.lang.Boolean if the configuration property tinyInt1isBit is set to true (the default) and the storage size is 1, or java.lang.Integer if not.
BOOL, BOOLEAN|	TINYINT	|See TINYINT, above as these are aliases for TINYINT(1), currently.
SMALLINT[(M)] [UNSIGNED]|	SMALLINT [UNSIGNED]	|java.lang.Integer (regardless if UNSIGNED or not)
MEDIUMINT[(M)] [UNSIGNED]|	MEDIUMINT [UNSIGNED]|	java.lang.Integer, if UNSIGNED java.lang.Long (C/J 3.1 and earlier), or java.lang.Integer for C/J 5.0 and later
INT,INTEGER[(M)] [UNSlGNED] | INTEGER [UNSIGNED] | java.lang.Integer, if UNSIGNED java.lang.Long
BIGINT[(M)] [UNSIGNED] | BIGINT [UNSIGNED]	| java.lang.Long, if UNSIGNED java.math.BigInteger
FLOAT[(M,D)]|	FLOAT	|java.lang.Float
DOUBLE[(M,B)]|	DOUBLE	|java.lang.Double
DECIMAL[(M[,D])]|	DECIMAL|	java.math.BigDecimal
DATE	|DATE	|java.sql.Date
DATETIME	|DATETIME	|java.sql.Timestamp
TIMESTAMP[(M)]	|TIMESTAMP|	java.sql.Timestamp
TIME	|TIME	|java.sql.Time
YEAR[(2l4)]|	YEAR|	If yearIsDateType configuration property is set to false, then the returned object type is java.sql.Short. If set to true (the default), then the returned object is of type java.sql.Date with the date set to January 1st, at midnight.
CHAR(M)|	CHAR|	java.lang.String (unless the character set for the column is BINARY, then byte[] is returned.
VARCHAR(M)| [BINARY]	|VARCHAR	java.lang.String (unless the character set for the column is BINARY, then byte[] is returned.
BINARY(M)|	BINARY	|byte[]
VARBINARY(M)	|VARBINARY|	byte[]
TINYBLOB|	TINYBLOB	|byte[]
TINYTEXT|	VARCHAR|	java.lang.String
BLOB|	BLOB	|byte[]
TEXT|	VARCHAR	|java.lang.String
MEDIUMBLOB	|MEDIUMBLOB|	byte[]
MEDIUMTEXT	|VARCHAR	|java.lang.String
LONGBLOB|	LONGBLOB|	byte[]
LONGTEXT|	VARCHAR	|java.lang.String
ENUM('value1','value2',...)	|CHAR|	java.lang.String
SET('value1','value2',...)	|CHAR	|java.lang.String


参考： http://dev.mysql.com/doc/connector-j/5.1/en/connector-j-reference-type-conversions.html

## 模拟ORM 

### 根据实体映射表
**如下只是一个基本实例，想要完成更多特性，还是要下点功夫的。**
```
public class CreateTableORM {
    
    private static Map<String,String> ormField = getJavaMapMysql();
    
    Class<?> clazz;
    
    Connection conn;
    
    // 表名
    String tableName;
    
    public CreateTableORM(Class<?> clazz , Connection conn){
        this.clazz = clazz;
        this.conn = conn;
        tableName = clazz.getName();
        
        createTable();
    }
    
    private void createTable(){
        
         StringBuffer sb = new StringBuffer();
        
         Arrays.asList(clazz.getDeclaredFields()).forEach(field ->{
             
            String fieldType = ormField.get(field.getType().getName());
            String fieldName = field.getName();
            
            sb.append(String.format("%s %s,", fieldName,fieldType));
        });
        
        String sql = String.format("Create Table If Not Exists %s (%s)",this.tableName, sb.deleteCharAt(sb.length()-1).toString());
        
        excuteSQL(sql);
    }
    
    private void excuteSQL(String sql) {
        PreparedStatement statement;
        
        try {
            statement = conn.prepareStatement(sql);
            statement.execute();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    public static Map<String,String> getJavaMapMysql(){
        
        /**定义并不标准**/
        Map<String,String> map = new HashMap<String,String>();
        map.put("java.lang.String", "VARCHAR(255)");
        map.put("java.lang.Character", "VARCHAR(255)");
        map.put("char", "VARCHAR(255)");
        map.put("java.lang.Double", " DOUBLE(5,2)");
        map.put("double", " DOUBLE(5,2)");
        map.put("java.lang.Float", "FLOAT(5,2)");
        map.put("float", "FLOAT(5,2)");
        map.put("java.lang.Integer", "INT(11)");
        map.put("int", "INT(11)");
        map.put("java.lang.Long", "INTEGER(16)");
        map.put("long", "INTEGER(16)");
        map.put("java.util.Date", "DATE");
        map.put("java.lang.Boolean", "BIT(1)");
        map.put("boolean", "BIT(1)");
        return map;
    }
    
    //测试
    public static void main(String[] args) {
        Connection conn = MysqlJDBCPoolUtil.getConnection();
        new CreateTableORM(Admin.class, conn);
    }
}  
```

### 暂无需求。

**日后，有需要再完善**



