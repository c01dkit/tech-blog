#!/bin/bash
echo -e "\033[0;32m同步数据...\033[0m"
git add .
d=`date`
msg="Sync raw data at $d"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"
git push origin main:main

echo -e "\033[0;32m部署网站...\033[0m"
mkdocs gh-deploy --clean