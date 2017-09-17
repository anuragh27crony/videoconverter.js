# Current build uses emscripten at commit df11c6f1fd1636a355b83a1c48b3a890596e6a32

echo "Beginning Build:"

rm -r dist
mkdir -p dist

cd zlib
make clean
emconfigure ./configure --prefix=$(pwd)/../dist --64
emmake make	
emmake make install
cd ..


# x264-snapshot-20140501-2245
cd x264
make clean
emconfigure ./configure --disable-thread --disable-asm \
  --host=i686-pc-linux-gnu \
  --disable-cli --enable-static --disable-gpl --prefix=$(pwd)/../dist
emmake make
emmake make install
cd ..

cd ffmpeg

#--enable-small

make clean
emconfigure ./configure --cc="emcc" --prefix=$(pwd)/../dist --enable-cross-compile --enable-static --target-os=none --arch=x86_32 --cpu=generic \
--disable-all --disable-everything --disable-ffplay --disable-ffprobe --disable-ffserver --disable-asm --disable-doc --disable-pthreads --disable-w32threads --disable-network \
--disable-fast-unaligned --disable-os2threads --disable-debug --disable-stripping --disable-dxva2 --disable-vaapi --disable-vda --disable-vdpau --disable-bzlib  --disable-iconv \
--disable-xlib  --disable-zlib --disable-opencl \
--enable-ffmpeg --enable-avcodec --enable-avcodec  --enable-avformat  --enable-avutil  --enable-swresample  --enable-swscale  --enable-avfilter \
--enable-decoder=vp8  --enable-decoder=vp9  --enable-decoder=theora  --enable-decoder=mpeg2video  --enable-decoder=mpeg4 \
--enable-decoder=h264  --enable-decoder=hevc  --enable-decoder=png  --enable-decoder=mjpeg  --enable-decoder=vorbis  --enable-decoder=opus  --enable-decoder=mp3 \
--enable-decoder=ac3  --enable-decoder=aac  --enable-decoder=ass  --enable-decoder=ssa  --enable-decoder=srt  --enable-decoder=webvtt  --enable-demuxer=matroska \
--enable-demuxer=ogg  --enable-demuxer=avi  --enable-demuxer=mov  --enable-demuxer=flv  --enable-demuxer=mpegps  --enable-demuxer=image2 --enable-demuxer=mp3  \
--enable-demuxer=concat  --enable-protocol=file --enable-protocol=http --enable-filter=aresample  --enable-filter=scale  --enable-filter=crop  --enable-filter=overlay \
--enable-encoder=libx264 --enable-encoder=aac --enable-muxer=mp4  --enable-muxer=mp3 --enable-muxer=image2 --enable-muxer=null \
--enable-gpl --enable-libvpx --enable-libx264 && \ 
--extra-libs="$(pwd)/../dist/lib/libx264.a"


# If we --enable-libx264 there is an error.  Instead just act like it is there, extra-libs seems to work.
sed -i '' 's/define CONFIG_LIBX264 0/define CONFIG_LIBX264 1/' config.h
sed -i '' 's/define CONFIG_LIBX264_ENCODER 0/define CONFIG_LIBX264_ENCODER 1/' config.h
sed -i '' 's/define CONFIG_LIBX264RGB_ENCODER 0/define CONFIG_LIBX264RGB_ENCODER 1/' config.h
sed -i '' 's/define CONFIG_H264_PARSER 0/define CONFIG_H264_PARSER 1/' config.h

sed -i '' 's/\!CONFIG_LIBX264=yes/CONFIG_LIBX264=yes/' config.mak
sed -i '' 's/\!CONFIG_LIBX264_ENCODER=yes/CONFIG_LIBX264_ENCODER=yes/' config.mak
sed -i '' 's/\!CONFIG_LIBX264RGB_ENCODER=yes/CONFIG_LIBX264RGB_ENCODER=yes/' config.mak
sed -i '' 's/\!CONFIG_H264_PARSER=yes/CONFIG_H264_PARSER=yes/' config.mak

make
make install


cd ..

cd dist

rm *.bc

cp lib/libz.a dist/libz.bc
cp ../ffmpeg/ffmpeg ffmpeg.bc
cp dist/lib/libx264.a dist/libx264.bc

emcc -s OUTLINING_LIMIT=100000 -s VERBOSE=1 -s TOTAL_MEMORY=33554432 -O2 -v ffmpeg.bc libx264.bc -o ../ffmpeg.js --pre-js ../ffmpeg_pre.js --post-js ../ffmpeg_post.js

cd ..


echo "Finished Build"
