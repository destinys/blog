---
title: Hive知识体系之三
date: 2019-07-19 13:00:00
tags: Hive
---

# Hive Shell常用操作

## Hive非交互模式常用命令
命令格式为：hive -paramater

<!-- more -->

```
-e：从命令行执行指定的HQL，HQL后不需要分号 

hive -e 'select * from dummy' > a.txt
 
–f： 执行HQL脚本文件

hive -f /home/my/hive-script.sql  --hive-script.sql是hql脚本文件
 
-i：进入Hive交互Shell时候先执行脚本中的HQL语句

hive -i /home/my/hive-init.sql
 
-v：冗余verbose模式，额外打印出执行的HQL语句

hive -v -e "select count(*) from wangbin.demo"
 
-S：静默Slient模式，不显示转化MR-Job的信息，只显示最终结果

hive -S -e "select count(*) from wangbin.demo"
 
--hiveconf ：使用给定属性的值 

hive --hiveconf mapred.reduce.tasks=2 --启动时,配置reduce个数2（只在此session中有效）
 
--service serviceName：启动服务

hive --service metastore 10000 &
 
--database src：进入CLI交互界面，默认进入default数据库，--database指定进入后的默认数据库。

hive --database src
```

 
## Hive的交互模式下命令：

```
quit/exit：退出CLI

reset：重置所有的配置参数，初始化为hive-site.xml中的配置。如之前使用set命令设置了reduce数量。

set =：设置Hive运行时配置参数，优先级最高，相同key，后面的设置会覆盖前面的设置。

set –v：打印出所有Hive的配置参数和Hadoop的配置参数。

#找出和"mapred.reduce.tasks"相关的设置
hive -e 'set -v;' | grep mapred.reduce.tasks
 
add命令：包括add File[S]/Jar[S]/Archive[S] *，向 DistributeCache 中添加一个或过个文件、jar包、或者归档，添加之后，可以在Map和Reduce task中使用。比如，自定义一个udf函数，打成jar包，在创建函数之前，必须使用add jar命令，将该jar包添加，否则会报错找不到类。

list 命令：包括list File[S]/Jar[S]/Archive[S]。列出当前DistributeCache中的文件、jar包或者归档。

delete 命令：包括 delete File[S]/Jar[S]/Archive[S] *。从DistributeCache中删除文件。

#将file加入缓冲区
add file /root/test/sql;
#列出当前缓冲区内的文件
list file
#删除缓存区内的指定file
delete file /root/test/sql;
 
create命令：创建自定义函数

hive> create temporary function udfTest as ‘com.cstore.udfExample’
 
source ：在CLI中执行脚本文件。

#相当于[root@ncst test]# hive -S -f /root/test/sql
hive> source /root/test/sql; 
 
! <command>：在CLI执行Linux命令。

dfs <dfs command>：在CLI执行hdfs命令

```
## 本地获取Hive数据
### Hive
```bash
#重定向方式 bash #分隔符和hive数据文件的分隔符相同
hive -S -e 'select * from dummy' > a.txt
#Hive写出数据至本地路径，仅支持客户端模式

#可通过row format指定字段分隔符
hive -S -e "insert overwrite local directory '/root/hive/a' row format delimited fields terminated by '\t' "
 
#直接下载Hive对应hdfs数据文件
hive -S -e "dfs -get /hive/warehouse/hive01 /root/test/hive01"
```
 
### Beeline
Beeline和其他工具有一些不同，执行查询都是正常的SQL输入，但是如果是一些管理的命令，
比如进行连接，中断，退出，执行Beeline命令需要带上“！”，不需要终止符。常用命令介绍：


```bash
!connect url –连接不同的Hive2服务器

!exit –退出shell

!help –显示全部命令列表

!verbose –显示查询追加的明细

Option Description  
--autoCommit=[true/false] ---进入一个自动提交模式：beeline --autoCommit=true  
--autosave=[true/false]   ---进入一个自动保存模式：beeline --autosave=true  
--color=[true/false]    ---显示用到的颜色：beeline --color=true  
--delimiterForDSV= DELIMITER ---分隔值输出格式的分隔符。默认是“|”字符。  
--fastConnect=[true/false]  ---在连接时，跳过组建表等对象：beeline --fastConnect=false  
--force=[true/false]    ---是否强制运行脚本：beeline--force=true  
--headerInterval=ROWS   ---输出的表间隔格式，默认是100: beeline --headerInterval=50  
--help ---帮助  beeline --help  
--hiveconf property=value  ---设置属性值，以防被hive.conf.restricted.list重置：beeline --hiveconf prop1=value1   
--hivevar name=value   ---设置变量名：beeline --hivevar var1=value1  
--incremental=[true/false]  ---输出增量
--isolation=LEVEL  ---设置事务隔离级别：beeline --isolation=TRANSACTION_SERIALIZABLE  
--maxColumnWidth=MAXCOLWIDTH ---设置字符串列的最大宽度：beeline --maxColumnWidth=25  
--maxWidth=MAXWIDTH ---设置截断数据的最大宽度：beeline --maxWidth=150  
--nullemptystring=[true/false]  ---打印空字符串：beeline --nullemptystring=false  
--numberFormat=[pattern]     ---数字使用DecimalFormat：beeline --numberFormat="#,###,##0.00"  
--outputformat=[table/vertical/csv/tsv/dsv/csv2/tsv2] ---输出格式：beeline --outputformat=tsv   
--showHeader=[true/false]   ---显示查询结果的列名：beeline --showHeader=false  
--showNestedErrs=[true/false] ---显示嵌套错误：beeline --showNestedErrs=true  
--showWarnings=[true/false] ---显示警告：beeline --showWarnings=true  
--silent=[true/false]  ---静默方式执行，不显示执行过程信息：beeline --silent=true  
--truncateTable=[true/false] ---是否在客户端截断表的列     
--verbose=[true/false]  ---显示详细错误信息和调试信息：beeline --verbose=true  
-d <driver class>  ---使用一个驱动类：beeline -d driver_class  
-e <query>  ---使用一个查询语句：beeline -e "query_string"  
-f <file>  ---加载一个文件：beeline -f filepath  多个文件用-e file1 -e file2
-n <username>  ---加载一个用户名：beeline -n valid_user  
-p <password>  ---加载一个密码：beeline -p valid_password  
-u <database URL> ---加载一个JDBC连接字符串：beeline -u db_URL
 
# beeline使用范例：

beeline -u "jdbc:hive2://dwtest-name1:10000/default" -n root --silent=true --outputformat=csv2  -hivevar logdate=${dt}  -f script.q > ${file_tmp}
 
-f 对应查询的脚本 script.q
--outputformat=csv2 以逗号分隔
--silent=true 静默方式执行，注意：输出文件的时候必须以静默方式运行，否则输出的文本中带有很多程序执行信息。
```
