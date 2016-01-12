#!/bin/sh

git submodule init
git submodule update

for dir in $(find . -type d -maxdepth 1 | grep -e '[0-9]\{3\}'); do
	echo "Bootstrapping " $dir
	pushd $dir/love-toys
	git submodule init
	git submodule update
	popd
done

