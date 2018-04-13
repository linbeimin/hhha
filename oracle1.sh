#!/bin/bash
#定义函数
editenv(){
#进入tester的根目录
	cd /home/tester
	#向文件中插入内容
	sed -i "10aORACLE_BASE=/oracle" .bash_profile
	sed -i '11aORACLE_HOME=$ORACLE_BASE/product/10.2.0/db_1' .bash_profile
	sed -i "12aORACLE_SID=orcl" .bash_profile
	sed -i '13aPATH=$PATH:$HOME/bin:$ORACLE_HOME/bin' .bash_profile
	sed -i '14aLD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib' .bash_profile
	sed -i "15aexport ORACLE_BASE" .bash_profile
	sed -i "16aexport ORACLE_HOME" .bash_profile
	sed -i "17aexport ORACLE_SID" .bash_profile
	sed -i "18aexport PATH" .bash_profile
	sed -i "19aexport LD_LIBRARY_PATH" .bash_profile
	#更新文件
	source ./.bash_profile
	#判断环境变量是否修改成功
	if [ "$ORACLE_BASE" == "/oracle" ]
	then
		echo "环境变量修改成功"
	else
		echo "环境变量修改失败"
	fi 
}
#定义函数
createdir(){
	mydir="/oracle/product/10.2.0/db_1"
	#创建目录
	mkdir -p $mydir
	#判断目录是否存在
	if [ -d "$mydir" ]
	then
		echo "目录创建成功"
		#修改目录的所属组和拥有者
		chown -R tester.oinstall /oracle
		#修改文件的执行权限
		chmod 755 -R /oracle
		#调用修改环境变量函数
		editenv
	else
		echo "目录创建失败"
	fi

}
#定义函数
createuser(){
	#创建用户
	useradd tester -g oinstall -G dba
	#判断
	test=`grep "tester" /etc/passwd|cut -d ":" -f 1`
	if [ "$test" == "tester" ]
	then
		echo "用户创建成功"
		#修改密码
		passwd tester
		#密码修改成功
		echo "密码修改成功"
		#调用创建目录函数
		createdir
	else
		echo "用户创建失败"
	fi	

}
#定义函数
creategrp(){
	 #创建dba
	groupadd dba
	#判断是否创建成功
	#在group文件中将dba剪取
	db=`grep "dba" /etc/group|cut -d ":" -f 1`
	
	if [ "$db" == "dba" ]
	then
		echo "dba创建成功"
		#创建oinstall
		groupadd oinstall
		#判断
		oin=`grep "oinstall" /etc/group|cut -d ":" -f 1`
		if [ "$oin" == "oinstall" ]
		then
			echo "oinstall组创建成功"
			#调用函数
			createuser
		else
			echo "oinstall组创建失败"
		fi
	else
		echo "创建失败"
	fi

}
#进行判断
if [ "$USER" == "root" ]
then
	echo "当前用户为root,进行下一步"
	#调用函数
	creategrp
else
	echo "不是root,请切换用户"
fi
