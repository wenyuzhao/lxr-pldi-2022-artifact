#!/usr/bin/env python3
import matplotlib.pyplot as plt
from hdrh.histogram import HdrHistogram
import seaborn as sns
import pandas
from matplotlib import pyplot as plt
import os.path
from enum import Enum
import matplotlib as mpl
from typing import *
import argparse

parser = argparse.ArgumentParser(description='Generate latency curve.')
parser.add_argument('runid', type=str)
parser.add_argument('--invocations', type=int, default=40)

args = parser.parse_args()

INVOCATIONS = args.invocations
RUNID = args.runid

assert os.path.isdir(
    f'/root/bench/results/{RUNID}'), f'Incorrect runid: {RUNID}'

HFAC = 1319
HEAP = {
    'lusearch': 70,
    'cassandra': 347,
    'h2':  1572,
    'tomcat': 94,
}
DACAPO = 'dacapochopin-b00bfa9'
DATA = {
    'G1': RUNID + '/{bench}.{hfac}.{heap}.jdk-lxr.g1.common.hs.latency.{dacapo}',
    'Shen.': RUNID + '/{bench}.{hfac}.{heap}.jdk-lxr.shenandoah.common.hs.latency.{dacapo}',
    'LXR': RUNID + '/{bench}.{hfac}.{heap}.jdk-lxr.ix.common.tph.trace2-5.srv-128.srvw.lfb-32.latency.{dacapo}',
    'ZGC': RUNID + '/{bench}.{hfac}.{heap}.jdk-lxr.z.common.hs.latency.{dacapo}',
}
MAX_INVOCATIONS = max(INVOCATIONS, 40)
MIN_LATENCY_USEC = 1
MAX_LATENCY_USEC = 1000 * 1000  # 1 sec
LATENCY_SIGNIFICANT_DIGITS = 5
LABEL_FONT_SIZE = 60
LEGEND_FONT_SIZE = 60
TICK_FONT_SIZE = 50
SAVE_FILE = 'jpg'
# SAVE_FILE = 'pdf'


def load_data(invocation: int, folder: str):
    path = os.path.realpath(os.path.expanduser(
        '{}.{}/dacapo-latency-usec-metered.csv'.format(folder, invocation)))
    if not os.path.isfile(path):
        return None
    df = pandas.read_csv(path, names=["start", "end"])
    try:
        df["latency"] = df["end"] - df["start"]
    except Exception as e:
        print(path)
        raise e
    return df


def load_data_and_plot(bench, data: Optional[Dict[str, Union[str, List[str]]]] = None, invocations=MAX_INVOCATIONS, save=SAVE_FILE, legend: Union[str, bool] = True, max_percentile='99.999'):
    assert bench in HEAP
    print(f'[{bench}] Loading...')
    histograms = {}
    # Clean up inputs
    if data is None:
        data = {k: v for k, v in DATA.items()}
    for gc in data.keys():
        if isinstance(data[gc], str):
            data[gc] = [data[gc]]
        data[gc] = [
            f'/root/bench/results/{x}'.format(
                runid=RUNID, bench=bench, hfac=HFAC, heap=HEAP[bench], dacapo=DACAPO)
            for x in data[gc]
        ]
    data: Dict[str, List[str]]
    # Load data
    for gc, logs in data.items():
        histograms[gc] = []
        for folder in logs:
            for i in range(invocations):
                loaded_data = load_data(i, folder)
                if loaded_data is None:
                    continue
                histogram = HdrHistogram(
                    MIN_LATENCY_USEC, MAX_LATENCY_USEC, LATENCY_SIGNIFICANT_DIGITS)
                latencies = loaded_data["latency"]
                for l in latencies:
                    histogram.record_value(l)
                histograms[gc].append(histogram)
        if len(histograms[gc]) == 0:
            histogram = HdrHistogram(
                MIN_LATENCY_USEC, MAX_LATENCY_USEC, LATENCY_SIGNIFICANT_DIGITS)
            histogram.record_value(0)
            histograms[gc].append(histogram)
    # Process data
    print(f'[{bench}] Processing...')
    percentile_list = []
    for gc, hists in histograms.items():
        for j, histogram in enumerate(hists):
            for i in histogram.get_percentile_iterator(5):
                percentile_list.append({"GC": gc, "inv": j, "value": i.value_iterated_to,
                                       "percentile": i.percentile_level_iterated_to / 100})
    percentile_df = pandas.DataFrame(percentile_list)
    percentile_df["other"] = 1 / (1 - percentile_df["percentile"])
    # Plot curves
    print(f'[{bench}] Plotting...')
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    # fig.suptitle(f'{bench} {latency_type} latency')
    sns.color_palette()
    # colors = ['green', 'blue', 'orange', 'red'][:len(gcs)]
    # print(f'{gcs} {colors}')
    sns.lineplot(data=percentile_df, x="other", y="value", hue="GC")
    # sns.lineplot(data=percentile_df, x="other", y="value", hue="GC")
    ax.set_xscale('log')
    ax.set_xlabel('Percentile', fontsize=LABEL_FONT_SIZE, labelpad=12)
    ax.set_ylabel('Latency (msec)', fontsize=LABEL_FONT_SIZE, labelpad=12)
    labels = ['0', '90', '99', '99.9', '99.99', '99.999', '99.9999']
    ax.set_xticks([1, 10, 100, 1000, 10000, 100000, 1000000]
                  [:labels.index(max_percentile) + 1])
    ax.set_xticklabels(labels[:labels.index(
        max_percentile) + 1], fontsize=TICK_FONT_SIZE)
    # ax.set_xticks([1, 10, 100, 1000, 10000, 100000])
    # ax.set_xticklabels(['0', '90', '99', '99.9', '99.99', '99.999'], fontsize=TICK_FONT_SIZE)
    plt.yticks(fontsize=TICK_FONT_SIZE)
    ax.yaxis.set_major_formatter(mpl.ticker.FuncFormatter(
        lambda x, pos: f'{int(x / 1000)}'.format(x)))
    handles, labels = plt.gca().get_legend_handles_labels()
    order = [0, 1, 3, 2]
    if legend == False:
        plt.legend([], [], frameon=False)
    elif legend == True:
        plt.legend([handles[i] for i in order], [labels[i]
                   for i in order],  fontsize=LEGEND_FONT_SIZE)
    else:
        plt.legend([handles[i] for i in order], [labels[i]
                   for i in order], fontsize=LEGEND_FONT_SIZE, loc=legend)
    plt.tight_layout()

    if save is not None:
        print(f'[{bench}] Save to latency-{bench}.{save}')
        plt.savefig(f'latency-{bench}.{save}', bbox_inches='tight')


load_data_and_plot(bench='lusearch', legend='upper left')
load_data_and_plot(bench='cassandra', legend='upper left')
load_data_and_plot(bench='h2', legend='upper left', max_percentile='99.99')
load_data_and_plot(bench='tomcat', legend='lower right')
