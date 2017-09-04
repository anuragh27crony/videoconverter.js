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

cd ffmpeg

#--enable-small

make clean
emconfigure ./configure --cc="emcc" --prefix=$(pwd)/../dist --enable-cross-compile --target-os=none --arch=x86_32 --cpu=generic \
    --disable-ffplay --disable-ffprobe --disable-ffserver --disable-asm --disable-doc --disable-devices --disable-pthreads --disable-w32threads --disable-network \
    --disable-asm --disable-fast-unaligned --disable-pthreads --disable-w32threads --disable-os2threads --disable-debug --disable-stripping --disable-all --enable-ffmpeg --enable-avcodec \
    --enable-avformat --enable-avutil --enable-swresample --enable-swscale --enable-avfilter --disable-network --disable-dxva2 --disable-vaapi --disable-vda --disable-vdpau
    --enable-avcodec  --enable-avformat  --enable-avutil  --enable-swresample  --enable-swscale  --enable-avfilter --disable-network  --disable-d3d11va  --disable-dxva2 \
    --disable-vaapi  --disable-vda  --disable-vdpau  --enable-decoder=vp8  --enable-decoder=vp9  --enable-decoder=theora  --enable-decoder=mpeg2video  --enable-decoder=mpeg4 \
    --enable-decoder=h264  --enable-decoder=hevc  --enable-decoder=png  --enable-decoder=mjpeg  --enable-decoder=vorbis  --enable-decoder=opus  --enable-decoder=mp3 \
    --enable-decoder=ac3  --enable-decoder=aac  --enable-decoder=ass  --enable-decoder=ssa  --enable-decoder=srt  --enable-decoder=webvtt  --enable-demuxer=matroska \
    --enable-demuxer=ogg  --enable-demuxer=avi  --enable-demuxer=mov  --enable-demuxer=flv  --enable-demuxer=mpegps  --enable-demuxer=image2  --enable-demuxer=mp3  \
    --enable-demuxer=concat  --enable-protocol=file  --enable-filter=aresample  --enable-filter=scale  --enable-filter=crop  --enable-filter=overlay  --disable-bzlib  --disable-iconv  \
    --disable-libxcb  --disable-lzma  --disable-sdl  --disable-securetransport  --disable-xlib  --disable-zlib  --enable-encoder=libx264  --enable-encoder=libmp3lame  --enable-encoder=aac  \
    --enable-muxer=mp4  --enable-muxer=mp3  --enable-muxer=null  --enable-gpl  --enable-libmp3lame  --disable-hwaccels --disable-parsers --disable-bsfs --disable-debug --disable-protocols \
    --disable-indevs --disable-outdevs \

make
make install


cd ..

cd dist

rm *.bc

cp lib/libz.a dist/libz.bc
cp ../ffmpeg/ffmpeg ffmpeg.bc

emcc -s OUTLINING_LIMIT=100000 -s VERBOSE=1 -s TOTAL_MEMORY=33554432 -O2 -v ffmpeg.bc -o ../ffmpeg.js --pre-js ../ffmpeg_pre.js --post-js ../ffmpeg_post.js

cd ..


echo "Finished Build"
