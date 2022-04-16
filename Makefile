
docker_image_name=wenyuzhao/lxr
common_jvm_args=-XX:MetaspaceSize=1G -XX:-UseBiasedLocking -XX:-TieredCompilation -XX:+UnlockDiagnosticVMOptions -XX:-InlineObjectCopy
dacapo_jvm_args=-Djava.library.path=/root/probes -cp /root/probes:/root/probes/probes.jar:/usr/share/benchmarks/dacapo/dacapo-evaluation-git-b00bfa9.jar
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

docker-build: probes.zip dacapo-evaluation-git-b00bfa9.zip
	sudo docker build -t $(docker_image_name) .

docker-run:
	sudo docker rm -f lxr
	sudo docker run -dit --privileged -m 16g --name lxr $(docker_image_name)
	# sudo docker exec -it lxr /bin/bash

docker-stop:
	sudo docker stop lxr

probes.zip:
	wget https://github.com/wenyuzhao/lxr-pldi-2022-artifact/releases/download/_/$@

dacapo-evaluation-git-b00bfa9.zip: dacapo-evaluation-git-b00bfa9.jar dacapo-evaluation-git-b00bfa9.zip.aa dacapo-evaluation-git-b00bfa9.zip.ab dacapo-evaluation-git-b00bfa9.zip.ac dacapo-evaluation-git-b00bfa9.zip.ad
	cat dacapo-evaluation-git-b00bfa9.zip.* > dacapo-evaluation-git-b00bfa9.zip

dacapo-%.jar:
	wget https://github.com/wenyuzhao/lxr-pldi-2022-artifact/releases/download/_/$@

dacapo-evaluation-git-b00bfa9.zip.%:
	wget https://github.com/wenyuzhao/lxr-pldi-2022-artifact/releases/download/_/$@

clean:
	rm -r probes
	rm *.jar
	rm *.zip