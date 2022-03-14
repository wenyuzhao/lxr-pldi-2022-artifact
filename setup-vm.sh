#!/usr/bin/env bash

export HOME=/root
export DEBIAN_FRONTEND=noninteractive
download_url=https://github.com/wenyuzhao/lxr-pldi-2022-artifact/releases/download/_
cd /root

# Install Packages
apt-get update && apt-get upgrade -y
apt-get install -y wget curl python3 build-essential
apt-get install -y openjdk-11-jdk
apt-get install -y autoconf libx11-dev libxext-dev libxrender-dev libxrandr-dev libxtst-dev libxt-dev libcups2-dev libfontconfig1-dev libasound2-dev
apt-get install -y clang git zip libpfm4 libpfm4-dev gcc-multilib g++-multilib python3-pip
apt-get install -y vim

# Install Rust
curl https://sh.rustup.rs -sSf | bash -s -- -y
export PATH="/root/.cargo/bin:$PATH"

# Install running-ng
RUN pip3 install running-ng
RUN pip3 install hdrhistogram seaborn pandas matplotlib

# Fetch DaCapo Benchmark Suite
mkdir -p /usr/share/benchmarks/dacapo/
pushd /usr/share/benchmarks/dacapo/
wget $download_url/dacapo-9.12-bach.jar
wget $download_url/dacapo-2006-10-MR2.jar
wget $download_url/dacapo-evaluation-git-29a657f.jar
wget $download_url/dacapo-evaluation-git-29a657f.jar
wget $download_url/dacapo-evaluation-git-29a657f.zip.aa
wget $download_url/dacapo-evaluation-git-29a657f.zip.ab
wget $download_url/dacapo-evaluation-git-29a657f.zip.ac
wget $download_url/dacapo-evaluation-git-29a657f.zip.ad
cat dacapo-evaluation-git-29a657f.zip.* > dacapo-evaluation-git-29a657f.zip
unzip dacapo-evaluation-git-29a657f.zip
rm dacapo-evaluation-git-29a657f.zip.aa
rm dacapo-evaluation-git-29a657f.zip.ab
rm dacapo-evaluation-git-29a657f.zip.ac
rm dacapo-evaluation-git-29a657f.zip.ad
rm dacapo-evaluation-git-29a657f.zip
popd

# Fetch probes
wget $download_url/probes.zip
unzip probes.zip
rm probes.zip
pushd /root/probes
make all JDK=/usr/lib/jvm/java-11-openjdk-amd64 CFLAGS=-Wno-error=stringop-overflow JAVAC=/usr/lib/jvm/java-11-openjdk-amd64/bin/javac
popd

# Clone mmtk-core, mmtk-openjdk and openjdk
git clone -b lxr-2021-11-19 https://github.com/wenyuzhao/mmtk-core.git
git clone --recurse-submodules -b lxr-2021-11-19 https://github.com/wenyuzhao/mmtk-openjdk.git
echo "nightly-2021-11-20" > /root/mmtk-core/rust-toolchain
echo "nightly-2021-11-20" > /root/mmtk-openjdk/mmtk/rust-toolchain
mkdir .cargo
pushd .cargo
wget https://raw.githubusercontent.com/wenyuzhao/lxr-pldi-2022-artifact/main/.cargo/config.toml
popd

# Fetch bench configs
mkdir bench
bench_download_url=https://raw.githubusercontent.com/wenyuzhao/lxr-pldi-2022-artifact/main/bench/
pushd /root/bench
wget $bench_download_url/build.sh
wget $bench_download_url/latency-curve.py
wget $bench_download_url/latency.yml
wget $bench_download_url/xput.yml
popd
wget https://raw.githubusercontent.com/wenyuzhao/lxr-pldi-2022-artifact/main/Makefile

# Build OpenJDK(LXR)
~/bench/build.sh --features lxr_evac --copy ~/bench/builds/jdk-lxr-stw
~/bench/build.sh --features lxr --copy ~/bench/builds/jdk-lxr