#!/bin/bash
set -e
# 去掉 [*] 和 <*> 便于从 deb 复制 Build-Depends
pkgs=$(cat /dev/stdin | sed "s#\[[^]]\+]##g" | sed "s# <\w\+># #g" | tr ',' '|')

url=https://pools.uniontech.com/deepin-beige
distribution=beige
components="main"
arch=$1

rm -rf ~/.aptly
aptly mirror create -ignore-signatures -architectures=$arch -filter="$pkgs" -filter-with-deps linglong-download-depend $url $distribution $components > /dev/null
aptly mirror update -ignore-signatures linglong-download-depend > download.log

grep 'Success downloading' download.log|grep 'deb$'|awk '{print $3}'|sort|while IFS= read -r url; do
    filename=$(basename "$url")
    filepath=$(find ~/.aptly/pool|grep "\_$filename")
    digest=$(sha256sum "$filepath"|awk '{print $1}')
    echo "  - kind: file"
    echo "    url: $url"
    echo "    digest: $digest"
done

rm download.log