---
title: Hive知识体系之九
date: 2019-07-19 19:00:00
tags: Hive
---

# Troubleshooting
在进行hive相关的问题排查的时候，我们首先需要了解一条hive语句从提交到最终执行结束，会经过哪些阶段，不同的阶段可能会抛出哪些异常；这样就可以根据执行日志定位错误发生阶段，进而查看对应阶段详细日志定位错误原因；

<!-- more -->


一个HQL任务，整体上可以分为两个部分，Hive阶段和Hadoop阶段，如下图 ：
{% asset_img 15538391160636.jpg HQL任务框架 %}
## Hive阶段
Hive阶段对HQL进行解析、编译、优化、执行；主要包括驱动器、解析器、编译器、优化器和执行器
{% asset_img 15541882205944.jpg HQL-Hive阶段 %}

+ 驱动器：与用户进行交互，接收用户提交的HQL及获取执行器返回结果给用户；此阶段常见错误为：
    + `java heap space`：该异常一般为用户HQL访问的表元数据过大(表分区过多或表对应文件数据过多)，可通过调整HQL进行分区剪裁等减小驱动器压力或加大hive客户端内存解决；详细日志为hiveserver.log；
+ 解析器：对驱动器传递过来的HQL进行语法校验解析，解析通过后，将HQL传递给编译器；此阶段常见错误为：
    + `SemanticException`：该异常一般为用户SQL编写错误，根据异常后接关键字信息进行HQL检查修正即可；详细日志为hiveserver.log
    + `MetaException`：该异常一般为用户编写的HQL中来源表的元数据存在问题导致，可通过修正HQL访问数据表及字段解决；详细日志为Metastore.log
+ 编译器：将解析完成的HQL生成逻辑执行计划，此阶段一般不会抛出异常；
+ 优化器：对编译器生成的执行计划进行优化，此阶段一般不会抛出异常；
+ 执行器：对优化器产出的执行计划转化为物理执行计划，并提交至具体计算引擎进行计算，此阶段抛出异常均为RuntimeException，对应子异常需到具体计算引擎日志中查看；
    + MR引擎：可根据hiveserver中记录application_Id到jobhistory中查看详细日志；
    + Spark引擎：可根据hiveserver中记录application_Id到sparkhistory中查看详细日志

## Hadoop阶段
目前主流使用Hive on MR进行HQL任务执行，在Hadoop阶段主要分为map、shuffle和reduce；
MR任务资源调度流程如下图：
{% asset_img 15540995551939.jpg MR资源调度流程 %}

+ Client会将物理执行计划发送给RM；
+ RM向某个NM发送请求，创建AM；
+ AM启动成功后，想RM进行注册；
+ RM响应AM注册，并返回资源分配列表；
+ AM根据资源列表请求对应NM启动container；
+ AM定时通过RPC协议请求NM反馈对应container状态；
+ AM监控container任务执行结束后(正常或异常)，向NM请求释放资源；
+ AM监控所有container都成功结束后，向RM请求退出；

MR任务工作原理如下图：
{% asset_img 15541737167219.jp MR任务原理 %}

+ MAP阶段
    + hdfs根据hive表指定Serde读取数据（并根据split大小对block进行切分）
    + map加载split数据进入环形缓冲区
    + 当环形缓冲区使用达到阈值时，将环形缓冲区中数据进行分区及分区内排序并溢写成spill文件至磁盘；（默认分区原理为对hash算法后key值按照reduce数量取模，目的为将数据均衡分布至各个reduce端）
    + 所有数据均溢写为spill文件后，当spill文件书大于1时，将启用merge操作，将所有spill文件归并为一个文件；归并操作的原理为：假设spill1文件存在{"a",1},spill2文件中存在{"a":2}，那么归并后结果为{"a",[1,2]}
+ REDUCE阶段
    + 通过fetcher将map端归并后的文件按照对应分区拉取至reduce端内存缓冲区中
    + 将拉取过来的数据进行归并操作，并根据内存缓冲区阈值将数据溢写到磁盘（最后一次归并的结果将直接传递给reduce函数，不再溢写至磁盘，减少IO操作，节省时间）；
    + 在数据拉取过程中，会同时启动后台线程进行溢写文件合并，最终形成一个文件(如数据量较小，可能不会生成磁盘溢写文件)；
    + 内存中最后结果与磁盘溢写文件数据传递给reduce函数进行计算，生成最终结果，写入HDFS（每个reduce生成一个HDFS文件）；

在以上过程中常见错误有：
+ AM异常退出：一般为AM内存不足导致，可通过参数set yarn.app.mapreduce.am.resource.mb = xxxx修改am默认内存大小；
+ container内存不足：一般为该container对应任务处理数据量过大导致，可根据该container执行的任务调整对应参数解决，map任务调整参数为 set mapreduce.map.memory.mb=xxxx； set mapreduce.map.java.opts="-Xmx7200m"；其中xxxx和7200需根据实际情况替换为合适的数值；
+ AM与container连接超时：当MR任务处理数据量耗时较长超出默认超时时间时，会导致MR任务抛出timeout异常，可通过设置set  mapreduce.task.timeout=120000修改默认超时时间
+ 数据倾斜：当Hive任务处理的数据出现大量重复数据时，将会导致MR出现数据倾斜，表现症状为大量Reduce task耗时很短，剩下少量task一直不能结束，解决措施如下：
    + HQL优化：将较多重复值数据与其他数据拆分分别处理，然后将结果进行union all
    + 参数优化：通过设置set hive.groupby.skewindata=true进行多级MR处理以及hive.map.aggr = true启用map段数据合并优化；


## 错误排查
错误排查的最为基础的手段为查看对应日志，与Hive任务相关的日志一共有三类，hiveserver日志、metastore日志以及yarn日志；
错误排查步骤为：
* 问题定界：确定问题发生在哪个阶段-客户端、HiveServer、Metastore及MR
    * code=1：job提交失败，异常堆栈信息一般在hiveserver日志中；
    * code=2：一般在mr阶段抛出RuntimeException异常，异常堆栈信息在可根据job_id到job history中查找；
    * code=3：一般为在mr任务结束时，将文件从临时路径想最终路径移动时抛出；常见为动态分区任务或MR任务结束时抛出；
    * code=5：加载job创建临时文件夹时失败；
* 问题定位：
    * 查看hiveserver日志，根据任务关键信息搜索对应日志；
    * 查看对应日志中报错信息关键字，分析问题定界，前往对应阶段日志查找详细堆栈信息；    
    
    
