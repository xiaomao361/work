#!/bin/bash
# func: pull code and run oem project container
# date: 2018-01-03
# author: zhouwei
# email: xiaoamo361@163.com

script_home=/home/tongxin/txcloud
project_name=$1

# check input
if [[ "$1" == "" ]]; then
	echo "need input the project name { ecs|api|rds }"
	exit 1
fi

# check the user
if [ $(id -u) -ne 0 ]; then
	echo "need root"
	echo "use sudo ./deploy.sh"
	exit 1
fi

# pull code
su - tongxin -c "cd $script_home/$project_name&&git pull origin master"
if [ $? -ne 0 ]; then
	echo "code pull error"
	exit 1
fi

# check the home path
if [ $(pwd)!=="$script" ]; then
	cd $script_home
fi

# docker-compose build and up
docker-compose build ${project_name}
if [ $? -eq 0 ]; then
	docker-compose scale ${project_name}=1
	docker-compose stop ${project_name}
	docker-compose rm -f ${project_name}
	docker-compose up -d ${project_name}
	if [ "${project_name}" == "api" ]; then
		docker-compose scale ${project_name}=3
	fi
	$script_home/app_scale.sh ${project_name}
else
	echo "docker-compose build base error"
fi
