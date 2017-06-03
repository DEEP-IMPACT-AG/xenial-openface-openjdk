FROM ubuntu:16.04

ADD build_openface.sh /app/
ADD build_torch.sh /app/

RUN apt-get update \
 && apt-get install -y sudo wget curl git zip python2.7-dev python2.7 libpython2.7 python-pip cmake build-essential ca-certificates \
            libtbb2 libtbb-dev libpng12-0 libpng12-dev libtiff5-dev libjasper1 libjasper-dev \
            libdc1394-22 libdc1394-22-dev openjdk-8-jre-headless \
            graphicsmagick libgraphicsmagick1-dev libfftw3-bin libfftw3-double3 libfftw3-long3 libfftw3-quad3 \
            libfftw3-single3 libfftw3-dev \
            libreadline6 libreadline6-dev libjpeg8 libjpeg8-dev libzmq5 libzmq3-dev \
            libboost-atomic1.58.0 libboost-chrono1.58.0 libboost-context1.58.0 libboost-coroutine1.58.0 \
            libboost-date-time1.58.0 libboost-filesystem1.58.0 libboost-graph-parallel1.58.0 libboost-graph1.58.0 \
            libboost-iostreams1.58.0 libboost-locale1.58.0 libboost-log1.58.0 libboost-math1.58.0 libboost-mpi-python1.58.0 \
            libboost-mpi1.58.0 libboost-program-options1.58.0 libboost-random1.58.0 libboost-regex1.58.0 libboost-serialization1.58.0 \
            libboost-signals1.58.0 libboost-test1.58.0 libboost-thread1.58.0 libboost-timer1.58.0 libboost-wave1.58.0 \
            libboost-python1.58.0 libboost-python1.58-dev libssl1.0.0 libssl-dev \
 && pip install numpy scipy pandas scikit-learn scikit-image \
 && useradd -m app && echo "app:app" | chpasswd && adduser app sudo \
 && chown -R app /app \
 && adduser app adm \
 && chmod a+rx /root \
 && chmod a+rxw /var \
 && git clone https://github.com/xianyi/OpenBLAS.git /root/openblas \
 && cd /root/openblas/ \
 && make NO_AFFINITY=1 USE_OPENMP=0 USE_THREAD=0 \
 && make install \
 && cd /root \
 && rm -fr openblas \
 && su app -c "/app/build_torch.sh" \
 && ln -s /app/torch/install/bin/* /usr/local/bin \
 && su app -c "luarocks install dpnn && luarocks install image && luarocks install optim && luarocks install csvigo && luarocks install optnet && luarocks install graphicsmagick && luarocks install tds" \
 && git clone https://github.com/opencv/opencv.git /root/opencv && cd /root/opencv && git checkout 2.4.13 \
 && mkdir /root/opencv/build && cd /root/opencv/build  \
 && cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D BUILD_PYTHON_SUPPORT=ON \
          ..  \
 && make -j8 \
 && make install \
 && cd /root \
 && rm -fr opencv \
 && git clone https://github.com/davisking/dlib.git /root/dlib && cd /root/dlib && git checkout v19.0 \
 && cd /root/dlib/python_examples && cmake ../tools/python && cmake --build . --config Release -- -j8 \
 && cp dlib.so /usr/local/lib/python2.7/dist-packages \
 && cd /root && rm dlib -rf \
 && su app -c "/app/build_openface.sh" \
 && cd /app/openface \
 && python setup.py install \
 && SUDO_FORCE_REMOVE=yes apt-get remove -y sudo wget git cmake build-essential python2.7-dev libtbb-dev \
    libpng12-dev libtiff5-dev libfftw3-dev libreadline6-dev libjpeg8-dev libzmq3-dev libboost-python1.58-dev libssl-dev \
 && apt-get autoremove -y \
 && find /app -name ".git" | xargs rm -fr {} \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
