---
title: Hive知识体系之八
date: 2019-07-19 18:00:00
tags: Hive
---

# Hive执行计划及调优
Hive底层主流是使用MR编程实现，我们可以通过执行计划来了解我们的HQL转换后的MR任务是哪些以及如何执行的;

Hive查看执行计划的语法为 explain HQL

<!-- more -->

## HQL执行计划 

我们先来看一条sql的执行计划 

```sql
explain select b.name ,count(distinct b.name) from wangbin.demo_info a join  wangbin.data_temp b on a.id=b.id where b.name>100 group by b.name having count(*) > 10 order by b.name;
```

解析计划输出如下:


```sql
Explain
STAGE DEPENDENCIES:
  Stage-1 is a root stage
  Stage-2 depends on stages: Stage-1
  Stage-3 depends on stages: Stage-2
  Stage-0 depends on stages: Stage-3
  
STAGE PLANS:
  Stage: Stage-1
    Map Reduce
      Map Operator Tree:
          TableScan
            alias: a
            Statistics: Num rows: 5 Data size: 24 Basic stats: COMPLETE Column stats: NONE
            Filter Operator
              predicate: id is not null (type: boolean)
              Statistics: Num rows: 5 Data size: 24 Basic stats: COMPLETE Column stats: NONE
              Select Operator
                expressions: id (type: int)
                outputColumnNames: _col0
                Statistics: Num rows: 5 Data size: 24 Basic stats: COMPLETE Column stats: NONE
                Reduce Output Operator
                  key expressions: _col0 (type: int)
                  sort order: +
                  Map-reduce partition columns: _col0 (type: int)
                  Statistics: Num rows: 5 Data size: 24 Basic stats: COMPLETE Column stats: NONE
          TableScan
            alias: b
            Statistics: Num rows: 13 Data size: 156 Basic stats: COMPLETE Column stats: NONE
            Filter Operator
              predicate: ((UDFToDouble(name) > 100.0) and id is not null) (type: boolean)
              Statistics: Num rows: 4 Data size: 48 Basic stats: COMPLETE Column stats: NONE
              Select Operator
                expressions: id (type: int), name (type: string)
                outputColumnNames: _col0, _col1
                Statistics: Num rows: 4 Data size: 48 Basic stats: COMPLETE Column stats: NONE
                Reduce Output Operator
                  key expressions: _col0 (type: int)
                  sort order: +
                  Map-reduce partition columns: _col0 (type: int)
                  Statistics: Num rows: 4 Data size: 48 Basic stats: COMPLETE Column stats: NONE
                  value expressions: _col1 (type: string)
      Reduce Operator Tree:
        Join Operator
          condition map:
               Inner Join 0 to 1
          keys:
            0 _col0 (type: int)
            1 _col0 (type: int)
          outputColumnNames: _col2
          Statistics: Num rows: 5 Data size: 26 Basic stats: COMPLETE Column stats: NONE
          File Output Operator
            compressed: false
            table:
                input format: org.apache.hadoop.mapred.SequenceFileInputFormat
                output format: org.apache.hadoop.hive.ql.io.HiveSequenceFileOutputFormat
                serde: org.apache.hadoop.hive.serde2.lazybinary.LazyBinarySerDe
  
  Stage: Stage-2
    Map Reduce
      Map Operator Tree:
          TableScan
            Reduce Output Operator
              key expressions: _col2 (type: string)
              sort order: +
              Map-reduce partition columns: _col2 (type: string)
              Statistics: Num rows: 5 Data size: 26 Basic stats: COMPLETE Column stats: NONE
      Reduce Operator Tree:
        Group By Operator
          aggregations: count(KEY._col0), count()
          keys: KEY._col0 (type: string)
          mode: complete
          outputColumnNames: _col0, _col1, _col2
          Statistics: Num rows: 2 Data size: 10 Basic stats: COMPLETE Column stats: NONE
          Filter Operator
            predicate: (_col2 > 10) (type: boolean)
            Statistics: Num rows: 1 Data size: 5 Basic stats: COMPLETE Column stats: NONE
            Select Operator
              expressions: _col0 (type: string), _col1 (type: bigint)
              outputColumnNames: _col0, _col1
              Statistics: Num rows: 1 Data size: 5 Basic stats: COMPLETE Column stats: NONE
              File Output Operator
                compressed: false
                table:
                    input format: org.apache.hadoop.mapred.SequenceFileInputFormat
                    output format: org.apache.hadoop.hive.ql.io.HiveSequenceFileOutputFormat
                    serde: org.apache.hadoop.hive.serde2.lazybinary.LazyBinarySerDe
  
  Stage: Stage-3
    Map Reduce
      Map Operator Tree:
          TableScan
            Reduce Output Operator
              key expressions: _col0 (type: string)
              sort order: +
              Statistics: Num rows: 1 Data size: 5 Basic stats: COMPLETE Column stats: NONE
              value expressions: _col1 (type: bigint)
      Reduce Operator Tree:
        Select Operator
          expressions: KEY.reducesinkkey0 (type: string), VALUE._col0 (type: bigint)
          outputColumnNames: _col0, _col1
          Statistics: Num rows: 1 Data size: 5 Basic stats: COMPLETE Column stats: NONE
          File Output Operator
            compressed: false
            Statistics: Num rows: 1 Data size: 5 Basic stats: COMPLETE Column stats: NONE
            table:
                input format: org.apache.hadoop.mapred.SequenceFileInputFormat
                output format: org.apache.hadoop.hive.ql.io.HiveSequenceFileOutputFormat
                serde: org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe
  
  Stage: Stage-0
    Fetch Operator
      limit: -1
      Processor Tree:
        ListSink

``` 

详细说明：


```sql
Explain
STAGE DEPENDENCIES:  #这里给出的是执行依赖顺序
  Stage-1 is a root stage
  Stage-2 depends on stages: Stage-1
  Stage-3 depends on stages: Stage-2
  Stage-0 depends on stages: Stage-3
```

先看第一个stage


```sql
Map Operator Tree:
    Table Scan
        Filter Operator # 过滤操作因为有join所以会过滤掉null字段,如果对这个表对字段有where条件也会在这边执行
            select operator #把id字段取个名字_col0
                Reduce Output Operator #整理reduce的输入，按照_col0字段分区，相同的分区到同一个reuce
  
Reduce Operator Tree:
    Join Operator #condatition map里面的 0和1表示的sql join用on条件连接起来的两个表从左右到命名为0，1，2...
    File Output Operator #对数据进行输出，相当于生成了一个临时表了
```
 
第二个stage
这里和第一个stage差不多重点关注一下Reduce Operator


```sql
Reduce Operator Tree:
    Group By Operator #这里进行了group操作，同时计算了aggregations
        Filter Operation # Group by操作之后进行的having会在这里执行，但是如果having过滤的是某个字段而不是count(*)这类的聚合函数，hive会优化，把这部分放到where里面取执行，也就是TableScan里面  
```      
 
Stage-3
这个stage进行的只有order by操作,这里需要注意的是这个order by只会启动一个reduce

最后一个stage 

```sql
Fetch Operator #这里用的是fetch task，并没有启动MR任务，只是单纯的取数据
      limit: -1
      Processor Tree:
        ListSink

``` 

从上述的执行计划可以看到执行顺序为
1. FROM：对FROM子句中前两个表执行笛卡尔积生成虚拟表vt1
2. ON:对vt1表应用ON筛选器只有满足<join_condition>为真的行才被插入vt2
3. OUTER(join)：如果指定了 OUTER JOIN保留表(preserved table)中未找到的行将行作为外部行添加到vt2生成t3如果from包含两个以上表则对上一个联结生成的结果表和下一个表重复执行步骤和步骤直接结束
4. WHERE：对vt3应用 WHERE 筛选器只有使<where_condition>为true的行才被插入vt4
5. GROUP BY：按GROUP BY子句中的列列表对vt4中的行分组生成vt5
6. HAVING：对vt6应用HAVING筛选器只有使<having_condition>为true的组才插入vt5
7. SELECT：处理select列表产生vt7
8. DISTINCT：将重复的行从vt8中去除产生vt8
9. ORDER BY：将vt8的行按order by子句中的列列表排序生成一个游标vc9

### 分区剪裁的执行计划
#### 无分区剪裁的执行计划


```sql
explain select count(*) from wangbin.demo_partition_date;
 
---------------------------------------------------------
Explain
STAGE DEPENDENCIES:
  Stage-1 is a root stage
  Stage-0 depends on stages: Stage-1
 
STAGE PLANS:
  Stage: Stage-1
    Map Reduce
      Map Operator Tree:
          TableScan
            alias: demo_partition_date
            Statistics: Num rows: 2789212646 Data size: 25102913536 Basic stats: COMPLETE Column stats: NONE
            Select Operator
              Statistics: Num rows: 2789212646 Data size: 25102913536 Basic stats: COMPLETE Column stats: NONE
              Group By Operator
                aggregations: count()
                mode: hash
                outputColumnNames: _col0
                Statistics: Num rows: 1 Data size: 8 Basic stats: COMPLETE Column stats: NONE
                Reduce Output Operator
                  sort order:
                  Statistics: Num rows: 1 Data size: 8 Basic stats: COMPLETE Column stats: NONE
                  value expressions: _col0 (type: bigint)
      Reduce Operator Tree:
        Group By Operator
          aggregations: count(VALUE._col0)
          mode: mergepartial
          outputColumnNames: _col0
          Statistics: Num rows: 1 Data size: 8 Basic stats: COMPLETE Column stats: NONE
          File Output Operator
            compressed: false
            Statistics: Num rows: 1 Data size: 8 Basic stats: COMPLETE Column stats: NONE
            table:
                input format: org.apache.hadoop.mapred.SequenceFileInputFormat
                output format: org.apache.hadoop.hive.ql.io.HiveSequenceFileOutputFormat
                serde: org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe
 
  Stage: Stage-0
    Fetch Operator
      limit: -1
      Processor Tree:
        ListSink

``` 

#### 有分区剪裁的执行计划

```sql
explain select count(*) from wangbin.demo_partition_date where datadate="2018-01-01";
Explain
STAGE DEPENDENCIES:
  Stage-1 is a root stage
  Stage-0 depends on stages: Stage-1
 
STAGE PLANS:
  Stage: Stage-1
    Map Reduce
      Map Operator Tree:
          TableScan
            alias: demo_partition_date
            Statistics: Num rows: 1394580078 Data size: 12551220224 Basic stats: COMPLETE Column stats: NONE
            Select Operator
              Statistics: Num rows: 1394580078 Data size: 12551220224 Basic stats: COMPLETE Column stats: NONE
              Group By Operator
                aggregations: count()
                mode: hash
                outputColumnNames: _col0
                Statistics: Num rows: 1 Data size: 8 Basic stats: COMPLETE Column stats: NONE
                Reduce Output Operator
                  sort order:
                  Statistics: Num rows: 1 Data size: 8 Basic stats: COMPLETE Column stats: NONE
                  value expressions: _col0 (type: bigint)
      Reduce Operator Tree:
        Group By Operator
          aggregations: count(VALUE._col0)
          mode: mergepartial
          outputColumnNames: _col0
          Statistics: Num rows: 1 Data size: 8 Basic stats: COMPLETE Column stats: NONE
          File Output Operator
            compressed: false
            Statistics: Num rows: 1 Data size: 8 Basic stats: COMPLETE Column stats: NONE
            table:
                input format: org.apache.hadoop.mapred.SequenceFileInputFormat
                output format: org.apache.hadoop.hive.ql.io.HiveSequenceFileOutputFormat
                serde: org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe
 
  Stage: Stage-0
    Fetch Operator
      limit: -1
      Processor Tree:
        ListSink
```
这里重点关注两者的 Statistics: Num rows，这里可以看到有分区剪裁的直接统计的就是这个分区的数据，根本没有去查询其他分区的数据，但是没有分区剪裁的去统计了所有的数据，也就是去查询了所有的数据

## HQL调优
HQL任务调优可以从以下几个方面进行：
1. 资源
2. HQL Join优化
3. HQL逻辑优化

### 资源
每个HQL任务都最终都将转换为MR任务，可通过调整Map/Reduce task个数及container的内存大小来提升MR任务的执行效率，以达到HQL任务调优目的；常用调优参数如下：

```sql
--调整map task数量，通过调整split大小达到调整map task个数的目的
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=128000000;
set mapred.min.split.size.per.rack=256000000;
set hive.input.format=org.apache.hadoop.hive.ql.io.CombineHiveInputFormat;

--调整reduce task数量，当HQL 存在全局计数、求和、排序及笛卡尔积时无效，默认只会生成一个 reduce
set mapreduce.job.reduces=200;

--调整container内存大小
set mapreduce.map.memory.mb=8192;
set mapreduce.reduce.memory.mb=8192;
```

### HQL Join优化
HQL转换为MR任务与Join方式有直接关系，执行效率也存在明显差异，Map Join > SMB Join > Common Join，根据业务数据实际情况，选择合适的Join方式对HQL任务效率提升较为明显；

### HQL逻辑优化
1. 根据业务需求，在编写HQL的时候，尽量使用分区剪裁及列剪裁，减少MR任务IO压力；
2. 尽量不要使用存在数据倾斜的键作为Join键，如必须使用，可将倾斜严重键值拆分出来单独Join后再进行Union All
3. 尽量减少笛卡尔积、全局排序、全局聚合函数使用，如有需要使用，可先在map段进行聚合，减少Shuffle及reduce压力
4. 使用Group By替代distinct功能
