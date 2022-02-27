#!/usr/bin/env bash
set -ex

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --features)
      features="$2"
      shift; shift
      ;;
    -cp|--copy)
      copy="$2"
      shift; shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}"

pushd /root/mmtk-openjdk/mmtk
cargo build --features $features --release
popd

pushd /root/mmtk-openjdk/repos/openjdk
sh configure --disable-warnings-as-errors --with-debug-level=release
make CONF=linux-x86_64-normal-server-release THIRD_PARTY_HEAP=$PWD/../../openjdk GC_FEATURES=$features
popd

if [ ! -z "$copy" ]; then
    mkdir -p $copy
    rm -rf $copy
    cp -r /root/mmtk-openjdk/repos/openjdk/build/linux-x86_64-normal-server-release $copy
fi
