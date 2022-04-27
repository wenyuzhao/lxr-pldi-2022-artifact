# [**PLDI'22 Artifact**] Low-Latency, High-Throughput Garbage Collection

We ship our artifact as a docker image, containing the pre-built OpenJDK builds (with LXR GC) and all necessary benchmarks for evaluation.

This documentation shows the steps to fetch the image, and reproduce all the key results in the paper.

Please refer to https://github.com/wenyuzhao/mmtk-core/tree/lxr-pldi-2022 for latest implementation, and [this repo](https://github.com/wenyuzhao/lxr-pldi-2022-artifact) for the instructions to reproduce the results in our paper.

## Table of Contents

* [Prepare](#prepare)
  * [Platform requirements](#platform-requirements)
  * [Source code](#source-code)
  * [Warnings for fully reproducible results](#warnings-for-fully-reproducible-results)
* [Getting started](#getting-started)
* [Table 4 - Latency evaluation](#table-4-latency-evaluation)
* [Table 6 - Throughput evaluation](#table-6-throughput-evaluation)
* [Figure 5 - Latency Curve](#figure-1-latency-curve)
* [Build the docker image](#build-the-docker-image)

## Prepare

### Platform requirements

Here we list the machine details we used for our experiments in the paper.

* OS: Ubuntu 18.04 (optionally, with docker installed).
* Memory: At least 16GB. We use 64GB DDR4 3200MHz for our evaluation in the paper.
* CPU: AMD Zen 3 5950X (16/32 cores, 3.4 GHz, 64 MB LLC).
* At least 70 GB of disk space. We use an NVMe SSD.

Please make your machine as close to the configuration avobe as possible. Otherwise, you will likely to get a different result. For more details please refer to the sensitivity or treats to validity sections in our paper.

### Source code

Source code is available at:
* https://github.com/wenyuzhao/mmtk-core/tree/lxr-pldi-2022 (commit 4d4e516)
* https://github.com/wenyuzhao/mmtk-openjdk/tree/lxr-pldi-2022 (commit abbdd1db)
* https://github.com/mmtk/openjdk/commit/f817e9d00b2850221bb9443443a123e38e81a129

### Warnings for fully reproducible results

#### Cassandra benchmark may not run

Due to the restrictions of docker, cassandra or even other benchmarks can be sliently killed by docker because of a large amount of memory reservations.

To fully reproduce all the results with minimal experiment error, feel free to run the experiment on a native host. You can easily do that by copying out all the folders under `/root` to the host machine's `/root` directory.  You may also need to run `pip3 install running-ng` on your native machine to install the benchmark running tool.

#### Some benchmarks may not run with ZGC

As discussed in our paper, ZGC in openjdk 11 sets a minimium heap requirement that is larger than the heap size of some of the benchmarks. For these benchmarks we will not report ZGC results.

#### Benchmark running time

Please note that benchmarks may take over a day to complete.

For benchmarks triggered by our `running` command (see detailed instructions in the following sections), feel free to decrease the command argument `-i 20` to a smaller value to reduce the experiment time, or increase it to further reduce noise.

#### Noise and errors

Running inside a docker container can bring some overheads as well. Feel free to use a native host to run the experiment, as explained above.

**_Important notes:_ To minimize noise, you should ensure that you're the only user logged in to the machine. There should be no other resource-consuming programs running during benchmarking, except the benchmark programs. We recommend using a tmux session to run the benchmark, and the user, or the "operator" should log out of the machine right after the benchmark starts.**

#### Evaluations not included in this artifact

In our paper we have a few experiments and analysis on openjdk GCs, LXR itself, as well as the benchmark characteristics. These results are not the _key_ claims of the paper, so we do not evaluate and reproduce them in this artifact.

## Getting started

### 1. Pull docker image, launch and enter container

```console
$ sudo docker pull wenyuzhao/lxr # Pull docker image
$ sudo docker run -dit --privileged -m 16g --name lxr wenyuzhao/lxr # Launch container
$ sudo docker exec -it lxr /bin/bash # Login into the container
```

We've already included the LXR build into our image, located at `/root/bench/builds/jdk-lxr`.

### 2. Run simple benchmark

Run a simple benchmark using our pre-built LXR GC and check the output results. This will ensure that the builds in the image are functional.

Note that our GC implementation is not as stable as OpenJDK GCs. If you run into an error, try re-run it a few more times.

Please cd to `/root` and run:

```console
# MMTK_PLAN=Immix TRACE_THRESHOLD2=10 LOCK_FREE_BLOCKS=32 MAX_SURVIVAL_MB=256 SURVIVAL_PREDICTOR_WEIGHTED=1 /root/bench/builds/jdk-lxr/jdk/bin/java -XX:MetaspaceSize=1G -XX:-UseBiasedLocking -XX:-TieredCompilation -XX:+UnlockDiagnosticVMOptions -XX:-InlineObjectCopy -Djava.library.path=/root/probes -cp /root/probes:/root/probes/probes.jar:/root/dacapo/dacapo-evaluation-git-b00bfa9.jar -XX:+UseThirdPartyHeap -Dprobes=RustMMTk -Xms100M -Xmx100M Harness -n 5 -c probe.DacapoChopinCallback lusearch
```

You will see the following output:

<details>
  <summary><b>Output detail</b></summary>

```console
# MMTK_PLAN=Immix TRACE_THRESHOLD2=10 LOCK_FREE_BLOCKS=32 MAX_SURVIVAL_MB=256 SURVIVAL_PREDICTOR_WEIGHTED=1 /root/bench/builds/jdk-lxr/jdk/bin/java -XX:MetaspaceSize=1G -XX:-UseBiasedLocking -XX:-TieredCompilation -XX:+UnlockDiagnosticVMOptions -XX:-InlineObjectCopy -Djava.library.path=/root/probes -cp /root/probes:/root/probes/probes.jar:/root/dacapo/dacapo-evaluation-git-b00bfa9.jar -XX:+UseThirdPartyHeap -Dprobes=RustMMTk -Xms100M -Xmx100M Harness -n 5 -c probe.DacapoChopinCallback lusearch
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
 * lxr_enable_initial_alloc_limit: false
 * disable_mutator_line_reusing: false
 * lock_free_blocks: 32
 * nursery_blocks: None
 * nursery_ratio: None
 * low_concurrent_worker_priority: false
 * concurrent_worker_ratio: 50
 * concurrent_marking_threshold: 90
 * ignore_reusing_blocks: true
 * log_block_size: 15
 * log_line_size: 8
 * enable_non_temporal_memset: false
 * max_mature_defrag_percent: 15
 * no_gc_until_lazy_sweeping_finished: false
 * log_bytes_per_rc_lock_bit: 9
 * heap_health_guided_gc: true
 * count_bytes_for_mature_evac: true
 * opportunistic_evac: false
 * opportunistic_evac_threshold: 50
 * incs_limit: None
 * lxr_rc_only: false
 * lxr_trace_threshold: 20.0
 * max_survival_mb: Some(256)
 * survival_predictor_harmonic_mean: false
 * survival_predictor_weighted: true
 * trace_threshold2: Some(10)
 * max_copy_size: 2048
 * buffer_size: 1024
 * nontemporal: false
 * cm_large_array_optimization: true
 * lazy_mu_reuse_block_sweeping: true
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

Using scaled threading model. 8 processors detected, 8 threads used to drive the workload, in a possible range of [1,2048]
===== DaCapo evaluation-git-b00bfa9 lusearch starting warmup 1 =====
Completing query batches: 100%
===== DaCapo evaluation-git-b00bfa9 lusearch completed warmup 1 in 18305 msec =====
===== DaCapo simple tail latency: 50% 69 usec, 90% 445 usec, 99% 1572 usec, 99.9% 8900 usec, 99.99% 16401 usec, max 47697 usec, measured over 524288 events =====
===== DaCapo metered tail latency: 50% 995422 usec, 90% 1820552 usec, 99% 1906210 usec, 99.9% 1916172 usec, 99.99% 1921226 usec, max 1931143 usec, measured over 524288 events =====
===== DaCapo evaluation-git-b00bfa9 lusearch starting warmup 2 =====
Completing query batches: 100%
===== DaCapo evaluation-git-b00bfa9 lusearch completed warmup 2 in 17459 msec =====
===== DaCapo simple tail latency: 50% 67 usec, 90% 458 usec, 99% 1261 usec, 99.9% 6873 usec, 99.99% 13459 usec, max 45045 usec, measured over 524288 events =====
===== DaCapo metered tail latency: 50% 68 usec, 90% 480 usec, 99% 4168 usec, 99.9% 11242 usec, 99.99% 14346 usec, max 45045 usec, measured over 524288 events =====
===== DaCapo evaluation-git-b00bfa9 lusearch starting warmup 3 =====
Completing query batches: 100%
===== DaCapo evaluation-git-b00bfa9 lusearch completed warmup 3 in 18550 msec =====
===== DaCapo simple tail latency: 50% 72 usec, 90% 489 usec, 99% 1405 usec, 99.9% 7508 usec, 99.99% 14094 usec, max 34682 usec, measured over 524288 events =====
===== DaCapo metered tail latency: 50% 109 usec, 90% 16949 usec, 99% 55472 usec, 99.9% 64885 usec, 99.99% 67246 usec, max 72483 usec, measured over 524288 events =====
===== DaCapo evaluation-git-b00bfa9 lusearch starting warmup 4 =====
Completing query batches: 100%
===== DaCapo evaluation-git-b00bfa9 lusearch completed warmup 4 in 17384 msec =====
===== DaCapo simple tail latency: 50% 68 usec, 90% 464 usec, 99% 1328 usec, 99.9% 6963 usec, 99.99% 13346 usec, max 33206 usec, measured over 524288 events =====
===== DaCapo metered tail latency: 50% 126 usec, 90% 34378 usec, 99% 62011 usec, 99.9% 68218 usec, 99.99% 70939 usec, max 74394 usec, measured over 524288 events =====
===== DaCapo evaluation-git-b00bfa9 lusearch starting =====
Completing query batches: 100%
============================ MMTk Statistics Totals ============================
pauses  time.other      time.stw        gc.rc   gc.initial_satb gc.final_satb   gc.full gc.emergency    cm_early_quit   gc_with_unfinished_lazy_jobs    time.yield      time.roots      time.satb       total_used_pages        min_used_pages     max_used_pages  incs_triggerd   alloc_triggerd  survival_triggerd       overflow_triggerd       rc_during_satb
525     16232.78        1151.63 439     43      43      0       0       0       0       0       0       0       4428690 5808    10933   0       0       0       525     0
Total time: 17384.40 ms
------------------------------ End MMTk Statistics -----------------------------
===== DaCapo evaluation-git-b00bfa9 lusearch PASSED in 17384 msec =====
===== DaCapo simple tail latency: 50% 66 usec, 90% 454 usec, 99% 1375 usec, 99.9% 7203 usec, 99.99% 14140 usec, max 50680 usec, measured over 524288 events =====
===== DaCapo metered tail latency: 50% 58359 usec, 90% 109886 usec, 99% 129627 usec, 99.9% 141334 usec, 99.99% 146067 usec, max 150553 usec, measured over 524288 events =====
```
</details>

The data table after `MMTk Statistics Totals` is the performance results we're interested in. Specifically, the "Total time:" in the table is the throughput of the benchmark. The _last_ "DaCapo metered tail latency" record is the tail latency of the benchmark.

Note that the benchmark runs for 5 iterations. Iterations 1-4 are the warmup runs, and the 5-th iteration is the actual benchmark run. We always ignore the throughput or latency results reported from the warmup iterations, and only report the last iteration results.

When doing evaluations, we usually run the above runs for at least 20 times (i.e. 20 _invocations_) to reduce the noise.


## [Table 4] Latency evaluation

```console
# cd /root
# running runbms /root/bench/results /root/bench/latency.yml 32 7 -p latency -i 20
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
# running runbms /root/bench/results /root/bench/throughput.yml 12 7 -p throughput -i 20
```

This will run the throughput experiment and generate all required results.

Each benchmarks will be run 20 times to produce relatively stable results. Feel free to decrease `-i 20` to a lower value to shorten the experiment time, or increase it to further reduce noise.

### Check results

Results are stored at `/root/bench/results/`. You'll see a folder with the name starting with `throughput-`.

Each log file contains the results for all the `20` invocations of a benchmark. For each invocation, please extract the `time` column from the data table and calculate the mean value as the average running time for this benchmark.

## [Figure 5] Latency curve

Please [produce the results of Table 4](#table-4-latency-evaluation) first. We'll use the results of the table 4 evaluation for latency curve plotting.

Run `ls /root/bench/results` and find the result data folder with the name starting with `latency-`.

Say if we have the data folder name as `latency-41e9f1e1e2ea-2022-03-04-Fri-021548`, then please run:

```console
# cd /root
# ./bench/latency-curve.py latency-41e9f1e1e2ea-2022-03-04-Fri-021548
```

This will generate three jpg files under `/root/` containing the latency curve graphs. File names should be `latency-lusearch.jpg`, `latency-cassandra.jpg`, `latency-h2.jpg`, and `latency-tomcat.jpg`.

If you use a docker container, you can use the following commands to copy graphs out to your host machine:

```console
$ sudo docker cp lxr:/root/latency-lusearch.jpg ./
$ sudo docker cp lxr:/root/latency-cassandra.jpg ./
$ sudo docker cp lxr:/root/latency-h2.jpg ./
$ sudo docker cp lxr:/root/latency-tomcat.jpg ./
```

# Build the docker image

Instead of using our pre-build image, you can also choose to build the docker image yourself.


```console
$ git clone https://github.com/wenyuzhao/lxr-pldi-2022-artifact.git
$ cd lxr-pldi-2022-artifact
$ make docker-build # This will fetch all the required files before running `docker build`.
```
