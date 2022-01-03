#!/bin/bash

#保存备份个数，备份7天数据
number=7
#备份保存路径
backup_dir=/home/mysql_backup
#日期
dd=`date +%Y-%m-%d-%H-%M-%S`
#备份工具
dumper=/usr/local/mysql/bin/mysqldump
#备份实例
socket=/tmp/mysql.sock3306
#用户名
username=mysql
#密码
password=ly.19980430
#将要备份的数据库
database_name=--all-databases

#如果文件夹不存在则创建
if [ ! -d $backup_dir ];
then
    mkdir -p $backup_dir;
fi

#备份文件名称
dest_archive=$backup_dir/$(date +%Y-%m-%d-%H.%M.%S).sql.gz

$dumper --socket=$socket -u $username -p$password --opt --default-character-set=utf8 -e --triggers -R --hex-blob --flush-logs -x $database_name| gzip -c | cat > $dest_archive


#写创建备份日志
echo "create $backup_dir/$dest_archive" >> $backup_dir/log.txt

#找出需要删除的备份
delfile=`ls -l -crt  $backup_dir/*.sql.gz | awk '{print $9 }' | head -1`

#判断现在的备份数量是否大于$number
count=`ls -l -crt  $backup_dir/*.sql.gz | awk '{print $9 }' | wc -l`

if [ $count -gt $number ]
then
  #删除最早生成的备份，只保留number数量的备份
  rm $delfile
  #写删除文件日志
  echo "delete $delfile" >> $backup_dir/log.txt
fi
