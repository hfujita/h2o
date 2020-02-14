#!/bin/bash

cd `git rev-parse --show-toplevel`
files=`git diff --cached --name-only HEAD^ | egrep -v '(^deps/|/_|^handler/mimemap/defaults\.c\.h)' | grep -e '.*\.[ch]\(\.in\)\?$'`

command -v clang-format > /dev/null
if [ ! $? ]; then
	echo "Cannot execute clang-format"
	exit 1
fi

tmpdir=`mktemp --tmpdir -d h2o-format-checker.XXXXXX`
if [ $? != 0 ]; then
	echo "Failed to create a temp directory"
    exit 1
fi

cp .clang-format ${tmpdir}/

ret=0

# Verify code formatting using clang-format
for f in $files; do
	git checkout-index --prefix=${tmpdir}/ $f
	index=${tmpdir}/$f # File from current index
	correct=$tmpdir/${f}.correct # File with correct format
	clang-format -style=file $index > $correct
	diff -u $index $correct
	if [ $? != 0 ]; then
		ret=1
	fi
done

rm -rf $tmpdir

exit $ret
