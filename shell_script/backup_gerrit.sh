#!/bin/bash
echo "hehe"
rsync -avzp --delete gerrit@10.0.30.9:~/review_site/git .
rsync -avzp --delete gerrit@10.0.30.9:~/reviewdb20* .
rsync -avzp --delete gerrit@10.0.30.9:~/passwords .
#ssh gerrit@10.0.30.9 && ls
echo "哈哈"
