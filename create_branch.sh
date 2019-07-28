#!/bin/bash
#拉出“FA85_r26000dev”分支

PATHROOT=$(pwd)
export PATH=$PATH:/media/hw5t/gaoyuxia/bin
BASE_URL="/media/hw5t/gaoyuxia/MIRROR/manifest.git"
BASE_XML="default.xml"
BASE_BRANCH="master"
NEWBRANCH="FA85_r26000dev"
OP=$1
PATH1="/media/hw5t/gaoyuxia/MIRROR/ST101"
PATH2="/media/hw5t/gaoyuxia/MIRROR/ST102"
PATH3="/media/hw5t/gaoyuxia/MIRROR/manifest"

#清理环境，将xml复原
function update_xml(){
	pushd ${PATH3}
	./update_xml.sh
	popd
}


#删除新建分支
function delete_new_branch(){
	pushd ${PATH1}
	./delete_new_branch.sh
    popd
    
    pushd ${PATH2}
    ./delete_new_branch.sh
    popd
}


#拉代码
function pull_code(){
	repo init -u $BASE_URL -m $BASE_XML -b $BASE_BRANCH
}

#push分支
function push_new_branch(){	
	pushd ${PATHROOT}
	if [ -e project.list ];then
		rm -rf project.list
	else
		repo list -p | tee -a project.list
		while read line
		do
			pushd $line > /dev/null
			{
			origin_name=$(git remote -v | awk '{print $1}' | head -1)
			git pull
			git push $origin_name $NEWBRANCH:$NEWBRANCH
			unset origin_name
			}&
			
			back_count=$((back_count+1))
			if [ "$back_count" == 3 ];then
				wait && echo "waiting..." && sleep 1s
				back_count=0
			fi
			popd
		done < project.list
		wait && echo "waiting..." && sleep 1s
	fi
	popd
}


#推送xml文件
function push_xml(){
	pushd ${PATHROOT}/.repo/manifests
	git add $BASE_XML
	git commit -m "modified $BASE_XML"
	git push origin HEAD:master	
	popd
}


#所有仓库拉出“FA85_r26000dev”分支
function create_branch_all(){
	update_xml
        delete_new_branch
	pull_code
	repo sync
	repo start $NEWBRANCH --all
	push_new_branch
	pushd ${PATHROOT}/.repo/manifests
	sed -i "s/revision=[A-Za-z0-9\"\"\._]*/revision=\"$NEWBRANCH\"/g" $BASE_XML
	popd
	pushd ${PATHROOT}/.repo/manifests
	push_xml
	popd	
	
}

#将XML中revision=dev修改成revision=FA85_r26000dev
function update_xml2.2(){
	pushd ${PATHROOT}/.repo/manifests
	default_revision=$(grep -w "default" $BASE_XML | awk -F' ' '{print $2}')
	readarray -t xml_array < $BASE_XML
	for line in "${xml_array[@]}"
	do
		revision_line=$(echo $line | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*")
		if [ "$default_revision" == 'revision="dev"' ];then
			echo $line | grep -aoe "project"
			if [ "$?" == 0 ];then
				#如果default行中revision=dev
				if [ "$revision_line" == 'revision="dev"' ];then
					echo $line | sed -n "s/revision=[a-zA-Z0-9\"\"\._]*/revision=\"$NEWBRANCH\"/g"p | tee -a local.xml 	
				else
					echo $line | tee -a local.xml
				fi
			else
				#将default行中revision=dev改成revision=FA85_r26000dev
				echo $line | grep -w "default" | sed -n "s/revision=[a-zA-Z0-9\"\"\._]*/revision=\"$NEWBRANCH\"/g"p | tee -a local.xml
				echo $line | grep -v "default" | tee -a local.xml
			fi
		else
			#如果default行中revision!=dev
			echo $line | grep -aoe "project"
			if [ "$?" == 0 ];then
				if [ "$revision_line" == 'revision="dev"' ];then
					echo $line | sed -n "s/revision=[a-zA-Z0-9\"\"\._]*/revision=\"$NEWBRANCH\"/g"p | tee -a local.xml
				else
					echo $line | tee -a local.xml
				fi
			else
				echo $line | tee -a local.xml
			fi	
		fi
	done
	mv local.xml $BASE_XML
}


#将revision!=dev的删除
function update_xml2(){
	pushd ${PATHROOT}/.repo/manifests
	readarray -t xml_array < $NEWBRANCH.xml
	for line in "${xml_array[@]}"
	do
		echo $line | grep -aoe "project"
		if [ "$?" == 0 ];then
			#default行中revision的值
			default_revision=$(grep -w "default" $NEWBRANCH.xml | awk -F' ' '{print $2}')
			revision_line=$(echo $line | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*")
			if [ "$default_revision" == 'revision="dev"' ];then
				#如果default=dev
				if [ "$revision_line" == 'revision="dev"' ];then
					echo $line | tee -a local.xml
				elif [ -z "$revision_line" ];then
					echo $line | tee -a local.xml
				else
					echo ""
				fi
			else
				#如果default!=dev
				if [ "$revision_line" == 'revision="dev"' ];then
					echo $line | tee -a local.xml
				else
					echo ""
				fi
			fi
		else
			echo $line | tee -a local.xml
		fi
	done
	mv local.xml $NEWBRANCH.xml
	popd
}

#所有dev分支的仓库都拉出"FA85_r26000dev”分支
function create_designate_branch(){
	update_xml
        delete_new_branch
	pull_code
	pushd ${PATHROOT}/.repo/manifests
	cp -r $BASE_XML $NEWBRANCH.xml
	popd
	update_xml2
	repo init -m $NEWBRANCH.xml
	repo sync
	repo start $NEWBRANCH --all
	push_new_branch
	update_xml2.2
	push_xml
}

#将xml中revision=dev的删除
function update_xml3(){
	pushd ${PATHROOT}/.repo/manifests
	default_line=$(grep -w "default" $NEWBRANCH.xml | awk -F' ' '{print $2}')
	readarray -t xml_array < $NEWBRANCH.xml
	for line in "${xml_array[@]}"
	do
		revision_line=$(echo $line | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*")
		if [ "$default_line" == 'revision="dev"' ];then
			#default行中revision=dev
			echo $line | grep -aoe "project"
			if [ "$?" == 0 ];then
				if [ "$revision_line" == 'revision="dev"' ];then
					echo ""
				elif [ -z "$revision_line" ];then
					echo ""
				else
					echo $line | tee -a local.xml
				fi	
			else
				echo $line | tee -a local.xml
			fi
		else	
			#如果default行中revision!=dev
			if [ "$revision_line" == 'revision="dev"' ];then
				echo ""
			else
				echo $line | tee -a local.xml
			fi
		fi	
	done
	mv local.xml $NEWBRANCH.xml
	popd
}

#修改xml中revision!=dev的revision的值
function update_xml3.3(){
	pushd ${PATHROOT}/.repo/manifests
	default_revision=$(grep -w "default" $BASE_XML | awk -F' ' '{print $2}')
	readarray -t xml_array < $BASE_XML
	for line in "${xml_array[@]}"
	do
		echo $line | grep -aoe "project"
		if [ "$?" == 0 ];then
			revision_line=$(echo $line | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*")
			if [ "$default_revision" == 'revision="dev"' ];then
				if [ "$revision_line" == 'revision="dev"' ];then
					echo $line | tee -a local.xml
				elif [ -z "$revision_line" ];then
					echo $line | tee -a local.xml
				else
					echo $line | sed -n "s/revision=[a-zA-Z0-9\"\"\._]*/revision=\"$NEWBRANCH\"/g"p | tee -a local.xml
				fi
			else
				#default行中revision!=dev
				if [ "$revision_line" == 'revision="dev"' ];then
					echo $line | tee -a local.xml
				elif [ -z "$revision_line" ];then
					echo $line | sed -n "s/revision=[a-zA-Z0-9\"\"\._]*/& revision=\"$NEWBRANCH\"/g"p | tee -a local.xml
				else
					echo $line | sed -n "s/revision=[a-zA-Z0-9\"\"\._]*/revision=\"$NEWBRANCH\"/g"p | tee -a local.xml
				fi
			fi
		else
			echo $line | tee -a local.xml
		fi	
	done
	mv local.xml $BASE_XML
	popd
}

#除了dev分支的所有仓库都拉出"FA85_r26000dev”分支
function except_designate_branch(){
	update_xml
        delete_new_branch
	pull_code
	pushd ${PATHROOT}/.repo/manifests
	cp -r $BASE_XML $NEWBRANCH.xml
	popd
	#将xml中revision=dev的删除
	update_xml3
	repo init -m $NEWBRANCH.xml
	repo sync
	repo start $NEWBRANCH --all
	push_new_branch
	#修改xml中revision!=dev的revision的值
	update_xml3.3
	push_xml
}

#将xml中path!=venus_proc&& path!=wcnss_proc全部删除
function update_xml4(){
	pushd ${PATHROOT}/.repo/manifests
	readarray -t xml_array < $NEWBRANCH.xml
	for line in "${xml_array[@]}"
	do
		echo $line | grep -aoe "project"
		if [ "$?" == 0 ];then
			path_line=$(echo $line | grep -aoe "path=[a-zA-Z0-9\"\"\._]*")
			if [ "$path_line" == 'path="venus_proc"' ] || [ "$path_line" == 'path="wcnss_proc"' ];then
				echo $line | tee -a local.xml
			else
				echo ""
			fi
		else
			echo $line | tee -a local.xml
		fi
	done
	mv local.xml $NEWBRANCH.xml
	popd	
}

#修改xml中path=venus_proc && path=wcnss_proc的revision=FA85_r26000dev
function update_xml4.4(){
	pushd ${PATHROOT}/.repo/manifests
	readarray -t xml_array < $BASE_XML
	for line in "${xml_array[@]}"
	do
		echo $line | grep -aoe "project"
		if [ "$?" == 0 ];then
			path_line=$(echo $line | grep -aoe "path=[a-zA-Z0-9\"\"\._]*")
			if [ "$path_line" == 'path="venus_proc"' ] || [ "$path_line" == 'path="wcnss_proc"' ];then
				echo $line | sed -n "s/revision=[a-zA-Z0-9\"\"\._]*/revision=\"$NEWBRANCH\"/g"p | tee -a local.xml
			else
				echo $line | tee -a local.xml
			fi
		else
			echo $line | tee -a local.xml
		fi
	done	
	mv local.xml $BASE_XML
	popd
}


#仓库venus_proc,wcnss_proc拉出“FA85_r26000dev”分支
function designated_repository(){
	update_xml
        delete_new_branch
	pull_code
	pushd ${PATHROOT}/.repo/manifests
	cp $BASE_XML $NEWBRANCH.xml
	popd
	#将xml中path!=venus_proc && path!=wcnss_proc的删除
	update_xml4
	repo init -m $NEWBRANCH.xml
	repo sync
	repo start $NEWBRANCH --all
	push_new_branch
	#修改xml中revision!=dev的revision的值
	update_xml4.4
	push_xml
}

#将xml中venus_proc，wcnss_proc仓库的行删除
function update_xml5(){
	pushd ${PATHROOT}/.repo/manifests
	cp -r $BASE_XML $NEWBRANCH.xml
	readarray -t xml_array < $NEWBRANCH.xml
	for line in "${xml_array[@]}"
	do
		echo $line | grep -aoe "project"
		if [ "$?" == 0 ];then
			path_line=$(echo $line | grep -aoe "path=[a-zA-Z0-9\"\"\._]*")
			if [ "$path_line" == 'path="venus_proc"' ] || [ "$path_line" == 'path="wcnss_proc"' ];then
				echo ""
			else
				echo $line | tee -a local.xml
			fi
		else
			echo $line | tee -a local.xml
		fi
	done
	mv local.xml $NEWBRANCH.xml
	popd
}

#修改xml中venus_proc，wcnss_proc仓库的revision=FA85_r26000dev
function update_xml5.5(){
	pushd ${PATHROOT}/.repo/manifests
	readarray -t xml_array < $BASE_XML
	for line in "${xml_array[@]}"
	do
		revision_line=$(echo $line | grep -aoe "revision=[a-zA-Z0-9\"\"\._]*")
		echo $line | grep -aoe "project"
		if [ "$?" == 0 ];then
			path_line=$(echo $line | grep -aoe "path=[a-zA-Z0-9\"\"\._]*")
			if [ "$path_line" == 'path="venus_proc"' ] || [ "$path_line" == 'path="wcnss_proc"' ];then
                                echo $line | tee -a local.xml
			elif [ -z "$revision_line" ];then
				echo $line | tee -a local.xml
                        else
                                echo $line | sed -n "s/revision=[a-zA-Z0-9\"\"\._]*/revision=\"$NEWBRANCH\"/g"p | tee -a local.xml
                        fi
		else
			echo $line | grep -w "default" | sed -n "s/revision=[a-zA-Z0-9\"\"\._]*/revision=\"$NEWBRANCH\"/g"p | tee -a local.xml
			echo $line | grep -v "default" |  tee -a local.xml
		fi
	done
	mv local.xml $BASE_XML
	popd
}


#除了venus_proc，wcnss_proc仓库，剩余仓库都拉出"FA85_r26000dev”分支
function except_designated_repository(){
	update_xml
        delete_new_branch
	pull_code
	pushd ${PATHROOT}/.repo/manifests
	cp -r $BASE_XML $NEWBRANCH.xml
	popd
	#将xml中revision=dev的删除
	update_xml5
	repo init -m $NEWBRANCH.xml
	repo sync
	repo start $NEWBRANCH --all
	push_new_branch
	#修改xml中revision!=dev的revision的值
	update_xml5.5
	push_xml
}

############ MAIN #############
function main(){
	if [ "$OP" == "create_branch_all" ];then
		create_branch_all        
	elif [ "$OP" == "create_designate_branch" ];then
		create_designate_branch
	elif [ "$OP" == "except_designate_branch" ];then
		except_designate_branch
	elif [ "$OP" == "designated_repository" ];then
		designated_repository
	elif [ "$OP" == "except_designated_repository" ];then
		except_designated_repository
	else
		echo "请输入1-5之间的数字"
	fi
}
main "$@"


