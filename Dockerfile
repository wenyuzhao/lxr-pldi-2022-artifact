FROM ubuntu:18.04

ENV HOME /root
WORKDIR /root

# Install libraries
RUN apt-get update && apt-get upgrade -y
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y wget curl python3 build-essential
RUN apt-get install -y openjdk-11-jdk
RUN apt-get install -y autoconf libx11-dev libxext-dev libxrender-dev libxrandr-dev libxtst-dev libxt-dev libcups2-dev libfontconfig1-dev libasound2-dev
RUN apt-get install -y clang git zip libpfm4 libpfm4-dev gcc-multilib g++-multilib python3-pip
RUN apt-get install -y vim
# - rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Copy DaCapo Benchmark
RUN mkdir -p /root/dacapo/
COPY ./dacapo-evaluation-git-b00bfa9.jar  /root/dacapo/
COPY ./dacapo-evaluation-git-b00bfa9.jar  /root/dacapo/
COPY ./dacapo-evaluation-git-b00bfa9.zip  /root/dacapo/
RUN cd /root/dacapo/ && unzip dacapo-evaluation-git-b00bfa9.zip

# Install running-ng
RUN pip3 install running-ng
RUN pip3 install hdrhistogram seaborn pandas matplotlib

# Copy and build probes
COPY ./probes /root/probes
COPY ./probes.patch /root/probes.patch
COPY ./.git /root/.git
RUN cd probes && git apply ../probes.patch
RUN cd probes && make all JDK=/usr/lib/jvm/java-11-openjdk-amd64 CFLAGS=-Wno-error=stringop-overflow JAVAC=/usr/lib/jvm/java-11-openjdk-amd64/bin/javac

# Clone mmtk-core, mmtk-openjdk and openjdk
RUN git clone -b lxr-pldi-2022 https://github.com/wenyuzhao/mmtk-core.git
RUN git clone --recurse-submodules -b lxr-pldi-2022 https://github.com/wenyuzhao/mmtk-openjdk.git
COPY ./.cargo/config.toml /root/.cargo/config.toml

# Build OpenJDK(LXR)
COPY ./bench /root/bench
RUN ~/bench/build.sh --features lxr,lxr_heap_health_guided_gc --copy ~/bench/builds/jdk-lxr

# Copy Makefile
COPY ./Makefile /root/Makefile

CMD ["bash", "--login"]