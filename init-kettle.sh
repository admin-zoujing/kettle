#!/bin/bash
#centos7安装kettle脚本
sourceinstall=/usr/local/src/kettle
chmod -R 777 $sourceinstall
#1、时间时区同步，修改主机名
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

ntpdate ntp1.aliyun.com
hwclock --systohc
echo "*/30 * * * * root ntpdate -s ntp1.aliyun.com" >> /etc/crontab

sed -i 's|SELINUX=.*|SELINUX=disabled|' /etc/selinux/config
sed -i 's|SELINUXTYPE=.*|#SELINUXTYPE=targeted|' /etc/selinux/config
sed -i 's|SELINUX=.*|SELINUX=disabled|' /etc/sysconfig/selinux 
sed -i 's|SELINUXTYPE=.*|#SELINUXTYPE=targeted|' /etc/sysconfig/selinux
setenforce 0 && systemctl stop firewalld && systemctl disable firewalld 

rm -rf /var/run/yum.pid 
rm -rf /var/run/yum.pid


#一、创建用户
cd $sourceinstall
groupadd kettle
useradd -r -g kettle kettle -s /bin/sh -d /home/kettle -m

#二、安装jdk
cd $sourceinstall
mkdir /usr/local/java
tar -zxvf jdk-8u144-linux-x64.tar.gz -C /usr/local/java
cat > /etc/profile.d/java.sh <<EOF
export JAVA_HOME=/usr/local/java/jdk1.8.0_144
export JRE_HOME=/usr/local/java/jdk1.8.0_144/jre
export JAVA_BIN=\$JAVA_HOME/bin
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH
EOF
source /etc/profile.d/java.sh
java -version

#三、下载并解压安装包
cd $sourceinstall
unzip pdi-ce-8.2.0.0-342.zip -d /usr/local
chown -R kettle.kettle /usr/local/data-integration 
cd /usr/local/data-integration
chmod 755 *.sh

#四、安装mysql、sqlserver、oracle驱动
#Orcale驱动下载地址：https://www.oracle.com/technetwork/cn/database/features/jdbc/index-093096-zhs.html
#Sqlserver驱动下载地址：https://docs.microsoft.com/en-us/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server?view=sql-server-2017
#Mysql驱动下载地址：https://dev.mysql.com/downloads/connector/j/5.1.html
cd $sourceinstall
cp mysql-connector-java-5.1.47.jar /usr/local/data-integration/lib/ 
cp sqljdbc42.jar /usr/local/data-integration/lib/ 
cp ojdbc5.jar /usr/local/data-integration/lib/ 
cp ojdbc6.jar /usr/local/data-integration/lib/ 
chown -R kettle.kettle /usr/local/data-integration 


#五、测试安装是否成功
su - kettle
cd  /usr/local/data-integration
./kitchen.sh      #若出现帮助信息,证明安装成功
./spoon.sh  &     #启动


#1、Could not load SWT library. Reasons 没安装 SWT library，需要安装SWT库
#yum -y install gtk2.i686 gtk2-engines.i686 PackageKit-gtk-module.i686 PackageKit-gtk-module.x86_64 libcanberra-gtk2.x86_64 libcanberra-gtk2.i686

#2、No more handles [gtk_init_check() 没有安装图形化界面
#yum -y install "GNOME Desktop"