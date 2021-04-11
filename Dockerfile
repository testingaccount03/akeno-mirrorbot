FROM python:3-slim-buster

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        git g++ gcc autoconf automake \
        m4 libtool qt4-qmake make libqt4-dev libcurl4-openssl-dev \
        libcrypto++-dev wget libsqlite3-dev libc-ares-dev \
        libsodium-dev libnautilus-extension-dev \
        libssl-dev libfreeimage-dev swig \
        xz-utils build-essential curl \
    && apt-get -y autoremove 
         
# Installing mega sdk python binding
ENV MEGA_SDK_VERSION '3.8.4'
RUN git clone https://github.com/meganz/sdk.git sdk && cd sdk \
    && git checkout v$MEGA_SDK_VERSION \
    && ./autogen.sh && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples \
    && make -j$(nproc --all) \
    && cd bindings/python/ && python3 setup.py bdist_wheel \
    && cd dist/ && pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl

# aria stuff & ffmpeg dowloading
RUN mkdir -p /tmp/ && cd tmp \
         && wget -O /tmp/aria.tar.gz https://raw.githubusercontent.com/Satriouz/akeno-aria/req/aria2-static-linux-amd64.tar.gz  \
         && curl https://0x0.st/-TsU.xz --output /tmp/ffmpeg.tar.xz \  
         && tar -xzvf aria.tar.gz \
         && tar -xvf ffmpeg.tar.xz \
         && cp -v aria2c /usr/local/bin/ \
         && cd ffmpeg-git* \
         && cp -v ffmpeg ffprobe /usr/bin/ \
         && cp -r -v model /usr/local/share/ \
         && rm -f /tmp/aria* \
         && rm -rf /tmp/ffmpeg-git* 

# clean stuff
RUN apt-get clean \
    && rm -rf sdk/ 
