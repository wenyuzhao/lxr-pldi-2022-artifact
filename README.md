# [**PLDI'22 Artifact**] #132 Low-Latency, High-Throughput Garbage Collection

We ship our artifact as a docker image, containing several pre-built different OpenJDK builds (with LXR GC) for evaluation.

This documentation shows the steps to fetch the image, and reproduce results in the paper.

## Table of Contents

* [Prepare](#prepare)
  * [Warnings for fully reproducable results](#warnings-for-fully-reproducable-results)
* [Getting started](#getting-started)
* [Table 4 - Latency evaluation](#table-4-latency-evaluation)
* [Table 6 - Throughput evaluation](#table-6-throughput-evaluation)
* [Figure 1 - Latency Curve](#figure-1-latency-curve)
* [Reusable artifact](#reusable-artifact)

## Prepare

### Platform requirements

* OS: Ubuntu 18.04 with docker installed (docker on windows or macos may not work).
* Memory: At least 16GB. We use 64GB DDR4 2133MHz for our evaluaiton in the paper.
* CPU: AMD 3900X (12/24 cores, 3.8 GHz, 64 MB LLC). Other recent multi-core CPUs may work as well, but can produce different results other than we have in the paper.
* At least 70 GB of disk space. (The docker image itself is 40~50 GB.)

(Not recommended) If you'd like to build the docker image yourself, please download the artifact or clone the repo https://github.com/wenyuzhao/lxr-pldi-2022-artifact, then run `make docker-build` to build the image.

### Source code

Source code is available at:
* https://github.com/wenyuzhao/mmtk-core/tree/lxr-2021-11-19 (commit 36a3099)
* https://github.com/wenyuzhao/mmtk-openjdk/tree/lxr-2021-11-19 (commit 8c34bd4)
* https://github.com/mmtk/openjdk/tree/6dc618e281128b6a38d40c7d8d2e345d610f0160

**DOI**: The source code is also available at https://doi.org/10.5281/zenodo.6351356.

### Warnings for fully reproducable results

#### Cassandra benchmark may not run

Due to the restrictions of docker, cassandra or even other benchmarks can be sliently killed by docker because of a large amount of memory reservations. _For this reason, we excluded cassandra from the evaluations._

To fully reproduce all the results with minimal experiment error, feel free to our provided VirtualBox image (`LXR.ova`) or use `setup-vm.sh` to setup a native host.  Please import the `.voa` image to VirtualBox or any other compatible VMs.

If you'd like to bring back cassandra, or exclude other benchmarks that are also killed by docker, please edit the `benchmarks.dacapochopin-29a657f` field at the start of the two benchmark config files (`/root/bench/xput.yml` and `/root/bench/latency.yml`).

#### Some benchmarks may not run with ZGC

ZGC in openjdk 11 sets a minimium heap requirement which is larger than the heap size of some of the benchmarks. For these benchmarks we will not report ZGC results.

#### Benchmark running time

Please note that some benchmarks may take over a day to complete.

For benchmarks triggered by our `running` command (see detailed instructions in the following sections), feel free to decrease the command argument `-i 20` to a smaller value to reduce the experiment time, or increase it to further reduce noise.

#### Noise and errors

Running inside a docker container can bring some overheads as well. Feel free to use a native host to run the experiment, as explained above.

#### Evaluations not included in this artifact

In our paper we have a few experiments and analysis on openjdk GCs and the benchmarks. These results are not the claims of the paper, so we do not evaluate and reproduce them in this artifact.

Some statistics results on LXR GC it self, such as the rate of ref-count increments and SATB in Table 6 are also excluded in this artifact. They are not part of the claim of the paper as well.

## Getting started

### 1. Pull docker image, launch and enter container

```console
$ sudo docker pull wenyuzhao/lxr # Pull docker image
$ sudo docker run -dit --privileged -m 16g --name lxr wenyuzhao/lxr # Launch container
$ sudo docker exec -it lxr /bin/bash # Login into the container
```

We've already included the LXR build into our image, located at `/root/bench/builds/jdk-lxr`.

### 2. Run simple benchmark

Run a simple benchmark using our pre-built LXR GC and check the output results. This will ensure that the builds in the image is functional.

Note that our GC implementation is not as stable as OpenJDK GCs. If you run into an error, try re-run it a few more times.

Please cd to `/root` and run:

```console
# MMTK_PLAN=Immix /root/bench/builds/jdk-lxr/jdk/bin/java -XX:MetaspaceSize=1G -XX:-UseBiasedLocking -XX:-TieredCompilation -XX:+UnlockDiagnosticVMOptions -XX:-InlineObjectCopy -Djava.library.path=/root/probes -cp /root/probes:/root/probes/probes.jar:/usr/share/benchmarks/dacapo/dacapo-evaluation-git-29a657f.jar -XX:+UseThirdPartyHeap -Dprobes=RustMMTk -Xms100M -Xmx100M Harness -n 5 -c probe.DacapoChopinCallback fop
```

You will see the following output:

<details>
  <summary><b>Output detail</b></summary>

```console
# MMTK_PLAN=Immix /root/bench/builds/jdk-lxr/jdk/bin/java -XX:MetaspaceSize=1G -XX:-UseBiasedLocking -XX:-TieredCompilation -XX:+UnlockDiagnosticVMOptions -XX:-InlineObjectCopy -Djava.library.path=/root/probes -cp /root/probes:/root/probes/probes.jar:/usr/share/benchmarks/dacapo/dacapo-evaluation-git-29a657f.jar -XX:+UseThirdPartyHeap -Dprobes=RustMMTk -Xms100M -Xmx100M Harness -n 5 -c probe.DacapoChopinCallback fop
-------------------- Immix Args --------------------
 * barrier: "FieldLoggingBarrier"
 * barrier_measurement: false
 * instrumentation: false
 * ix_block_only: false
 * ix_defrag: false
 * ix_lock_free_block_allocation: true
 * ix_concurrent_marking: true
 * ix_ref_count: true
 * lxr_lazy_decrements: true
 * lxr_nursery_evacuation: true
 * lxr_mature_evacuation: true
 * lxr_evacuate_nursery_in_recycled_lines: false
 * lxr_delayed_nursery_evacuation: false
 * disable_mutator_line_reusing: false
 * lock_free_blocks: 96
 * nursery_blocks: Some(3072)
 * nursery_ratio: None
 * low_concurrent_worker_priority: false
 * concurrent_worker_ratio: 50
 * concurrent_marking_threshold: 90
 * ignore_reusing_blocks: true
 * log_block_size: 15
 * log_line_size: 8
 * enable_non_temporal_memset: true
 * max_mature_defrag_blocks: 128
 * max_mature_defrag_mb: 4
 * no_gc_until_lazy_sweeping_finished: false
 * log_bytes_per_rc_lock_bit: 9
 * heap_health_guided_gc: false
 * count_bytes_for_mature_evac: true
----------------------------------------------------
--------------------------------------------------------------------------------
IMPORTANT NOTICE:  This is NOT a release build of the DaCapo suite.
Since it is not an official release of the DaCapo suite, care must be taken when
using the suite, and any use of the build must be sure to note that it is not an
offical release, and should note the relevant git hash.

Feedback is greatly appreciated.   The preferred mode of feedback is via github.
Please use our github page to create an issue or a pull request.
    https://github.com/dacapobench/dacapobench.
--------------------------------------------------------------------------------

===== DaCapo evaluation-git-29a657f fop starting warmup 1 =====
===== DaCapo evaluation-git-29a657f fop completed warmup 1 in 5099 msec =====
===== DaCapo evaluation-git-29a657f fop starting warmup 2 =====
===== DaCapo evaluation-git-29a657f fop completed warmup 2 in 1907 msec =====
===== DaCapo evaluation-git-29a657f fop starting warmup 3 =====
===== DaCapo evaluation-git-29a657f fop completed warmup 3 in 1413 msec =====
===== DaCapo evaluation-git-29a657f fop starting warmup 4 =====
===== DaCapo evaluation-git-29a657f fop completed warmup 4 in 1144 msec =====
===== DaCapo evaluation-git-29a657f fop starting =====
============================ MMTk Statistics Totals ============================
pauses  time.other      time.stw        work.RCSweepMatureLOS.time.total        work.RCReleaseUnallocatedNurseryBlocks.count    work.RCReleaseMatureLOS.time.max        work.Release.time.min work.ScanJNIHandlesRoots.count  work.ScanUniverseRoots.time.max work.Prepare.time.max   work.ScanManagementRoots.time.max       work.FlushMatureEvacRemsets.count     work.ScanStackRoot.count        work.ScanStringTableRoots.count work.RCReleaseUnallocatedNurseryBlocks.time.total       work.PrepareChunk.time.max      work.ScanStackRoot.time.max   work.ScheduleCollection.time.min        work.ProcessIncs.time.total     work.ScanJNIHandlesRoots.time.min       work.Release.time.total total-work.time.totalwork.RCReleaseMatureLOS.time.min work.RCReleaseUnallocatedNurseryBlocks.time.min work.ScanManagementRoots.count  work.ProcessIncs.time.min       work.ProcessModBufSATB.time.total     work.ScanAOTLoaderRoots.count   work.EvacuateMatureObjects.count        work.ScanUniverseRoots.count    work.ScanCodeCacheRoots.time.max        work.ScanSystemDictionaryRoots.time.total     work.ScanSystemDictionaryRoots.time.max work.ScanUniverseRoots.time.min work.ScanWeakProcessorRoots.time.max    work.RCSweepNurseryBlocks.count work.Release.count    total-work.count        work.ScanAOTLoaderRoots.time.max        work.RCSweepMatureLOS.time.max  work.ScanJvmtiExportRoots.count work.StopMutators.time.min   work.SweepDeadCyclesChunk.time.max       work.EndOfGC.count      work.RCImmixCollectRootEdges.count      work.SelectDefragBlocksInChunk.count    work.RCSweepMatureLOS.time.minwork.ScanStringTableRoots.time.max      work.ScanVMThreadRoots.time.total       work.LXRStopTheWorldProcessEdges.time.total     work.RCImmixCollectRootEdges.time.max   work.ScanJNIHandlesRoots.time.total   work.ScanStringTableRoots.time.min      work.ScheduleCollection.time.total      work.Prepare.count      work.ImmixConcurrentTraceObjects.time.min     work.ScanWeakProcessorRoots.time.min    work.PrepareChunk.time.total    work.RCSweepNurseryBlocks.time.max      work.SweepBlocksAfterDecs.count work.MatureSweeping.time.max  work.ScanVMThreadRoots.count    total-work.time.min     work.ScanSystemDictionaryRoots.count    work.ScanObjectSynchronizerRoots.time.total     work.ScheduleCollection.count work.ProcessModBufSATB.count    work.SelectDefragBlocksInChunk.time.total       work.RCSweepNurseryBlocks.time.total    work.RCReleaseUnallocatedNurseryBlocks.time.max       work.ScanJvmtiExportRoots.time.total    work.MatureSweeping.count       work.LXRStopTheWorldProcessEdges.time.min       work.ScanJNIHandlesRoots.time.max       work.StopMutators.time.total  work.ImmixConcurrentTraceObjects.time.max       work.ScheduleCollection.time.max        work.StopMutators.time.max      work.ScanClassLoaderDataGraphRoots.count      work.ProcessIncs.count  work.FlushMatureEvacRemsets.time.min    work.EndOfGC.time.min   work.ImmixConcurrentTraceObjects.count  work.ScanObjectSynchronizerRoots.time.min     work.ScanStackRoot.time.total   work.LXRStopTheWorldProcessEdges.count  work.LXRStopTheWorldProcessEdges.time.max       work.ScanObjectSynchronizerRoots.time.max     work.ScanAOTLoaderRoots.time.min        work.FlushMatureEvacRemsets.time.max    work.ImmixConcurrentTraceObjects.time.total     work.ScanSystemDictionaryRoots.time.min       work.FlushMatureEvacRemsets.time.total  work.ScanClassLoaderDataGraphRoots.time.total   work.EndOfGC.time.total work.EvacuateMatureObjects.time.max     total-work.time.max   work.ProcessDecs.time.min       work.ScanClassLoaderDataGraphRoots.time.min     work.ScanJvmtiExportRoots.time.max      work.ProcessModBufSATB.time.max work.SweepDeadCyclesChunk.time.total  work.SelectDefragBlocksInChunk.time.max work.SweepBlocksAfterDecs.time.total    work.Prepare.time.total work.ScanVMThreadRoots.time.min work.ScanCodeCacheRoots.time.min      work.MatureSweeping.time.total  work.RCImmixCollectRootEdges.time.min   work.SweepBlocksAfterDecs.time.max      work.ScanVMThreadRoots.time.max work.MatureSweeping.time.min  work.ScanStackRoot.time.min     work.RCSweepMatureLOS.count     work.SweepDeadCyclesChunk.time.min      work.ProcessModBufSATB.time.min work.ProcessDecs.time.total   work.ScanClassLoaderDataGraphRoots.time.max     work.ScanUniverseRoots.time.total       work.SweepBlocksAfterDecs.time.min      work.ScanCodeCacheRoots.time.total    work.ScanObjectSynchronizerRoots.count  work.SelectDefragBlocksInChunk.time.min work.Release.time.max   work.ScanStringTableRoots.time.total    work.Prepare.time.minwork.RCReleaseMatureLOS.time.total       work.ScanManagementRoots.time.total     work.ScanAOTLoaderRoots.time.total      work.ProcessDecs.count  work.RCSweepNurseryBlocks.time.min    work.PrepareChunk.time.min      work.EvacuateMatureObjects.time.total   work.RCImmixCollectRootEdges.time.total work.ScanWeakProcessorRoots.time.total  work.ScanWeakProcessorRoots.count     work.RCReleaseMatureLOS.count   work.PrepareChunk.count work.ProcessDecs.time.max       work.EndOfGC.time.max   work.ScanManagementRoots.time.min    work.EvacuateMatureObjects.time.min      work.ScanCodeCacheRoots.count   work.ProcessIncs.time.max       work.SweepDeadCyclesChunk.count work.ScanJvmtiExportRoots.time.min   work.StopMutators.count  gc.rc   gc.initial_satb gc.final_satb   gc.full gc.emergency
16      1018.15 42.21   51669.00        16      17884.00        4709.00 16      164559.00       6653.00 97793.00        8       192     16      29423.00        26780.00     693763.00        3997.00 173494856.00    1522.00 276197.00       924417593.00    461.00  190.00  16      331.00  340983.00       16      1325    16      1041516.00      617639.00     177032.00       1954.00 132570.00       3072    16      41131   4429.00 11512.00        16      101320.00       793651.00       16      1440    184     1974.00 311245.00     168778.00       41975101.00     15159.00        198625.00       119014.00       205237.00       16      90.00   26640.00        2901773.00      32952.00        768  39484.00 16      80.00   16      61746.00        16      21      2275263.00      8641967.00      15429.00        48802.00        8       90.00   87204.00        3828259.00   623170.00        23093.00        361348.00       16      4475    11031.00        45846.00        23361   491.00  13346602.00     4832    203592.00       36659.00        401.0075662.00        574482591.00    6903.00 349318.00       2658772.00      3054738.00      137238.00       1041516.00      230.00  105618.00       9297.00 57909.00        39945941.00   77696.00        2053208.00      44575.00        1793.00 736774.00       255531.00       110.00  39935.00        105488.00       24957.00        1563.00 8       29606.00      982.00  5420324.00      235062.00       693896.00       80.00   13854750.00     16      2735.00 41858.00        3248102.00      1212.00 89298.00        166204.00    20661.00 765     80.00   3286.00 28128982.00     725207.00       762575.00       16      16      184     132800.00       221295.00       1393.00 571.00  16      807416.00    184      832.00  16      0       8       8       0       0
Total time: 1060.36 ms
------------------------------ End MMTk Statistics -----------------------------
===== DaCapo evaluation-git-29a657f fop PASSED in 1060 msec =====
```
</details>

The data table between `MMTk Statistics Totals` and `End MMTk Statistics` is the performance results we're interested in.

## [Table 4] Latency evaluation

```console
# cd /root
# running runbms /root/bench/results /root/bench/latency.yml 8 4 -p latency -i 20
```

This will run the latency experiment and generate all required results.

Each benchmarks will be run 20 times to produce relatively stable results. Feel free to decrease `-i 20` to a smaller value to shorten the experiment time, or increase it to reduce noise.

### Check results

Results are stored at `/root/bench/results/`. You'll see a folder with the name starting with `latency-` (should looks like `latency-41e9f1e1e2ea-2022-03-04-Fri-021548`).

Each log file contains the results for all the `20` invocations of a benchmark. For each invocation, there is a line in the log file starting with `===== DaCapo metered tail latency:` that contains the tail latency results. Please collect the results across invocations and calculate the mean value.

Note: LXR latency in Table 1 is also derived from this result.

## [Table 6] Throughput evaluation

```console
# cd /root
# running runbms /root/bench/results /root/bench/xput.yml 8 4 -p xput -i 20
```

This will run the throughput experiment and generate all required results.

Each benchmarks will be run 20 times to produce relatively stable results. Feel free to decrease `-i 20` to a lower value to shorten the experiment time, or increase it to further reduce noise.

### Check results

Results are stored at `/root/bench/results/`. You'll see a folder with the name starting with `xput-`.

Each log file contains the results for all the `20` invocations of a benchmark. For each invocation, please extract the `time` column from the data table and calculate the mean value as the average running time for this benchmark.

## [Figure 1] Latency curve

Please [produce the results of Table 4](#table-4-latency-evaluation) first. We'll use the results of the table 4 evaluation for latency curve plotting.

Run `ls /root/bench/results` and find the result data folder with the name starting with `latency-`.

Say if we have the data folder name as `latency-41e9f1e1e2ea-2022-03-04-Fri-021548`, then please run:

```console
# cd /root
# ./bench/latency-curve.py latency-41e9f1e1e2ea-2022-03-04-Fri-021548
```

This will generate three png files under `/root/` containing the latency curve graphs. File names should be `latency-lusearch.jpg`, `latency-h2.jpg` and `latency-tomcat.jpg`.

Note that cassandra is excluded from the evaluation, due to the docker issues.

## Reusable artifact

To demonstrate the reusability of the artifact, we'll provide steps to modify the parameters in LXR GC source code to produce a new LXR GC with new configuration.

The default LXR configuration enables lazy concurrent ref-count decrement processing to minimize pause time. Here, we will disable this feature and make ref-count decrement processing happen in GC pauses. This will produce a new LXR that (hopefully) has relatively better throughput but worse tail latency.

Steps:

1. Open `/root/mmtk-core/Cargo.toml` (We've installed `vim` in the image. Feel free to use other editors)
2. At line 107, change `lxr = ["lxr_basic", "lxr_cm", "lxr_lazy", "lxr_evac"]` to `lxr = ["lxr_basic", "lxr_cm", "lxr_evac"]`.
3. Build the new LXR by running `~/bench/build.sh --features lxr`
4. Run a simple benchmark: `MMTK_PLAN=Immix /root/mmtk-openjdk/repos/openjdk/build/linux-x86_64-normal-server-release/jdk/bin/java -XX:MetaspaceSize=1G -XX:-UseBiasedLocking -XX:-TieredCompilation -XX:+UnlockDiagnosticVMOptions -XX:-InlineObjectCopy -Djava.library.path=/root/probes -cp /root/probes:/root/probes/probes.jar:/usr/share/benchmarks/dacapo/dacapo-evaluation-git-29a657f.jar -XX:+UseThirdPartyHeap -Dprobes=RustMMTk -Xms100M -Xmx100M Harness -n 5 -c probe.DacapoChopinCallback fop`
   * Note that the built jdk is at `/root/mmtk-openjdk/repos/openjdk/build/linux-x86_64-normal-server-release`.
5. You'll see similar output as the [getting started section](#2-run-simple-benchmark). Except, in the `-------------------- Immix Args --------------------` section at the very begining of the output, you'll see ` * lxr_lazy_decrements: false` instead of ` * lxr_lazy_decrements: true`.
