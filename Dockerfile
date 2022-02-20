FROM ubuntu:20.04

RUN apt-get update && apt-get upgrade -y

# Copy DaCapo Benchmark
RUN apt-get install -y zip
RUN mkdir -p /usr/share/benchmarks/dacapo/
COPY ./dacapo-evaluation-git-f480064.jar /usr/share/benchmarks/dacapo/
COPY ./dacapo-evaluation-git-f480064.zip /usr/share/benchmarks/dacapo/
# RUN unzip /usr/share/benchmarks/dacapo/dacapo-evaluation-git-f480064.zip
# RUN rm /usr/share/benchmarks/dacapo/dacapo-evaluation-git-f480064.zip

# Fetch mmtk-core, mmtk-openjdk and openjdk
RUN apt-get install -y git
WORKDIR /root
RUN git clone -b lxr-2021-11-19 https://github.com/wenyuzhao/mmtk-core.git
RUN git clone --recurse-submodules -b lxr-2021-11-19 https://github.com/wenyuzhao/mmtk-openjdk.git

# Install libraries
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y wget curl python3 build-essential
RUN apt-get install -y openjdk-11-jdk
RUN apt-get install -y autoconf libx11-dev libxext-dev libxrender-dev libxrandr-dev libxtst-dev libxt-dev libcups2-dev libfontconfig1-dev libasound2-dev
RUN apt-get install -y clang
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
ENV HOME /root

# Clone running-ng
RUN git clone https://github.com/anupli/running-ng.git

# Copy other files
COPY ./.cargo/config.toml /root/.cargo/config.toml
RUN echo "nightly-2021-11-20" > /root/mmtk-core/rust-toolchain
RUN echo "nightly-2021-11-20" > /root/mmtk-openjdk/mmtk/rust-toolchain

# Build OpenJDK(LXR)
WORKDIR /root/mmtk-openjdk/repos/openjdk
RUN sh configure --disable-warnings-as-errors --with-debug-level=release
RUN make CONF=linux-x86_64-normal-server-release THIRD_PARTY_HEAP=$PWD/../../openjdk GC_FEATURES=lxr
WORKDIR /root

# Copy and build probes
RUN apt-get install -y libpfm4 libpfm4-dev gcc-multilib g++-multilib
COPY ./probes /root/probes
COPY ./dacapo-2006-10-MR2.jar /usr/share/benchmarks/dacapo/
COPY ./dacapo-9.12-bach.jar /usr/share/benchmarks/dacapo/
COPY ./dacapo-evaluation-git-29a657f.jar /usr/share/benchmarks/dacapo/
COPY ./probes.patch /root/probes.patch
RUN cd probes && git apply ../probes.patch
RUN cd probes && make all JDK=/usr/lib/jvm/java-11-openjdk-amd64 CFLAGS=-Wno-error=stringop-overflow JAVAC=/usr/lib/jvm/java-11-openjdk-amd64/bin/javac

# Copy Makefile
COPY ./Makefile /root/Makefile

CMD ["bash", "--login"]