---
title: Hive知识体系之四
date: 2019-07-19 14:00:00
tags: Hive
---

# Hive访问方式
目前常见的有三种方式连接Hive进行操作：Cli模式、JDBC模式以及WebUI模式；


<!-- more -->

## Cli模式
Cli模式即为Command Line Interface 的缩写，是hive的命令行界面，为hive的默认服务，可直接在linux系统命令行使用；
+ 数据库直连   
该模式需$HIVE_HOME/conf/hive-site.xml中直接配置hive元数据库连接地址、驱动类、用户名及密码信息，在启动Cli时直接连接hive元数据库读取相关信息，该模式存在安全隐患，不建议采用
+ metastore Thrift服务  
通过在某节点上启动metastore Thrift服务，在启动Cli时通过metastore服务获取hive元数据库信息；该模式可避免直接对用户暴露hive元数据库敏感信息，但无法实现高可用；

```bash
# 启动metastore服务
hive --service metastore
```

## JDBC模式
JDBC模式需要依赖于HiveServer2服务，客户端可以在不启动Cli的情况下进行Hive数据操作，且允许客户端通过多种变成语言向hive提交请求，取回结果；同时，HiveServer2提供了一个新的命令行工具beeline，它是基于SQLLine Cli的JDBC客户端；在生产环境中使用Hive建议采用HiveServer2来提供服务，他具备以下好处：
+ 在应用端不用部署Hadoop和Hive客户端(通过Java、Python等操作Hive)；
+ 不用直接将HDFS和Metastore暴漏给用户；
+ 支持HA机制，可解决业务高并发和负载均衡问题；

```bash
# 启动HiveServer2服务
hive --service hiveserver2
```

### HiveServer2高可用配置
HiveServer2实现高可用，需在启动服务的主机上部署Hive客户端，并在hive-site.xml中配置一下参数：

```xml
<property>
<name>hive.server2.support.dynamic.service.discovery</name>
<value>true</value>
</property>
 
<property>
<name>hive.server2.zookeeper.namespace</name>
<value>hiveserver2_zk</value>
<description>指定ZK中的逻辑空间名称</description>
</property>
 
<property>
<name>hive.zookeeper.quorum</name>
<value> zkNode1:2181,zkNode2:2181,zkNode3:2181</value>
<description>指定ZK节点</description>
</property>
 
<property>
<name>hive.zookeeper.client.port</name>
<value>2181</value>
<description>指定ZK端口</description>
</property>
 
<property>
<name>hive.server2.thrift.bind.host</name>
<value>0.0.0.0</value>
<description>指定hiveserver2主机绑定地址</description>
</property>
 
<property>
<name>hive.server2.thrift.port</name>
<value>10001</value> 
<description>指定hiveserver2端口号，且各节点端口号需一致</description>
</property>
```

### JDBC连接的URL格式


```java
jdbc:hive2://<zookeeper quorum>/<dbName>;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2
```
其中：
\<zookeeper quorum> 为Zookeeper的集群链接串，如zkNode1:2181,zkNode2:2181,zkNode3:2181
\<dbName> 为Hive数据库，如不填写则默认可访问所有hive db
serviceDiscoveryMode=zooKeeper 指定模式为zooKeeper
zooKeeperNamespace=hiveserver2 指定ZK中的nameSpace，即参数hive.server2.zookeeper.namespace所定义


## Web UI模式
目前原生Web UI基本无用户使用，受众最广的Web UI为Hue，大型发行版厂商也会开发自己的Web UI；
### Hue
Hue是目前市面上受众最广的Hive Web UI工具，当目前Hue尚不支持Hiveserver2 HA模式的连接；

###原生Web UI
1、 下载对应版本的 src 包：apache-hive-2.3.2-src.tar.gz
2、 上传，解压

```sh
tar -zxvf apache-hive-2.3.2-src.tar.gz
```
3、 然后进入目录，执行打包命令:

```sh
cd ${HIVE_SRC_HOME}/hwi/web
jar -cvf hive-hwi-2.3.2.war *
```
在当前目录会生成一个 hive-hwi-2.3.2.war
4、 得到 hive-hwi-2.3.2.war 文件，复制到 hive 下的 lib 目录中
cp hive-hwi-2.3.2.war ${HIVE_HOME}/lib/
5、 修改配置文件 hive-site.xml
```xml
<property>
 <name>hive.hwi.listen.host</name>
 <value>0.0.0.0</value>
 <description>监听的地址</description>
</property>
<property>
 <name>hive.hwi.listen.port</name>
 <value>9999</value>
 <description>监听的端口号</description>
</property>
<property>
 <name>hive.hwi.war.file</name>
 <value>lib/hive-hwi-2.3.2.war</value>
 <description>war 包所在的地址</description>
</property>
```
6、 复制所需 jar 包

```sh
cp ${JAVA_HOME}/lib/tools.jar ${HIVE_HOME}/lib
cp commons-el-1.0.jar ${HIVE_HOME}/lib
cp jasper-compiler-5.5.23.jar ${HIVE_HOME}/lib
cp jasper-runtime-5.5.23.jar ${HIVE_HOME}/lib
```
7、 安装 ant
+ 上传 ant 包：apache-ant-1.9.4-bin.tar.gz
+ 解压 tar -zxvf apache-ant-1.9.4-bin.tar.gz -C ~/apps/
+ 配置环境变量   
       
```sh
# vi /etc/profile
export ANT_HOME=/home/hadoop/apps/apache-ant-1.9.4 
export PATH=$PATH:$ANT_HOME/bin
source /etc/profile
```
+ 验证是否安装成功  

8、启动服务

```sh
cd ${HIVE_HOME}/bin
${HIVE_HOME}/bin/hive --service hwi
```
9、 前面配置了端口号为 9999，所以这里直接在浏览器中输入: hadoop02:9999/hwi
