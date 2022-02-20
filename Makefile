
common_jvm_args=-XX:MetaspaceSize=1G -XX:-UseBiasedLocking -XX:-TieredCompilation -XX:+UnlockDiagnosticVMOptions -XX:-InlineObjectCopy
lxr_jvm_args=-XX:+UseThirdPartyHeap -Dprobes=RustMMTk -Djava.library.path=$PWD/evaluation/probes -cp $PWD/evaluation/probes:$PWD/evaluation/probes/probes.jar:/usr/share/benchmarks/dacapo/dacapo-evaluation-git-29a657f.jar Harness -n 5 -c probe.DacapoChopinCallback

build-default-lxr:
	@echo "Building default lxr"
	@make -f Makefile.lxr
	@echo "Done"

run-example-benchmark:
	MMTK_PLAN=Immix /root/mmtk-openjdk/repos/openjdk/build/linux-x86_64-normal-server-release/jdk/bin/java $(common_jvm_args) -Xms100M -Xmx100M -XX:+UseThirdPartyHeap -Dprobes=RustMMTk -Djava.library.path=$PWD/evaluation/probes -cp $PWD/evaluation/probes:$PWD/evaluation/probes/probes.jar:/usr/share/benchmarks/dacapo/dacapo-evaluation-git-29a657f.jar Harness -n 5 -c probe.DacapoChopinCallback xalan

docker-push:
	docker push wenyuzhao/lxr

docker-build:
	docker build -t wenyuzhao/lxr .