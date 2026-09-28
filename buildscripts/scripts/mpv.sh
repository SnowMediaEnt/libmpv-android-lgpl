#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf $build
	exit 0
else
	exit 255
fi

unset CC CXX # meson wants these unset

meson setup $build --cross-file "$prefix_dir"/crossfile.txt \
	--default-library shared \
	-Diconv=disabled -Dlua=enabled \
	-Dlibmpv=true -Dcplayer=false \
	-Dgpl=false \
	-Dmanpage-build=disabled

# LGPL build: refuse to continue unless mpv was configured with gpl disabled.
grep -q '^#define HAVE_GPL 0' $build/config.h || {
	echo >&2 "mpv is not configured as LGPL (HAVE_GPL != 0)"; exit 1; }

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install

ln -sf "$prefix_dir"/lib/libmpv.so "$native_dir"
