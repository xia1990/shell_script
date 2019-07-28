#!/bin/bash
echo "find mirror file path"
find -name alternates > mirror_path

for i in `cat mirror_path`
do
	sed -i "s/E300_mirror_repo/300_mirror_repo/g"  "$i"
done
