### 1.环境【关闭SeLinux】

```shell
[root@test41 ~]# cat /etc/redhat-release
CentOS Linux release 7.2.1511 (Core) 
  
[root@test41 ~]# uname -r
3.10.0-514.6.1.el7.x86_64
```

执行`getenforce`命令，根据Selinux的开启状态执行相应命令。

```shell
--- 如果为Disableed则直接跳过这一步
[root@test41 ~]# getenforce
Disabled
--- 如果为Enforcing则执行以下命令进行更改SeLinux的配置
[root@test41 ~]# getenforce
Enforcing
[root@test41 ~]# vim /etc/selinux/config
将文件中的 SELINUX=enforcing 更改为 SELINUX=disabled 后重启reboot
[root@test41 ~]# getenforce
Disabled
```

### 2.安装部署

* 下载合适系统的安装tar.gz包

  tbd

* 解压 MySQL 5.7 二进制包到指定目录

  ```shell
  [root@test41 ~]# tar zxvf mysql-5.7.21-linux-glibc2.12-x86_64.tar.gz -C /usr/local/
  ```

* 创建Mysql软链接

  ```shell
  [root@test43 ~]# ln -s /usr/local/mysql-5.7.21-linux-glibc2.12-x86_64/ /usr/local/mysql
  ```

* 创建 MySQL 用户

  ```shell
  [root@test43 mycat]# useradd -r -s /sbin/nologin mysql
  ```

* 在 MySQL 二进制包目录中创建 mysql-files 目录 [MySQL 数据导入/导出数据专放目录]

  ```shell
  [root@test43 mycat]# mkdir -v /usr/local/mysql/mysql-files 
  mkdir: 已创建目录 "/usr/local/mysql/mysql-files"
  ```

* 创建多实例数据目录

  ```shell
  [root@test43 mycat]# mkdir -vp /home/data/mysql_data{3306,3307}
  mkdir: 已创建目录 "/home/data"
  mkdir: 已创建目录 "/home/data/mysql_data3306"
  mkdir: 已创建目录 "/home/data/mysql_data3307"
  ```

* 修改 MySQL 二进制包目录的所属用户与所属组

  ```shell
  [root@test43 mycat]# chown root.mysql -R /usr/local/mysql-5.7.21-linux-glibc2.12-x86_64/
  ```

* 修改 MySQL 多实例数据目录与 数据导入/导出专放目录的所属用户与所属组

  ```shell
  [root@test43 mycat]# chown mysql.mysql -R /usr/local/mysql/mysql-files /home/data/mysql_data{3306,3307}
  ```

* 配置 MySQL 配置文件 /etc/my.cnf

  新建配置文件

  ```
  touch /etc/my.cnf
  ```

  打开配置文件

  ```
  vim /etc/my.cnf
  ```

  配置文件内容

  ```shell
  [mysqld_multi] 
  mysqld = /usr/local/mysql/bin/mysqld  
  mysqladmin = /usr/local/mysql/bin/mysqladmin
  log = /tmp/mysql_multi.log
  [mysqld3306] 
  # 设置数据目录　[多实例中一定要不同] 
  datadir = /home/data/mysql_data3306
  # 设置sock存放文件名　[多实例中一定要不同] 
  socket = /tmp/mysql.sock3306 
  # 设置监听开放端口　[多实例中一定要不同] 
  port = 3306   
  # 主从备份时必须指定，且唯一
  server_id = 3306
  # 行内容实时同步模式
  binlog_format = row
  log-bin = /home/data/mysql_data3306/log/mysql3306_bin
  #主主互备模式，它是为了让slave也能充当master
  log-slave-updates
  #开启慢查询
  slow_query_log = on
  long_query_time = 3  
  slow_query_log_file = /home/data/mysql_data3306/log/slow.log  
  #忽略表名称大小
  lower_case_table_names = 1
  # 设置运行用户，否则会有Security问题
  user = mysql
  # 设置模式
  sql_mode = NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
  [mysqld3307]
  # 设置数据目录　[多实例中一定要不同]
  datadir = /home/data/mysql_data3307
  # 设置sock存放文件名　[多实例中一定要不同]
  socket = /tmp/mysql.sock3307
  # 设置监听开放端口　[多实例中一定要不同]
  port = 3307
  # 主从备份时必须指定，且唯一
  server_id = 3307
  # 行内容实时同步模式
  binlog_format = row
  log-bin = /home/data/mysql_data3307/log/mysql3307_bin
  #主主互备模式，它是为了让slave也能充当master
  log-slave-updates
  #开启慢查询
  slow_query_log = on
  long_query_time = 3
  slow_query_log_file = /home/data/mysql_data3307/log/slow.log
  #忽略表名称大小
  lower_case_table_names = 1
  # 设置运行用户，否则会有Security问题
  user = mysql
  # 设置模式
  sql_mode = NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
  ```

* 初始化3306和3307数据库实例

  ```shell
  --- 初始化3306
  [root@test43 mycat]#  /usr/local/mysql/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/home/data/mysql_data3306
  2018-01-30T09:14:38.498787Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
  2018-01-30T09:14:40.399581Z 0 [Warning] InnoDB: New log files created, LSN=45790
  2018-01-30T09:14:40.607864Z 0 [Warning] InnoDB: Creating foreign key constraint system tables.
  2018-01-30T09:14:40.695008Z 0 [Warning] No existing UUID has been found, so we assume that this is the first time that this server has been started. Generating a new UUID: 008c0bbc-059e-11e8-a427-5254005af559.
  2018-01-30T09:14:40.724985Z 0 [Warning] Gtid table is not ready to be used. Table 'mysql.gtid_executed' cannot be opened.
  2018-01-30T09:14:40.728073Z 1 [Note] A temporary password is generated for root@localhost: MQpz>eTC6Ui+
  # 记住默认的密码：MQpz>eTC6Ui+
  
  --- 初始化3307
  [root@test43 mycat]#  /usr/local/mysql/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/home/data/mysql_data3307
  2018-01-30T09:16:01.063751Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
  2018-01-30T09:16:02.402416Z 0 [Warning] InnoDB: New log files created, LSN=45790
  2018-01-30T09:16:02.665665Z 0 [Warning] InnoDB: Creating foreign key constraint system tables.
  2018-01-30T09:16:02.774495Z 0 [Warning] No existing UUID has been found, so we assume that this is the first time that this server has been started. Generating a new UUID: 317861d1-059e-11e8-a776-5254005af559.
  2018-01-30T09:16:02.787990Z 0 [Warning] Gtid table is not ready to be used. Table 'mysql.gtid_executed' cannot be opened.
  2018-01-30T09:16:02.790207Z 1 [Note] A temporary password is generated for root@localhost: wiPE(CyJb4/C
  # 记住默认的密码：wiPE(CyJb4/C
  
  # 如果初始化有误，可以直接把data目录整个删除，然后重新初始化。
  ```

  ```shell
  [root@test43 mycat]# mkdir -vp /home/data/mysql_data{3306,3307}/log
  mkdir: 已创建目录 "/home/data/mysql_data3306/log"
  mkdir: 已创建目录 "/home/data/mysql_data3307/log"
  ```

* 开启SSL连接

  ```shell
  [root@test43 mycat]# /usr/local/mysql/bin/mysql_ssl_rsa_setup --user=mysql --basedir=/usr/local/mysql --datadir=/home/data/mysql_data3306 
  [root@test43 mycat]# /usr/local/mysql/bin/mysql_ssl_rsa_setup --user=mysql --basedir=/usr/local/mysql --datadir=/home/data/mysql_data3307 
  ```

* 复制多实例脚本到服务管理目录下 [ /etc/init.d/ ]

  ```shell
  [root@test43 mycat]# cp /usr/local/mysql/support-files/mysqld_multi.server /etc/init.d/mysqld_multi
  ```

* 添加脚本执行权限

  ```shell
  [root@test43 mycat]# chmod +x /etc/init.d/mysqld_multi
  ```

* 添加进service服务管理

  ```mysql
  [root@test43 mycat]# chkconfig --add mysqld_multi
  ```

* 授予权限

  ```mysql
  [root@test43 mycat]# chown mysql:mysql -R  /usr/local/mysql
  [root@test43 mycat]# chown mysql:mysql -R  /home/data
  ```

* 启动测试

  ```shell
  [root@test43 mycat]# /etc/init.d/mysqld_multi report
  ```

  ```shell
  --- 如果产生以下输出
  WARNING: my_print_defaults command not found.
  Please make sure you have this command available and in your path. The command is available from the latest MySQL distribution.
  ABORT: Can't find command 'my_print_defaults'.
  This command is available from the latest MySQL distribution. Please make sure you have the command
  --- 临时解决
  [root@localhost mycat]# export PATH=/usr/local/mysql/bin:$PATH
  --- 永久解决
  [root@localhost mycat]# cp /usr/local/mysql/bin/my_print_defaults /usr/bin/
  [root@localhost mycat]# cp /usr/local/mysql/bin/mysqld_multi /usr/bin/
  ```

  ```shell
  --- 如果是以下输出，则正常进行启动
  Reporting MySQL servers
  MySQL server from group: mysqld3306 is not running
  MySQL server from group: mysqld3307 is not running
  ```

  ```shell
  [root@test43 mycat]# /etc/init.d/mysqld_multi start
  ```

* 打开客户端

  ```shell
  [root@test43 mycat]# /usr/local/mysql/bin/mysql -S /tmp/mysql.sock3306 -uroot -p[这里填上边记住的密码,或者这里不输入,命令行提示输入]
  ```

* 修改默认密码

  ```shell
  mysql> SET PASSWORD FOR 'root'@'localhost' = PASSWORD('bs');
  ```

* 新增用户

  ```shell
  mysql> CREATE USER 'mysql'@'%' IDENTIFIED BY 'bs';
  mysql> GRANT ALL ON *.* TO 'mysql'@'%';
  mysql> flush privileges;
  ```

* 修改防火墙配置

  ```shell
  --- 打开防火墙配置文件
  [root@localhost ~]# vim /etc/sysconfig/iptables
  
  --- 加入以下配置
  -A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT
  
  --- 注意
  增加的开放3306端口的语句一定要在icmp-host-prohibited之前
  
  --- 重启防火墙
  [root@localhost ~]# service iptables restart
  
  --- 注意：当防火墙没开启外部无法访问
  查看防火墙状态：service iptables status
  开启防火墙：service iptables start
  关闭防火墙：service iptables stop
  ```

* mysqld_multi命令管理数据库

  ```shell
  mysqld_multi [OPTIONS] {start|reload|stop|report} [GNR-GNR,GNR,GNR-GNR,...]
  ```

  ```shell
  # 查看mysqld_multi状态
  [root@VM-4-4-centos ~]# mysqld_multi report
  
  # 启动所有实例
  [root@VM-4-4-centos ~]# mysqld_multi start
  
  # 关闭所有实例 my.cnf中没有配置password 在命令行中传递
  [root@VM-4-4-centos ~]# mysqld_multi --password=xx stop
  
  # 启动指定实例
  [root@VM-4-4-centos ~]# mysqld_multi start 3306
  
  # 启动1-3和3306实例
  [root@VM-4-4-centos ~]# mysqld_multi start 1-3,3306
  
  # 关闭指定实例
  [root@VM-4-4-centos ~]# mysqld_multi --password=xx stop 3306
  ```