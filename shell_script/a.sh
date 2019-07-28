#!/bin/bash

prj=P118F
message="[Subject]\n[$prj]\n[Bug Number/CSP Number/Enhancement/New Feature]\nN/A\n[Ripple Effect]\nN/A\n[Solution]\nN/A\n[Project]\n[$prj]\n\n\n"


git init Project
cd Project
touch b.txt
git add b.txt
commit_message=$(echo -e $message | sed "0,/\[$prj\]/s/\[$prj\]/&gaoyuxia/")
git commit --amend -m "$commit_message"
print "new file:  b.txt"
git log 
cd ../
