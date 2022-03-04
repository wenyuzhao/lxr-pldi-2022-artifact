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
RUN mkdir -p /usr/share/benchmarks/dacapo/
COPY ./dacapo-2006-10-MR2.jar /usr/share/benchmarks/dacapo/
COPY ./dacapo-9.12-bach.jar /usr/share/benchmarks/dacapo/
COPY ./dacapo-evaluation-git-29a657f.jar /usr/share/benchmarks/dacapo/
COPY ./dacapo-evaluation-git-29a657f.jar /usr/share/benchmarks/dacapo/
COPY ./dacapo-evaluation-git-29a657f.zip /usr/share/benchmarks/dacapo/
RUN cd /usr/share/benchmarks/dacapo/ && unzip dacapo-evaluation-git-29a657f.zip

# Install running-ng
RUN pip3 install running-ng

# Copy and build probes
COPY ./probes /root/probes
COPY ./probes.patch /root/probes.patch
COPY ./.git /root/.git
RUN cd probes && git apply ../probes.patch
RUN cd probes && make all JDK=/usr/lib/jvm/java-11-openjdk-amd64 CFLAGS=-Wno-error=stringop-overflow JAVAC=/usr/lib/jvm/java-11-openjdk-amd64/bin/javac

# Clone mmtk-core, mmtk-openjdk and openjdk
RUN git clone -b lxr-2021-11-19 https://github.com/wenyuzhao/mmtk-core.git
RUN git clone --recurse-submodules -b lxr-2021-11-19 https://github.com/wenyuzhao/mmtk-openjdk.git
COPY ./.cargo/config.toml /root/.cargo/config.toml
RUN echo "nightly-2021-11-20" > /root/mmtk-core/rust-toolchain
RUN echo "nightly-2021-11-20" > /root/mmtk-openjdk/mmtk/rust-toolchain

# Build OpenJDK(LXR)
COPY ./bench /root/bench
RUN ~/bench/build.sh --features lxr_evac --copy ~/bench/builds/jdk-lxr-stw
RUN ~/bench/build.sh --features lxr --copy ~/bench/builds/jdk-lxr

# Copy Makefile
COPY ./Makefile /root/Makefile

CMD ["bash", "--login"]