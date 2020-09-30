FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
# install deps
ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y \
    git \
    sudo \
    build-essential \
    libgtk2.0-dev \
    pkg-config \
    python-numpy \
    python-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff5-dev \
    build-essential \
    checkinstall \
    cmake \
    pkg-config \
    yasm \
    libjpeg-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libdc1394-22-dev \
    libxine2 \
    libv4l-dev \
    libtbb-dev \
    libgtk2.0-dev \
    libmp3lame-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libtheora-dev \
    libvorbis-dev \
    libxvidcore-dev \
    x264 \
    v4l-utils \
    wget \
    unzip \
    gcc-5 \
    g++-5 \
    ffmpeg \
    protobuf-compiler \
    libprotobuf-dev \
    && rm -rf /var/lib/apt/lists/*

# install torch7
RUN git clone https://github.com/nagadomi/distro.git /root/torch --recursive && \
    cd /root/torch && \
     ./install-deps && \
     TORCH_CUDA_ARCH_LIST="Kepler Maxwell Kepler+Tegra Kepler+Tesla Maxwell+Tegra Pascal Volta Turing" ./install.sh -b

# set env, from torch-activate
ENV LUA_PATH='/root/.luarocks/share/lua/5.1/?.lua;/root/.luarocks/share/lua/5.1/?/init.lua;/root/torch/install/share/lua/5.1/?.lua;/root/torch/install/share/lua/5.1/?/init.lua;./?.lua;/root/torch/install/share/luajit-2.1.0-beta1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua'
ENV LUA_CPATH='/root/.luarocks/lib/lua/5.1/?.so;/root/torch/install/lib/lua/5.1/?.so;/root/torch/install/lib/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so'
ENV PATH=/root/torch/install/bin:$PATH
ENV LD_LIBRARY_PATH=/root/torch/install/lib:$LD_LIBRARY_PATH
ENV DYLD_LIBRARY_PATH=/root/torch/install/lib:$DYLD_LIBRARY_PATH
ENV LUA_CPATH='/root/torch/install/lib/?.so;'$LUA_CPATH

# download opencv-2.4.13
RUN wget https://vorboss.dl.sourceforge.net/project/opencvlibrary/opencv-unix/2.4.13/opencv-2.4.13.zip \
    && unzip opencv-2.4.13.zip \
    && cd opencv-2.4.13 \
    mkdir release \
    cd release


# compile and install
WORKDIR /opencv-2.4.13/release
RUN cmake -G "Unix Makefiles" -DCMAKE_CXX_STANDARD=11 -DCMAKE_CXX_COMPILER=/usr/bin/g++-5 -DCMAKE_C_COMPILER=/usr/bin/gcc-5 -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/usr/local -DWITH_TBB=ON -DBUILD_NEW_PYTHON_SUPPORT=ON -DWITH_V4L=ON -DINSTALL_C_EXAMPLES=OFF -DINSTALL_PYTHON_EXAMPLES=OFF -DBUILD_EXAMPLES=OFF -DWITH_QT=OFF -DWITH_OPENGL=ON -DBUILD_FAT_JAVA_LIB=ON -DINSTALL_TO_MANGLED_PATHS=ON -DINSTALL_CREATE_DISTRIB=ON -DINSTALL_TESTS=ON -DENABLE_FAST_MATH=ON -DWITH_IMAGEIO=ON -DBUILD_SHARED_LIBS=ON -DWITH_GSTREAMER=ON -DWITH_CUDA=OFF ..  \
    && make all -j4 \
    && make install

# setup fast artistic videos
RUN git clone https://github.com/ramintoosi/fast-artistic-videos /root/app \
    && cd /root/app \
    && cd consistencyChecker \
    && make \
    && cd .. \
    && bash download_models.sh

RUN luarocks install loadcaffe

WORKDIR /root/app
