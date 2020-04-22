---
title: vsftp搭建
tags: Linux
date: 2020-04-17 17:31
---

# Vsftp搭建

VSFTP是一个基于GPL发布的类Unix系统上使用的FTP服务器软件，全称为Very Secure FTP，开发者的初衷就是安全，同时兼顾了稳定与速度；

+ 稳定：在RedHat系统下测试，可支持15000个并发；
+ 速度：在千兆网卡下下载速度可达86MB/S；



## Vsftp搭建

### 安装

```bash
yum install vsftpd
```



### 配置

#### ssh服务配置

```bash
# vi /etc/ssh/sshd_config


PasswordAuthentication	yes  # yes：允许使用密码登陆   no：只能使用公钥登陆
# 注释原有 Subsystem
# Subsystem sftp /usr/lib/openssh/sftp-server
Subsystem sftp internal-sftp   # 使用sshd的内置sftp代码，不另外启动sftp-server进程

# Match 必须位于文件末尾，否则会导致其后其他配置丢失
Match Group sftp   # 限制sftp用户组用户
	ChrootDirectory /opt/sftp/%u  #指定ftp用户的根目录
	AllowTcpForwarding no		# 不允许tcp转发
	X11Forwarding no		# 不允许图形化转发

```



#### vsftp服务配置

```bash
# /etc/vsftpd/vsftpd.conf

anonymous_enable=NO  # 禁用匿名登陆

chroot_list_enable=YES	# 仅允许用户访问自身目录
choroot_list_file=/etc/vsftpd/vsftpd.chroot_list	# 指定受限用户列表

idle_session_timeout=600	# 空闲链接超时时长

data_connection_timeout=120		#数据链接超时时长

ftpd_banner=Welcome to blah FTP service.	# 定义登陆提示语

write_enable=YES	#配置可进行写操作
```



#### Vsftp黑名单

```bash
# vi /etc/vsftpd/ftpusers
user1
user2

# vi /etc/vsftpd/vsftpd.user_list

userlist_enable=YES
userlist_deny=YES  		#YES :user_list为黑名单  NO:user_list为白名单
```



#### 用户配置

```bash
groupadd sftp  #创建ftp用户组
useradd -g sftp  -d  /opt/sftp/myftp -s /bin/false myftp  # 指定用户组为sftp  家目录为/opt/sftp/myftp  无法登陆OS
echo 'passwordstr' |passwd --stdin.  #设置用户密码为passwordstr
```



#### 目录配置

```bash
mkdir /opt/sftp   #创建ftp根目录

chown root:sftp /opt/sftp/myftp   #修改ftp用户根目录属主为root:sftp

chown 755 /opt/sftp/myftp   #修改ftp用户根目录权限为755
```



## 启动

```bash
systemctl enable vsftpd
systemctl start vsftpd

systemctl restart sshd
```



## 登陆验证

```bash
sftp  myftp@localhost
```



## 常见问题

+ `Permission denied (publickey)`

出现此类错误为OS启用了公钥验证，禁用了密码验证功能，可通过修改参数`PasswordAuthentication yes`解决。

+ `packet_write_wait: Connection to 10.173.32.51 port 22: Broken pipe`

出现此类错误为ftp配置目录权限异常导致，可参考上文目录配置进行操作；
