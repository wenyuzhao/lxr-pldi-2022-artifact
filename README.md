running runbms /root/bench/results /root/bench/xput.yml 8 4

MMTK_PLAN=Immix NURSERY_RATIO=1 /root/bench/builds/jdk-lxr/jdk/bin/java -XX:MetaspaceSize=1G -XX:+DisableExplicitGC -XX:-UseBiasedLocking -server -XX:-TieredCompilation -Xcomp -Djava.library.path=/root/probes -Dprobes=RustMMTk -XX:+UnlockDiagnosticVMOptions -XX:-InlineObjectCopy -XX:+UseThirdPartyHeap -Xms269M -Xmx269M -cp /usr/share/benchmarks/dacapo/dacapo-evaluation-git-29a657f.jar:/root/probes:/root/probes/probes.jar Harness -c probe.DacapoChopinCallback -n 5 -s default cassandra


MMTK_PLAN=Immix NURSERY_RATIO=1 /root/bench/builds/jdk-lxr/jdk/bin/java -XX:MetaspaceSize=1G -XX:+DisableExplicitGC -XX:-UseBiasedLocking -server -XX:-TieredCompilation -Xcomp -XX:+UnlockDiagnosticVMOptions -XX:-InlineObjectCopy -XX:+UseThirdPartyHeap -Xms269M -Xmx269M -cp /usr/share/benchmarks/dacapo/dacapo-evaluation-git-29a657f.jar Harness -n 5 -s default cassandra




MMTK_PLAN=SemiSpace /root/mmtk-openjdk/repos/openjdk/build/linux-x86_64-normal-server-release/jdk/bin/java -XX:MetaspaceSize=1G -XX:+DisableExplicitGC -XX:-UseBiasedLocking -server -XX:-TieredCompilation -Xcomp -Djava.library.path=/root/probes -Dprobes=RustMMTk -XX:+UnlockDiagnosticVMOptions -XX:-InlineObjectCopy -XX:+UseThirdPartyHeap -Xms269M -Xmx269M -cp /usr/share/benchmarks/dacapo/dacapo-evaluation-git-29a657f.jar:/root/probes:/root/probes/probes.jar Harness -c probe.DacapoChopinCallback -n 5 -s default cassandra

MMTK_PLAN=Immix NURSERY_RATIO=1 /root/mmtk-openjdk/repos/openjdk/build/linux-x86_64-normal-server-release/jdk/bin/java -XX:MetaspaceSize=1G -XX:+DisableExplicitGC -XX:-UseBiasedLocking -server -XX:-TieredCompilation -Xcomp -Djava.library.path=/root/probes -Dprobes=RustMMTk -XX:+UnlockDiagnosticVMOptions -XX:-InlineObjectCopy -XX:+UseThirdPartyHeap -Xms269M -Xmx269M -cp /usr/share/benchmarks/dacapo/dacapo-evaluation-git-29a657f.jar:/root/probes:/root/probes/probes.jar Harness -c probe.DacapoChopinCallback -n 5 -s default cassandra




MMTK_PLAN=Immix NURSERY_RATIO=1 ~/lxr-pldi-2022-artefact/jdk-lxr/jdk/bin/java -XX:MetaspaceSize=1G -XX:+DisableExplicitGC -XX:-UseBiasedLocking -server -XX:-TieredCompilation -Xcomp -Djava.library.path=/root/probes -Dprobes=RustMMTk -XX:+UnlockDiagnosticVMOptions -XX:-InlineObjectCopy -XX:+UseThirdPartyHeap -Xms269M -Xmx269M -cp /usr/share/benchmarks/dacapo/dacapo-evaluation-git-29a657f.jar:/root/probes:/root/probes/probes.jar Harness -c probe.DacapoChopinCallback -n 5 -s default cassandra



MMTK_PLAN=Immix NURSERY_RATIO=1 ~/lxr-pldi-2022-artefact/jdk-lxr/jdk/bin/java -XX:MetaspaceSize=1G -XX:+DisableExplicitGC -XX:-UseBiasedLocking -server -XX:-TieredCompilation -Xcomp -Djava.library.path=/root/probes -XX:+UnlockDiagnosticVMOptions -XX:-InlineObjectCopy -XX:+UseThirdPartyHeap -Xms269M -Xmx269M -cp /usr/share/benchmarks/dacapo/dacapo-evaluation-git-29a657f.jar Harness -n 5 -s default cassandra
