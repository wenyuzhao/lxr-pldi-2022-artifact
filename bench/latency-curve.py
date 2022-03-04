#!/usr/bin/env python3

from hdrh.histogram import HdrHistogram
import seaborn as sns
import pandas
from matplotlib import pyplot as plt
import os.path
import matplotlib as mpl
from typing import *
import argparse

parser = argparse.ArgumentParser(description='Generate latency curve.')
parser.add_argument('runid', type=str)
parser.add_argument('--invocations', type=int, default=40)

args = parser.parse_args()

INVOCATIONS = args.invocations
RUNID = args.runid

assert os.path.isdir(f'/root/bench/results/{RUNID}'), f'Incorrect runid: {RUNID}'

MIN_LATENCY_USEC = 1
MAX_LATENCY_USEC = 1000*1000 # 1 sec
LATENCY_SIGNIFICANT_DIGITS = 5
latency_types = ["metered", "simple"]
result = lambda runid, buildstring: f'/root/bench/results/{runid}/{buildstring}'

def load_data(invocation, latency_type, folder):
    path = "{}.{}/dacapo-latency-usec-{}.csv".format(folder, invocation, latency_type)
    if not os.path.isfile(path):
        return None
    df =  pandas.read_csv(path, names=["start", "end"])
    df["latency"] = df["end"] - df["start"]
    return df

def load_data_and_plot(bench, gcs, folders_list: List[List[str]], invocations = 10, save = None, latency_type = "metered"):
    print('Loading...')
    histograms = {}
    for gc in gcs:
        histograms[gc] = []
        for i in range(invocations):
            folders = folders_list[gcs.index(gc)]
            for folder in folders:
                histogram = HdrHistogram(MIN_LATENCY_USEC, MAX_LATENCY_USEC, LATENCY_SIGNIFICANT_DIGITS)
                data = load_data(i, latency_type, folder)
                if data is None:
                    continue
                latencies = data["latency"]
                for l in latencies:
                    histogram.record_value(l)
                histograms[gc].append(histogram)

    print('Processing...')
    percentile_list = []
    for gc, hists in histograms.items():
        for j, histogram in enumerate(hists):
            for i in histogram.get_percentile_iterator(5):
                x = i.percentile_level_iterated_to
                percentile_list.append({"GC": gc, "inv": j, "value": i.value_iterated_to, "percentile": i.percentile_level_iterated_to / 100})
    percentile_df = pandas.DataFrame(percentile_list)
    percentile_df["other"] = 1 / (1 - percentile_df["percentile"])

    print('Plotting...')
    fig, ax = plt.subplots(1,1,figsize=(16,12))
    # fig.suptitle(f'{bench} {latency_type} latency')
    sns.color_palette()
    colors = ['green', 'blue', 'orange', 'red'][:len(gcs)]
    print(f'{gcs} {colors}')
    sns.lineplot(data=percentile_df, x="other", y="value", hue="GC")
    # sns.lineplot(data=percentile_df, x="other", y="value", hue="GC")
    ax.set_xscale('log')
    ax.set_xlabel('Percentile', fontsize=26, labelpad=12)
    ax.set_ylabel('Latency (msec)', fontsize=26, labelpad=12)
    ax.set_xticks([1, 10, 100, 1000, 10000, 100000, 1000000])
    ax.set_xticklabels(['0', '90', '99', '99.9', '99.99', '99.999', '99.9999'], fontsize=20)
    plt.yticks(fontsize=20)
    ax.yaxis.set_major_formatter(mpl.ticker.FuncFormatter(lambda x, pos: f'{int(x / 1000)}'.format(x)))
    plt.legend(fontsize=26)

    if save is not None:
        plt.savefig(save, bbox_inches='tight')


# Lusearch

load_data_and_plot(
    bench = 'lusearch',
    gcs = ["LXR", "G1", "Shen."],
    folders_list = [
        # LXR
        [
            result(RUNID, 'lusearch.3023.70.jdk.ix.common.tph.mmtk_perf.nr-1.latency.dacapochopin-29a657f'),
        ],
        # G1
        [
            result(RUNID, 'lusearch.3023.70.jdk.g1.common.hs_perf.latency.dacapochopin-29a657f'),
        ],
        # Shen.
        [
            result(RUNID, 'lusearch.3023.70.jdk.shenandoah.common.hs_perf.latency.dacapochopin-29a657f'),
        ],

    ],
    invocations = INVOCATIONS,
    save = './latency-lusearch.jpg',
)

load_data_and_plot(
    bench = 'cassandra',
    gcs = ["LXR", "G1", "Shen.", "ZGC"],
    folders_list = [
        # LXR
        [
            result(RUNID, 'cassandra.3023.269.jdk.ix.common.tph.mmtk_perf.nr-1.latency.dacapochopin-29a657f'),
        ],
        # G1
        [
            result(RUNID, 'cassandra.3023.269.jdk.g1.common.hs_perf.latency.dacapochopin-29a657f'),
        ],
        # Shen.
        [
            result(RUNID, 'cassandra.3023.269.jdk.shenandoah.common.hs_perf.latency.dacapochopin-29a657f'),
        ],
        # ZGC
        [
            result(RUNID, 'cassandra.3023.269.jdk.z.common.hs_perf.latency.dacapochopin-29a657f'),
        ],
    ],
    invocations = INVOCATIONS,
    save = './latency-cassandra.jpg',
)

load_data_and_plot(
    bench = 'h2',
    gcs = ["LXR", "G1", "Shen.",  "ZGC"],
    folders_list = [
        # LXR
        [
            result(RUNID, 'h2.3023.3489.jdk.ix.common.tph.mmtk_perf.nr-1.latency.dacapochopin-29a657f'),
        ],
        # G1
        [
            result(RUNID, 'h2.3023.3489.jdk.g1.common.hs_perf.latency.dacapochopin-29a657f'),
        ],
        # Shen.
        [
            result(RUNID, 'h2.3023.3489.jdk.shenandoah.common.hs_perf.latency.dacapochopin-29a657f'),
        ],
        # ZGC
        [
            result(RUNID, 'h2.3023.3489.jdk.z.common.hs_perf.latency.dacapochopin-29a657f'),
        ],

    ],
    invocations = 30,
    save = './latency-h2.jpg',
)

load_data_and_plot(
    bench = 'tomcat',
    gcs = ["LXR", "G1", "Shen."],
    folders_list = [
        # LXR
        [
            result(RUNID, 'tomcat.3023.76.jdk.ix.common.tph.mmtk_perf.nr-1.latency.dacapochopin-29a657f'),
        ],
        # G1
        [
            result(RUNID, 'tomcat.3023.76.jdk.g1.common.hs_perf.latency.dacapochopin-29a657f'),
        ],
        # Shen.
        [
            result(RUNID, 'tomcat.3023.76.jdk.shenandoah.common.hs_perf.latency.dacapochopin-29a657f'),
        ],

    ],
    invocations = 30,
    save = './latency-tomcat.jpg',
)