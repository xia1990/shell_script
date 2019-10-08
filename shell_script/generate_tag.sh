#!/bin/bash

PATH=~/rar:$PATH
PATHROOT=$(pwd)
PROJECT=T10_LA1.1.1_Branch

function generate_tag(){
	pushd  "$PATHROOT"/$PROJECT/LINUX/android/out/target/product/msm8952_64/system
		TAG=`strings build.prop | grep ro.build.supplier.version.in | awk -F'=' 'NR==1 {print $2}'`
		echo ${TAG}
	popd

	pushd "$PATHROOT"/$PROJECT
		git tag -a $TAG -m "Create Label $TAG"
		git push origin $TAG
	popd
}
generate_tag
