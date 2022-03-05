
docker_image_name=wenyuzhao/lxr
common_jvm_args=-XX:MetaspaceSize=1G -XX:-UseBiasedLocking -XX:-TieredCompilation -XX:+UnlockDiagnosticVMOptions -XX:-InlineObjectCopy
dacapo_jvm_args=-Djava.library.path=/root/probes -cp /root/probes:/root/probes/probes.jar:/usr/share/benchmarks/dacapo/dacapo-evaluation-git-29a657f.jar
lxr_jvm_args=-XX:+UseThirdPartyHeap -Dprobes=RustMMTk

build-default-lxr:
	@echo "Building default lxr"
	@make -f Makefile.lxr
	@echo "Done"

run-example-benchmark:
	MMTK_PLAN=Immix /root/bench/builds/jdk-lxr/jdk/bin/java $(common_jvm_args) $(dacapo_jvm_args) $(lxr_jvm_args) -Xms100M -Xmx100M Harness -n 5 -c probe.DacapoChopinCallback fop

run2:
	running runbms /root/bench/results /root/bench/xput.yml 8 4

docker-push:
	sudo docker push $(docker_image_name)

docker-build: dacapo-evaluation-git-29a657f.zip
	sudo docker build -t $(docker_image_name) .

docker-run:
	sudo docker rm -f lxr
	sudo docker run -dit --privileged -m 64g --name lxr $(docker_image_name)
	# sudo docker exec -it lxr /bin/bash

docker-stop:
	sudo docker stop lxr

dacapo-evaluation-git-29a657f.zip: dacapo-9.12-bach.jar dacapo-2006-10-MR2.jar dacapo-evaluation-git-29a657f.jar dacapo-evaluation-git-29a657f.jar dacapo-evaluation-git-29a657f.zip.aa dacapo-evaluation-git-29a657f.zip.ab dacapo-evaluation-git-29a657f.zip.ac dacapo-evaluation-git-29a657f.zip.ad
	cat dacapo-evaluation-git-29a657f.zip.* > dacapo-evaluation-git-29a657f.zip

dacapo-%.jar:
	wget https://github.com/wenyuzhao/lxr-pldi-2022-artifact/releases/download/_/$@

dacapo-evaluation-git-29a657f.zip.%:
	wget https://github.com/wenyuzhao/lxr-pldi-2022-artifact/releases/download/_/$@