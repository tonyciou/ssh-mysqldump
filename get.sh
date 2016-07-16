#!/bin/sh

###### necessary configuration
ssh_user='foo'
ssh_hostname='localhost'
ssh_port='22'
ssh_key=''
remote_db_user_name='foo'
remote_db_user_pwd='foo'
remote_db_name='foo'
###### necessary configuration

current_time="$(date +'%Y%m%d%H%M%S')"
dump_file_name="$remote_db_name"_"$current_time".sql
download_file_name="$dump_file_name".gz

ssh_params=$ssh_user@$ssh_hostname
scp_params="-P $ssh_port $ssh_params"
ssh_params="-p $ssh_port $ssh_params"

if [ "$ssh_key" = "" ]; then
	echo "without ssh key."
else 
	if [ ! -e $ssh_key ]; then
		echo "ssh key not found!"
		exit 0;
	fi
	echo "ssh key be used."
	scp_params="-i $ssh_key $scp_params"
	ssh_params="-i $ssh_key $ssh_params"
fi 

#via ssh dump sql file
echo "===> Dumping..."
ssh $ssh_params "MYSQL_PWD=$remote_db_user_pwd; mysqldump -u $remote_db_user_name -p\$MYSQL_PWD $remote_db_name > $dump_file_name; gzip $dump_file_name"
echo "===> Done."

#get sql file from remote hosta
echo "===> Downloading..."
scp $scp_params:~/$download_file_name .
echo "===> Done."

echo "===> Deleting..."
ssh $ssh_params "rm -f $download_file_name"
echo "===> Done."
