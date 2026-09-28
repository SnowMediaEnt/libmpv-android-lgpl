#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf _build$ndk_suffix
	exit 0
else
	exit 255
fi

mkdir -p _build$ndk_suffix
cd _build$ndk_suffix

cpu=armv7-a
[[ "$ndk_triple" == "aarch64"* ]] && cpu=armv8-a
[[ "$ndk_triple" == "x86_64"* ]] && cpu=generic
[[ "$ndk_triple" == "i686"* ]] && cpu="i686 --disable-asm"

cpuflags=
[[ "$ndk_triple" == "arm"* ]] && cpuflags="$cpuflags -mfpu=neon -mcpu=cortex-a8"

../configure \
	--target-os=android --enable-cross-compile --cross-prefix=$ndk_triple- --cc=$CC \
	--arch=${ndk_triple%%-*} --cpu=$cpu --pkg-config=pkg-config --nm=llvm-nm \
	--extra-cflags="-I$prefix_dir/include $cpuflags" --extra-ldflags="-L$prefix_dir/lib" \
	--enable-{jni,mediacodec,mbedtls,libdav1d} --disable-vulkan \
	--disable-static --enable-shared \
	--enable-version3 --disable-gpl --disable-nonfree --disable-postproc \
	--disable-{stripping,doc,programs} \
	--disable-{muxers,encoders,devices,filters} \
	--disable-v4l2-m2m

# LGPL build: refuse to continue if configure produced anything but an LGPL FFmpeg.
# (--enable-version3 is required by mbedtls and makes this LGPL version 3 or later.)
grep -q '^#define FFMPEG_LICENSE "LGPL version 3 or later"' config.h || {
	echo >&2 "FFmpeg is not configured as LGPL:"; grep FFMPEG_LICENSE config.h >&2; exit 1; }
if grep -q -- '--enable-gpl\|--enable-nonfree' config.h; then
	echo >&2 "FFmpeg configuration contains --enable-gpl/--enable-nonfree"; exit 1
fi

make -j$cores
make DESTDIR="$prefix_dir" install

ln -sf "$prefix_dir"/lib/libswresample.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavutil.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavcodec.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavformat.so "$native_dir"
ln -sf "$prefix_dir"/lib/libswscale.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavfilter.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavdevice.so "$native_dir"
