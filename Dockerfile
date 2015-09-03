FROM ubuntu:14.04
MAINTAINER Hisanari Otsu <hi2p.perim@gmail.com>

# Install some packages
RUN apt-get update -qq
RUN apt-get install -qq -y git software-properties-common 
RUN add-apt-repository -y ppa:george-edison55/cmake-3.x
RUN apt-get update -qq
RUN apt-get install -qq -y python cmake build-essential libfreeimage-dev libboost-dev libboost-regex-dev libboost-program-options-dev libboost-system-dev libboost-filesystem-dev libboost-coroutine-dev libboost-context-dev freeglut3-dev libxmu-dev libxi-dev libglm-dev libyaml-cpp-dev libtbb-dev libeigen3-dev libctemplate-dev

# Install assimp
RUN git clone --depth=1 --branch v3.1.1 https://github.com/assimp/assimp.git assimp
RUN mkdir -p assimp/build && cd assimp/build && cmake -DCMAKE_BUILD_TYPE=Release .. && make -j && make install

# Install embree
RUN git clone --depth=1 --branch v2.5.1 https://github.com/embree/embree.git embree
RUN mkdir -p embree/build && cd embree/build && cmake -D CMAKE_BUILD_TYPE=Release -D ENABLE_ISPC_SUPPORT=OFF -D RTCORE_TASKING_SYSTEM=INTERNAL -D ENABLE_TUTORIALS=OFF .. && make -j && make install && cp libembree.so /usr/local/lib

# Add a project file to the container
COPY include /nanogi/
COPY cmake /nanogi/
COPY src /nanogi/

# Build nanogi
RUN mkdir -p nanogi/build && cd nanogi/build && BOOST_ROOT="" BOOST_INCLUDEDIR="/usr/include" BOOST_LIBRARYDIR="/usr/lib/x86_64-linux-gnu" cmake -DCMAKE_BUILD_TYPE=Release .. && make -j
RUN ln -s /nanogi/build/bin/nanogi /nanogi
