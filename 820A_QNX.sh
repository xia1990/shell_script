#!/bin/bash -x
#!/usr/bin/expect

#########################################
#$PROJECT:项目名称						
#$BRANCH:分支名称						
#$$LUNCH:编译生成的lunch
#$TYPE:要编译的版本类型					
#########################################

PATH=~/rar:$PATH
PATHROOT=$(pwd)
Date=`date +%Y%m%d`
PROJECT=820A_QNX
Ftp_PATCH="./Qualcomm/8996/820A_QNX/"
BRANCH=820a_qnx_dev
TYPE=USERDEBUG
LUNCH=msm8996_gvmq_userdebug
#传入当前版本号
old_version=$1

#cd ../../../../../tmp/
#rm -rf *
#cd -


function clean_code(){
	if [ -d $PROJECT ] ;then
        pushd $PROJECT
        	rm  -rf  SCM_COPY_FILES
            	git clean -fd
           	git reset --hard HEAD 
            	git checkout $BRANCH
            	git pull origin $BRANCH >>log.txt
		if [ -s log.txt ] && [ -z log.txt ];then
			git pull origin $git_branch >>log.txt
		fi
            	#VAR=`strings log.txt | grep -i Already |awk -F' ' 'NR==1 {print $1}'` 
            	if [ "$VAR" = "Already" ] ; then
            		echo "**********git pull null**********"
               		exit
            	fi
            	if [ $? -ne 0 ] ; then
               		echo "**********git update error**********"
               		exit 1
            	fi
      	popd 
	else
		repo init -u ssh://gaoyuxia@10.30.99.88:29418/$PROJECT/manifest -m default.xml -b $BRANCH
		repo sync -j4
	    	if [ $? -eq 0 ] ; then
			echo "repo init code  sucessfully"
		  	exit 1
	    	fi   
	fi
}


function build_code(){
	pushd "$PATHROOT"/$PROJECT
		echo "target=msm8996_gvmq-userdebug" > build_target.cfg
       	       	./mk scm 2>&1 | tee -a build.log
        	if [ "$?" -eq 0 ];then
            		echo "All Project Build success!"
        	fi	
    	popd
}


function packing(){
	echo $old_version
	VERSION=$old_version
	Pack_name=820A_QNX_V${VERSION}_$Date
	echo $Pack_name
	Target_name=820A_QNX_V${VERSION}_$Date
	echo $Target_name
}


function make_zipfile(){
	packing
	echo $Pack_name
	echo "Ready to pack"
	if [ $TYPE = "USERDEBUG" ] ; then
		pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/$LUNCH
			zip -9 -r ${Pack_name}_OriginalFactory.zip sahara_images
			zip -9 -r DEBUG_INFO.zip scm_debug_info
			pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/$LUNCH/multiflash_images
				zip -r -9 ${Pack_name}.zip ./*
                        popd
		popd
	else	
		echo "goto next-------"
	fi
}


function ftp_upload(){
packing
ftp -n 10.30.11.100 2>&1 <<EOC
	user sh@scm sh@scm
	binary
	cd ${Ftp_PATCH}
	mkdir ${Target_name} 
	cd ${Target_name}
	mkdir target
	cd target
	lcd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/$LUNCH
	mkdir $TYPE
	cd $TYPE
	put ${Pack_name}_OriginalFactory.zip
	put DEBUG_INFO.zip
	lcd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/$LUNCH/multiflash_images
	put ${Pack_name}.zip
	bye
EOC
echo "11.100 Ftp upload complete"
}


################## main #################
function main(){
	if [ $# -eq 1 ];then
		clean_code
		build_code
    		make_zipfile
		ftp_upload    
	else
		echo "请输入版本号"
	fi
}

main "$@"
