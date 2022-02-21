
common_jvm_args=-XX:MetaspaceSize=1G -XX:-UseBiasedLocking -XX:-TieredCompilation -XX:+UnlockDiagnosticVMOptions -XX:-InlineObjectCopy
dacapo_jvm_args=-Djava.library.path=/root/probes -cp /root/probes:/root/probes/probes.jar:/usr/share/benchmarks/dacapo/dacapo-evaluation-git-f480064.jar
lxr_jvm_args=-XX:+UseThirdPartyHeap -Dprobes=RustMMTk

build-default-lxr:
	@echo "Building default lxr"
	@make -f Makefile.lxr
	@echo "Done"

run-example-benchmark:
	MMTK_PLAN=Immix /root/mmtk-openjdk/repos/openjdk/build/linux-x86_64-normal-server-release/jdk/bin/java $(common_jvm_args) $(dacapo_jvm_args) $(lxr_jvm_args) -Xms100M -Xmx100M Harness -n 5 -c probe.DacapoChopinCallback fop

docker-push: name=wenyuzhao/lxr
docker-push:
	docker push $(name)

docker-build: dacapo-evaluation-git-f480064.zip
	docker build -t wenyuzhao/lxr .

dacapo-evaluation-git-f480064.zip: dacapo-9.12-bach.jar dacapo-2006-10-MR2.jar dacapo-evaluation-git-29a657f.jar dacapo-evaluation-git-f480064.jar dacapo-evaluation-git-f480064.zip.001 dacapo-evaluation-git-f480064.zip.002 dacapo-evaluation-git-f480064.zip.003 dacapo-evaluation-git-f480064.zip.004
	cat dacapo-evaluation-git-f480064.zip.* > dacapo-evaluation-git-f480064.zip

dacapo-%.jar:
	wget https://github.com/wenyuzhao/lxr-pldi-2022-artefact/releases/download/_/$@

dacapo-evaluation-git-f480064.zip.%:
	wget https://github.com/wenyuzhao/lxr-pldi-2022-artefact/releases/download/_/$@