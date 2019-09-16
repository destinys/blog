---
title: Hive知识体系之二
date: 2019-07-19 12:00:00
tags: Hive
---


# Hive常见配置参数说明
Hive默认配置文件为HIVE_HOME/conf/hive-site.xml，一般下载apache原生Hive安装包，在该目录下默认提供了hive-site.xml.template文件，可直接将该文件重命名后，根据实际业务情况对相关参数进行调整；

<!-- more -->

## Hive Metadata相关

目前市场上Hive集群基本都是使用泛Mysql数据库存储Hive的Metadata信息，相关参数主要用于配置数据库主机地址、用户名、密码等信息；

*javax.jdo.option.ConnectionURL*：配置Hive元数据库链接信息

```xml
<name>javax.jdo.option.ConnectionURL</name>
<value>jdbc:mysql://192.168.76.100:3306/hive?createDatabaseIfNotExist=true</value>
<description>配置mysql的jdbc连接串信息</description>
</property>
```

*javax.jdo.option.ConnectionDriverName*：配置链接Hive元数据库驱动类

```xml
<property>
<name>javax.jdo.option.ConnectionDriverName</name>
<value>com.mysql.jdbc.Driver</value>
<description>指定mysql jdbc链接驱动</description>
</property>
```

*javax.jdo.option.ConnectionUserName*：配置链接Hive元数据库用户名

```xml
<property>
<name>javax.jdo.option.ConnectionUserName</name>
<value>root</value>
<description>指定mysql对应数据库登陆用户名</description>
</property>
```

*javax.jdo.option.ConnectionPassword*：配置链接Hive元数据库密码

```xml
<property>
<name>javax.jdo.option.ConnectionPassword</name>
<value>123</value>
<description>指定mysql对应数据库登陆密码</description>
</property>
```

*javax.jdo.option.Multithreaded*：配置是否支持并发访问metastore

```xml
<property>
<name>javax.jdo.option.Multithreaded</name>
<value>true</value>
<description>默认值为true</description>
</property>
```

*hive.metastore.local*：配置metastore服务与元数据库主机是否保持一致

```xml
<property>
<name>hive.metastore.local</name>
<value>true</value>
<description>当配置为true时，metastore服务于元数据库处于同一台主机</description>
</property>
```

*hive.metastore.uris*：配置metastore服务访问地址

```xml
<property>
<name>hive.metastore.uris</name>
<value>thrift://192.168.1.188:9083</value>
<description>指定非metastore服务宿主机访问metastore的地址，主要用于客户端主机配置，防止元数据库信息泄露</description>
</property>
```

*hive.metastore.connect.retries*：配置创建metastore链接时重试次数

```xml
<property>
<name>hive.metastore.connect.retries</name>
<value>5</value>
<description>默认值为5</description>
</property>
```

*hive.metastore.client.connect.retry.delay*：配置重试间隔时间

```xml
<property>
<name>hive.metastore.client.connect.retry.delay</name>
<value>1</value>
<description>默认值为1秒</description>
</property>
```

*hive.metastore.client.socket.timeout*：配置metastore链接超时时间

```xml
<property>
<name>hive.metastore.client.socket.timeout</name>
<value>20</value>
<description>默认值为20秒</description>
</property>
```


*hive.metastore.ds.retry.attempts*：配置出现错误时，自动重试次数

```xml
<property>
<name>hive.metastore.ds.retry.attempts</name>
<value>1</value>
<description>默认值为1次</description>
</property>
```


*hive.metastore.ds.retry.interval*：配置出现错误时，自动重试间隔

```xml
<property>
<name>hive.metastore.ds.retry.interval</name>
<value>1000</value>
<description>默认值为1000毫秒</description>
</property>
```


**Hiveserver2相关：**
*hive.server2.thrift.port*：配置hiveserver2服务端口


```xml
<property>
<name>hive.server2.thrift.port</name>
<value>10000</value>
<description>默认值为10000</description>
</property>
```

*hive.server2.thrift.bind.host*：配置hiveserver2服务主机IP
```xml
<property>
<name>hive.server2.thrift.bind.host</name>
<value>192.168.1.100</value>
<description>指定hiveserver2所在主机ip地址</description>
</property>
```

*hive.metastore.server.min.threads*:配置thrift服务池最小线程数

```xml
<property>
<name>hive.metastore.server.min.threads</name>
<value>200</value>
<description>默认值为200</description>
</property>
```

*hive.metastore.server.max.threads*：配置thrift服务池最小线程数

```xml
<property>
<name>hive.metastore.server.max.threads</name>
<value>100000</value>
<description>默认值为200</description>
</property>
```

*hive.metastore.server.tcp.keepalive*：配置是否开启长连接

```xml
<property>
<name>hive.metastore.server.tcp.keepalive</name>
<value>true</value>
<description>默认值为true</description>
</property>
```

**Hiveserver2安全相关：**
*hive.metastore.sasl.enabled*：配置metastore thrift接口安全策略

```xml
<property>
<name>hive.metastore.sasl.enabled</name>
<value>false</value>
<description>默认值为false</description>
</property>
```

*hive.metastore.kerberos.keytab.file*：配置开启安全策略后，keytab默认存储路径

```xml
<property>
<name>hive.metastore.kerberos.keytab.file</name>
<value>false</value>
<description>默认值为空</description>
</property>
```

*hive.metastore.kerberos.principal*：配置kerberos默认principal，_HOST会动态替换

```xml
<property>
<name>hive.metastore.kerberos.principal</name>
<value>hive-metastore/_HOST@EXAMPLE.COM</value>
<description>默认值为hive-metastore/_HOST@EXAMPLE.COM</description>
</property>
```

**Hiveserver2 高可用相关：**
*hive.server2.support.dynamic.service.discovery*：配置启用hiveserver2的HA

```xml
<property>
<name>hive.server2.support.dynamic.service.discovery</name>
<value>true</value>
<description>默认值为false</description>
</property>
```

*hive.zookeeper.quorum*：配置高可用zk列表

```xml
<property>
<name>hive.zookeeper.quorum</name>
<value>zkNode1:2181,zkNode2:2181,zkNode3:2181</value>
<description>默认值为空</description>
</property>
```

*hive.zookeeper.client.port*：配置高可用zk监听端口

```xml
<property>
<name>hive.zookeeper.client.port</name>
<value>2181</value>
<description>默认值为2181</description>
</property>
```

*hive.zookeeper.namespace*：配置高可用zk父节点

```xml
<property>
<name>hive.zookeeper.namespace</name>
<value>hive_zookeeper_namespace</value>
<description>默认值为hive_zookeeper_namespace</description>
</property>
```

*hive.zookeeper.session.timeout*：配置ZK超时时长

```xml
<property>
<name>hive.zookeeper.session.timeout</name>
<value>600000</value>
<description>默认值为600000</description>
</property>
```

## Hive数据存储相关

*hive.metastroe.warehouse.dir*：配置数据仓库的位置

```xml
<property>
<name>hive.metastroe.warehouse.dir</name>
<value>600000</value>
<description>默认是/user/hive/warehouse</description>
</property>
```

*hive.default.fileformat*：配置CREATE TABLE语句的默认文件格式

```xml
<property>
<name>hive.default.fileformat</name>
<value>TextFile</value>
<description>默认TextFile，其他可选的有SequenceFile、RCFile还有Orc</description>
</property>
```

*hive.files.umask.value*：hive创建文件夹时的dfs.umask值；

```xml
<property>
<name>hive.files.umask.value</name>
<value>0002</value>
<description>默认是0002</description>
</property>
```

## Hive MR相关

*hive.exec.mode.local.auto*：是否由hive决定自动在local模式下运

```xml
<property>
<name>hive.exec.mode.local.auto</name>
<value>false</value>
<description>默认是false</description>
</property>
```


*hive.mapred.mode*：hive操作执行时的模式

```xml
<property>
<name>hive.mapred.mode</name>
<value>nonstrict</value>
<description>默认是nonstrict非严格模式，如果是strict模式，很多有风险的查询会被禁止运行，比如笛卡尔积的join和动态分区</description>
</property>
```

*hive.map.aggr*：map端聚合是否开启

```xml
<property>
<name>hive.map.aggr</name>
<value>true</value>
<description>默认开启</description>
</property>
```


*hive.exec.compress.output*：配置mapreduce任务最终输出结果是否压缩

```xml
<property>
<name>hive.exec.compress.output</name>
<value>false</value>
<description>默认关闭，但是一般会开启为true，可节省存储，在不考虑cpu压力的时候会提高io</description>
</property>
```

*mapreduce.output.fileoutputformat.compress.codec*：指定mr输出文件压缩格式

```xml
<property>
<name>mapreduce.output.fileoutputformat.compress.codec</name>
<value>org.apache.Hadoop.io.compress.LzoCodec</value>
<description>本参数再mapred-site.xml中配置，可选列表在core-site中配置</description>
<!--默认可选列表为org.apache.hadoop.io.compress.GzipCodec,
org.apache.hadoop.io.compress.DefaultCodec,
org.apache.hadoop.io.compress.BZip2Codec,
org.apache.hadoop.io.compress.SnappyCodec-->
</property>
```


*hive.exec.compress.intermediate*：配置mapreduce任务输出的中间结果数据是否进行压缩

```xml
<property>
<name>hive.exec.compress.intermediate</name>
<value>false</value>
<description>默认关闭，集群CPU资源充足的情况下建议开启</description>
</property>
```

*hive.intermediate.compression.codec*：在上个参数设置为true时，用于指定压缩格式

```xml
<property>
<name>hive.intermediate.compression.codec</name>
<value>org.apache.Hadoop.io.compress.LzoCodec</value>
<description>可选列表在core-site中配置</description>
</property>
```

*hive.exec.max.created.files*：配置单个mapreduce作业能创建的HDFS文件最大数

```xml
<property>
<name>hive.exec.max.created.files</name>
<value>100000</value>
<description>默认是100000</description>
</property>
```

*hive.merge.mapfiles*：配置仅有map任务的作业是否在结束时合并小文件

```xml
<property>
<name>hive.merge.mapfiles</name>
<value>true</value>
<description>默认为true</description>
</property>
```

*hive.merge.mapredfiles*：配置mapreduce作业结束时是否合并小文件

```xml
<property>
<name>hive.merge.mapredfiles</name>
<value>false</value>
<description>默认为false</description>
</property>
```

*hive.merge.size.per.task*：配置启用小文件合并时，合并后文件的大小

```xml
<property>
<name>hive.merge.size.per.task</name>
<value>256000000</value>
<description>默认为256MB</description>
</property>
```

*hive.merge.smallfiles.avgsize*：在作业输出文件小于该值时，起一个额外的map/reduce作业将小文件合并为大文件，小文件的基本阈值，设置大点可以减少小文件个数，需要mapfiles和mapredfiles为true；
```xml
<property>
<name>hive.merge.smallfiles.avgsize</name>
<value>16000000</value>
<description>默认为16MB</description>
</property>
```

*mapred.reduce.tasks*：配置mapreduce任务的reduce任务个数，新版本该参数已更改为mapreduce.job.reduces

```xml
<property>
<name>mapred.reduce.tasks</name>
<value>1</value>
<description>默认为1</description>
</property>
```

*hive.exec.reducers.bytes.per.reducer*：配置单个reduce任务处理可处理数据量

```xml
<property>
<name>hive.exec.reducers.bytes.per.reducer</name>
<value>1000000000</value>
<description>默认为1G</description>
</property>
```

*hive.exec.reducers.max*：配置单个mapreduce任务reducer的最大个数，如果在mapred.reduce.tasks设置为负值，那么hive将取该值作为reducers的最大可能值。当然还要依赖（输入文件大小/hive.exec.reducers.bytes.per.reducer）所得出的大小，取其小值作为reducer的个数

```xml
<property>
<name>hive.exec.reducers.max</name>
<value>999</value>
<description>默认为999</description>
</property>
```

*hive.fileformat.check*：配置加载数据文件时是否校验文件格式

```xml
<property>
<name>hive.fileformat.check</name>
<value>true</value>
<description>默认为999</description>
</property>
```

*hive.groupby.skewindata*：group by操作是否允许数据倾斜，当设置为true时，执行计划会生成两个map/reduce作业，第一个MR中会将map的结果随机分布到reduce中，达到负载均衡的目的来解决数据倾斜

```xml
<property>
<name>hive.groupby.skewindata</name>
<value>false</value>
<description>默认为false</description>
</property>
```


*hive.groupby.mapaggr.checkinterval*：map端做聚合时，group by 的key所允许的数据行数，超过该值则进行分拆为多个job，默认是100000；

```xml
<property>
<name>hive.groupby.mapaggr.checkinterval</name>
<value>100000</value>
<description>默认为100000</description>
</property>
```


*hive.mapred.local.mem*：配置本地模式时，mapreduce任务的内存使用上限；

```xml
<property>
<name>hive.mapred.local.mem</name>
<value>0</value>
<description>默认为0，即无限制</description>
</property>
```


*hive.mapjoin.followby.map.aggr.hash.percentmemory*：map端聚合时hash表的内存占比，该设置约束group by在map join后进行，否则使用hive.map.aggr.hash.percentmemory来确认内存占比，默认值0.3；

```xml
<property>
<name>hive.mapjoin.followby.map.aggr.hash.percentmemory</name>
<value>0</value>
<description>默认为0，即无限制</description>
</property>
```

## MR优化
*hive.optimize.cp*：配置是否启用列裁剪，当启用列剪裁时，查询只读取用到的列，这个是个有用的优化；

```xml
<property>
<name>hive.optimize.cp</name>
<value>true</value>
<description>默认为true</description>
</property>
```

*hive.optimize.skewjoin*：配置是否开启数据倾斜的join优化，一般结合hive.skewjoin.key使用

```xml
<property>
<name>hive.optimize.skewjoin</name>
<value>false</value>
<description>默认为true</description>
</property>
```

*hive.skewjoin.key*：配置判断数据倾斜的阈值，如果在join中发现同样的key超过该值则认为是该key是倾斜的join key；

```xml
<property>
<name>hive.skewjoin.key</name>
<value>100000</value>
<description>默认为100000</description>
</property>
```

*hive.skewjoin.mapjoin.map.tasks*：配置处理数据倾斜的map join的map数量上限

```xml
<property>
<name>hive.skewjoin.mapjoin.map.tasks</name>
<value>10000</value>
<description>默认为10000</description>
</property>
```

*hive.skewjoin.mapjoin.min.split*：配置map join最小数据切分大小，该参数要结合上面的参数共同使用来进行细粒度的控制；

```xml
<property>
<name>hive.skewjoin.mapjoin.min.split</name>
<value>33554432</value>
<description>默认为32mb</description>
</property>
```

*hive.exec.parallel*：配置hive的执行job是否并行执行，在很多操作如join时，子查询之间并无关联可独立运行，这种情况下开启并行运算可以大大加速；

```xml
<property>
<name>hive.exec.parallel</name>
<value>false</value>
<description>默认为false</description>
</property>
```

*hvie.exec.parallel.thread.number*：配置任务最大并行数；

```xml
<property>
<name>hvie.exec.parallel.thread.number</name>
<value>8</value>
<description>默认为8</description>
</property>
```

*hive.auto.convert.join*：根据输入文件的大小决定是否将普通join转换为mapjoin的一种优化；

```xml
<property>
<name>hive.auto.convert.join</name>
<value>false</value>
<description>默认为false</description>
</property>
```

*hive.mapjoin.smalltable.filesize*：输入表文件的mapjoin阈值，如果输入文件的大小小于该值，则试图将普通join转化为mapjoin；

```xml
<property>
<name>hive.mapjoin.smalltable.filesize</name>
<value>25000000</value>
<description>默认为25mb</description>
</property>
```


*hive.mapred.reduce.tasks.speculative.execution*：reduce任务推测执行是否开启；

```xml
<property>
<name>hive.mapred.reduce.tasks.speculative.execution</name>
<value>true</value>
<description>默认为true</description>
</property>
```


## Hive 动态分区

*hive.exec.dynamic.partition*：配置Hql是否启用动态分区

```xml
<property>
<name>hive.exec.dynamic.partition</name>
<value>false</value>
<description>默认为false</description>
</property>
```


*hive.exec.dynamic.partition.mode*：配置动态分区模式，模式分为strict和nostrict，strict模式要求出现多级分区时，第一级分区必须为静态分区，而nostrict则所有层级分区均可为动态分区；

```xml
<property>
<name>hive.exec.dynamic.partition.mode</name>
<value>strict</value>
<description>默认为strict</description>
</property>
```

*hive.exec.max.dynamic.partitions*：配置单个任务可创建动态分区个数上限

```xml
<property>
<name>hive.exec.max.dynamic.partitions</name>
<value>1000</value>
<description>默认为1000</description>
</property>
```


*hive.exec.max.dynamic.partitions.pernode*：每个mapper/reducer节点可以创建的最大动态分区数，默认100；

```xml
<property>
<name>hive.exec.max.dynamic.partitions.pernode</name>
<value>1000</value>
<description>默认为1000</description>
</property>
```

*hive.exec.default.partition.name*：当动态分区启用时，配置数据列里包含null或者空字符串的分区名称；

```xml
<property>
<name>hive.exec.default.partition.name</name>
<value>__HIVE_DEFAULT_PARTITION__</value>
<description>默认为__HIVE_DEFAULT_PARTITION__</description>
</property>
```



## Hive QL
*hive.exec.drop.ignorenoneexistent*：配置删除不存在的hive表时是否报错

```xml
<property>
<name>hive.exec.drop.ignorenoneexistent</name>
<value>true</value>
<description>默认为true</description>
</property>
```

*hive.variable.substitute*：配置是否支持变量替换，如果开启的话，支持语法如${var} ${system:var}和${env.var}；

```xml
<property>
<name>hive.variable.substitute</name>
<value>true</value>
<description>默认为true</description>
</property>
```

*hive.limit.row.max.size*：配置最小采样记录数；

```xml
<property>
<name>hive.limit.row.max.size</name>
<value>100000</value>
<description>默认为100000</description>
</property>
```

*hive.limit.optimize.limit.file*：配置最大采样样本文件数；

```xml
<property>
<name>hive.limit.optimize.limit.file</name>
<value>10</value>
<description>默认为10</description>
</property>
```

*hive.limit.optimize.fetch.max*：配置limit语句返回最大记录数；

```xml
<property>
<name>hive.limit.optimize.fetch.max</name>
<value>5000</value>
<description>默认为5000</description>
</property>
```



*hive.autogen.columnalias.prefix.label*：配置查询结果默认列名前缀；

```xml
<property>
<name>hive.autogen.columnalias.prefix.label</name>
<value>_c</value>
<description>默认为_c</description>
</property>
```


*hive.cli.print.header*：配置cli执行HQL时是否显示列名；

```xml
<property>
<name>hive.cli.print.header</name>
<value>false</value>
<description>默认为false</description>
</property>
```


*hive.cli.print.current.db*：配置cli中是否显示当前数据库名

```xml
<property>
<name>hive.cli.print.current.db</name>
<value>false</value>
<description>默认为false</description>
</property>
```

更过配置参数可查阅官方文档：https://cwiki.apache.org/confluence/display/Hive/Configuration+Properties

