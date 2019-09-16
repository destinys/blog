---
title: Hive知识体系之六
date: 2019-07-19 16:00:00
tags: Hive
---


# Hive QL及常用函数
Hive QL主要分为DDL、DML及DQL；

<!-- more -->
##  DDL操作
主要包括数据库、表及视图的增删改查；此部分内容已在第五章Hive数据库/表中进行了介绍，不再重复说明；
## DML操作
hive不支持用insert语句一条一条的进行插入操作，也不支持update操作。数据是以load的方式加载到建立好的表中。数据一旦导入就不可以修改。
DML包括：INSERT插入、UPDATE更新、DELETE删除(hive基本不支持delete操作，可使用truncate代替)

### 数据加载
数据加载语法为：

```sql
LOAD DATA [LOCAL] INPATH 'filepath' [OVERWRITE] INTO TABLE tablename [PARTITION (partcol1=val1, partcol2=val2 ...)]
```
+ LOAD:仅进行数据复制或移动，使数据变更至目标表对应hdfs路径下；
+ LOCAL：添加LOCAL关键字表示数据文件在本地路径，缺省默认为hdfs路径;
+ OVERWRITE：OVERWRITE会将目标路径或表中数据删除后，写入新的数据至目标路径或表；
+ filepath：指定数据文件路径，可使用相对路径或绝对路径；
+ PARTITION:指定数据加载至表分区中；

使用范例：

```sql
hive> LOAD DATA LOCAL INPATH './examples/files/kv2.txt' OVERWRITE INTO TABLE invites PARTITION (ds='2019-04-23');
```

### 数据写入/写出
Hive支持将查询结果直接写入数据表或写出至指定目录中，语法格式为：

```sql
--数据写出至指定路径，支持hdfs路径或本地路径
INSERT OVERWRITE [LOCAL] DIRECTORY directory1 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
SELECT ...FROM from_statement  ;
--数据写入Hive表中
INSERT OVERWRITE TABLE tablename1 [PARTITION (partcol1=val1, partcol2=val2 ...)] select_statement1 FROM from_statement
```

### 数据删除
目前Hive对delete操作支持较差，一般进行数据删除时，使用overwrite或truncate，但Hive外表不支持truncate操作；
语法格式为：

```sql
--删除整表数据
TRUNCATE TABLE tablename1;
--删除指定分区数据
ALTER TABLE tablename1 TRUNCATE PARTITION (partcol1=val1);
```

## DQL操作
DQL操作包括基本的select操作以及多表join操作；

### 基础查询
语法格式为：

```sql
SELECT [DISTINCT] select_expr, select_expr, ...FROM table_reference 
[WHERE where_condition]
[GROUP BY col_list [HAVING condition]]
[
CLUSTER BY col_list| [DISTRIBUTE BY col_list] [SORT BY|ORDER BY col_list]
]
[LIMIT number]
```
+ DISTINCT：对查询字段进行去重复；
+ WHERE：对查询数据集进行筛选，不支持exists；
+ SORT BY：仅各节点进行数据排序；
+ ORDER BY：全局进行排序；
+ LIMIT：限制返回记录行数；如果为简单查询，则生成local task进行数据抽样；

使用范例：

```sql
select distinct id from xf.demo where id between 1 and 3 order by id;
```

### 多表join查询
语法格式为：

```sql
SELECT [DISTINCT] select_expr, select_expr, ...FROM table_reference1 [LEFT [SEMI]|RIGHT|FULL] [OUTER] JOIN table_reference2  ON join_condition
[WHERE where_condition]
```
+ Hive 只支持等值连接（equality joins）、外连接（outer joins）和（left semi joins）。Hive 不支持所有非等值的连接，因为非等值连接非常难转化到 map/reduce 任务;
+ ON join_condition 仅支持'='操作，不等式限制在hive中不支持；
+ WHERE where_condition 用于对关联后的结果集进行过滤；

## Hive Join
### Inner Join
Inner join又称为内连接或等连接，其中inner可以省略，返回结果集为参与连接表的交集；

```sql
SELECT * FROM TABLE_A T1 INNER JOIN TABLE_B T2 ON T1.COL1= T2.COL1
```

### Outer Join
Outer join又称为外链接，其中outer 可以省略，外链接包含三张链接方式；

#### Left Outer Join
Left outer join通常简写为left join，返回结果集为左表全部记录及匹配记录的右表列信息；

```sql
SELECT * FROM TABLE_A T1 LEFT JOIN TABLE_B T2 ON T1.COL1= T2.COL1
```

#### Right Outer Join
Right outer join通常简写为right join，返货结果集为右表全部记录及匹配右表的左表列信息；

```sql
SELECT * FROM TABLE_A T1 RIGHT JOIN TABLE_B T2 ON T1.COL1= T2.COL1
```

#### Full Outer Join
Full outer join通常简写为full join，返货结果集为左表及右表的并集，两表交集部分合并为一条记录；

```sql
SELECT * FROM TABLE_A T1 FULL JOIN TABLE_B T2 ON T1.COL1= T2.COL1
```

### Semi Join
Hive当前没有实现IN/EXISTS子查询功能，Semi join用于IN/EXISTS的替代实现；

```sql
--in/exists语句
SELECT T1.COL1,T1.COL2 FROM TABLE_A WHERE T1.COL1 IN (SELECT T2.COL1 FROM TABLE_B)

--Semi Join
SELECT T1.COL1,T1.COL2 FROM TABLE_A T1 SEMI JOIN TABLE_B ON T1.COL1 = T2.COL1 
```
+ SEMI JOIN 要求TABLE_B只能在ON子句中进行条件过滤，不支持WHERE子句、SELECT子句等其他地方过滤；
+ SEMI JOIN 的KEY仅传递给MAP阶段，最后的返回结果仅允许出现TABLE_A的列；
+ TABLE_B中出现重复记录不会导致笛卡尔积；


## 常用函数
### 聚合函数
+ sum：求和函数
+ count：计数函数
+ avg：求平均数
+ max：求最大值
+ min：求最小值

### 分析函数
+ row_number()over(partition by p_col order by o_col)：对p_col进行分组并按照o_col进行排序，排序序号连续且不重复；
+ dense_rank()over(partition by p_col order by o_col)：对p_col进行分组并按照o_col进行排序，o_col相同则序号相同，排序序号连续；
+ rank()over(partition by p_col order by o_col)：对p_col进行分组并按照o_col进行排序，o_col相同则序号相同，排序序号不连续；
+ cume_dist()over(partition by p_col order by o_col)：对p_col进行分组并按照o_col进行排序后，返回当前o_col所占总记录百分比；

### 条件函数
+ if(condition,col_a,col_b)：根据condition真假返回对应col，为真则返回col_a，否则返回col_b
+ isnull()：判断是否为空；
+ isnotnull()：判断是否非空
+ nvl(col_a,col_b)：如果col_a为空则返回col_b，否则返回col_a

### 日期函数
+ **string** add_months(string/date/timestamp start_date,int num)：返回start_date加上num个月后日期，如果返回日期在当月不存在，则返回当月最后一天；eg:
    + add_months('2009-08-31', 1)；
    + add_months('2017-12-31 14:15:16', 2, 'YYYY-MM-dd HH:mm:ss') returns '2018-02-28 14:15:16'
+ **date** current_date()：返回SQL执行时的当前日期，同一语句中各处调用返回值均一致；
+ **timestamp** current_timestamp()：返回SQL执行时的时间戳，，同一语句中各处调用返回值均一致；
+ **int** datediff(string start_date,string end_date)：返回两个时间之间相差天数；eg:
    +  datediff('2009-03-01', '2009-02-27') = 2
+ **date** date_add(date/timestamp/string start_date, int days)：返回start_date后days天日期;*hive 2.1.0版本前返回值为string*；eg:
    + date_add('2008-12-31', 1) = '2009-01-01'.
+ **date** date_sub(date/timestamp/string start_date, int days)：返回start_date前days天日期;*hive 2.1.0版本前返回值为string*；eg:
    + date_sub('2008-12-31', 1) = '2008-12-30'
+ **string** date_format(date/timestamp/string ts, string fmt)：将ts按照fmt格式进行格式化转换；eg:
    + date_format('2015-04-08', 'y') = '2015'
+ **int** day(string date)：返回date中的天部分；eg:
    + day("1970-11-01") = 1.
+ **string** from_unixtime(bigint unixtime[, string format])：将unixtime按照format进行格式化；
+ **string** last_day(string date)：返回date对应月份的最后一天，date的格式应为'yyyy-MM-dd HH:mm:ss'或'yyyy-MM-dd';
+ **date** to_date(string timestamp)：将时间戳转换为日期；*hive 2.1.0版本前返回值为string*
+ **string** trunc(string date, string format)：将date按照指定format进行截取，format支持MONTH/MON/MM, YEAR/YYYY/YY，其中date格式需为'yyyy-MM-dd HH:mm:ss'或'yyyy-MM-dd'；eg:
    + trunc('2015-03-17', 'MM') = 2015-03-01
+ **bigint** 	unix_timestamp(string date, string pattern)：将指定日期字符串按照指定pattern进行格式化为时间戳；eg：
    + unix_timestamp('2009-03-20', 'yyyy-MM-dd') = 1237532400

### 数学函数
+ round(double num,int a)：将num进行四舍五入，保留a位小数；
+ ceil(double num)：将num向下取整；
+ floor(double num)：将num向上取整；
+ rand(INT seed)：以seed为种子生成随机数；

### 字符串函数
+ **string** concat(string|binary A, string|binary B...)：将字符串A与字符串B进行拼接；
+ **string** concat_ws(string SEP, string A, string B...)：将字符串A与字符串B使用sep作为分隔符进行连接；
+ **string** get_json_object(string json_string, string path)：将json_string按照json进行解析，path指定json的路径，以'$.xxx.xxx'格式进行指定；指定路径不存在或非法时返回null;
+ **int** instr(string str, string substr)：在字符串str中找到substr，并返回其索引位置；
+ **string** substr(string|binary A, int start, int len)：对字符串A进行截取，从第start位开始截取len位；
+ **string** trim(string A)：去除字符串A开始与结束的空格字符；
+ **string** lower(string A)：将字符串A中大写字母转换为小写；
+ **string** upper(string A)：将字符串A中小写字母转换为大写；
+ **int** length(string A)：返回字符串A的长度;
+ **string** regexp_replace(string INITIAL_STRING, string PATTERN, string REPLACEMENT)：将字符串initial_string中匹配pattern部分替换为replacement；pattern支持正则；

### 类型转换
+ cast(a AS T)：将a强制转换为类型T，无法进行类型转换为T时返回空值；

### 行列转换
+ explode(SET/MAP/ARRAY<T> a)：将一个集合/映射/数组类型转换为多行记录返回；
+ json_tuple(string jsonStr,string k1,...,string kn)：将一个json串值解析出来；

除以上常用函数外，Hive官方提供了完整版本的Hive内置函数列表，详见https://cwiki.apache.org/confluence/display/Hive/LanguageManual+UDF

## 自定义函数
Hive除了提供丰富的内置函数之外，还允许用户使用Java开发自定义UDF函数；
开发自定义UDF函数有两种方式，一个是继承org.apache.hadoop.hive.ql.exec.UDF，另一个是继承org.apache.hadoop.hive.ql.udf.generic.GenericUDF；

如果是针对简单的数据类型（比如String、Integer等）可以使用UDF，如果是针对复杂的数据类型（比如Array、Map、Struct等），可以使用GenericUDF，另外，GenericUDF还可以在函数开始之前和结束之后做一些初始化和关闭的处理操作。

### UDF
#### UDF开发
##### 简单UDF
使用UDF非常简单，只需要继承org.apache.hadoop.hive.ql.exec.UDF，并定义public Object evaluate(Object args) {} 方法即可。
比如以下UDF函数实现对String类型的字符串全部转换为大写：

```java
package org.semon.hive.udf;

import org.apache.hadoop.hive.ql.exec.UDF;

public class SimpleUDF extends UDF {
    public String evaluate(String str)
    {
        return str.toUpperCase();
    }
}
```
##### 复杂UDF
org.apache.hadoop.hive.ql.udf.generic.GenericUDF API提供了一种方法去处理那些不是可写类型的对象，例如：struct，map和array类型。
这个API需要你亲自去为函数的参数去管理对象存储格式（object inspectors），验证接收的参数的数量与类型。一个object inspector为内在的数据类型提供一个一致性接口，以至不同实现的对象可以在hive中以一致的方式去访问（例如，只要你能提供一个对应的object inspector，你可以实现一个如Map的复合对象）。

```java
package org.semon.hive.udf;

import org.apache.hadoop.hive.ql.udf.generic.GenericUDF;

public class ComplexUDF extends GenericUDF {
  ListObjectInspector listOI;  
  StringObjectInspector elementOI;  
  
  @Override  
  public String getDisplayString(String[] arg0) {  
    return "arrayContainsExample()"; // this should probably be better  
  }  
  
  @Override  
  public ObjectInspector initialize(ObjectInspector[] arguments) throws UDFArgumentException {  
    if (arguments.length != 2) {  
      throw new UDFArgumentLengthException("arrayContainsExample only takes 2 arguments: List<T>, T");  
    }  
    // 1. 检查是否接收到正确的参数类型  
    ObjectInspector a = arguments[0];  
    ObjectInspector b = arguments[1];  
    if (!(a instanceof ListObjectInspector) || !(b instanceof StringObjectInspector)) {  
      throw new UDFArgumentException("first argument must be a list / array, second argument must be a string");  
    }  
    this.listOI = (ListObjectInspector) a;  
    this.elementOI = (StringObjectInspector) b;  
      
    // 2. 检查list是否包含的元素都是string  
    if(!(listOI.getListElementObjectInspector() instanceof StringObjectInspector)) {  
      throw new UDFArgumentException("first argument must be a list of strings");  
    }  
      
    // 返回类型是boolean，所以我们提供了正确的object inspector  
    return PrimitiveObjectInspectorFactory.javaBooleanObjectInspector;  
  }  
    
  @Override  
  public Object evaluate(DeferredObject[] arguments) throws HiveException {  
      
    // 利用object inspectors从传递的对象中得到list与string  
    List<String> list = (List<String>) this.listOI.getList(arguments[0].get());  
    String arg = elementOI.getPrimitiveJavaObject(arguments[1].get());  
      
    // 检查空值  
    if (list == null || arg == null) {  
      return null;  
    }  
      
    // 判断是否list中包含目标值  
    for(String s: list) {  
      if (arg.equals(s)) return new Boolean(true);  
    }  
    return new Boolean(false);  
  }  
}

```


将以上类打包为jar包，打包后jar包名为udf-1.0.jar

#### UDF注册
UDF函数注册分为临时函数与永久函数；

##### 临时UDF
添加临时函数，只能在此会话中生效，退出hive自动失效

```sql
add jar /user/semon/udf-1.0.jar;
create temporary function f_upper as 'org.semon.hive.udf.SimpleUDF';
```

### 永久UDF
+ 配置jar包文件所在路径；
    + 通过在HIVE_HOME创建auxlib文件夹，将对应jar包放入auxlib目录；
    + 在hive-site.xml配置文件中添加以下属性；

        ```xml
        <property>
        <name>hive.aux.jars.path</name>
        <value>file:///user/semon/udf-1.0.jar</value>
        </property>
        ```
+ 注册函数

    ```sql
    create function f_upper as 'org.semon.hive.udf.SimpleUDF';
    ```
    
    
