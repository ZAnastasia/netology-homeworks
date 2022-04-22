import functools
import hashlib
import math
import os
import random
import re
from collections import Counter, OrderedDict
from random import choices

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import presto  # https://github.com/prestosql/presto-python-client
import scipy
import seaborn as sns
from datetime import datetime, timedelta
from IPython.display import display
from pandas.io.json._normalize import nested_to_record
from scipy import stats
from scipy.stats import norm
from statsmodels.stats.multitest import multipletests


def _t_stat(a, b):
    """
	Calculates t-statistic for two Pandas.Series
    """
    return (a.mean() - b.mean()) / np.sqrt(a.var() / len(a) + b.var() / len(b))


def _bootstrap(df, measures, iters=5000, alpha=0.05, random_state=1, verbose=True):
    """
    Checks whether [measures] means are approx. equal across (!) Test groups (!) compared to (!) Control 1 (!)

    Returns a dictionary of this kind: {'ar': [0.6866], 'GH': [0.619], 'num_rides': [0.9132]}

    Parameters:
    --------------

    df:
        Dataframe with column "groups" - obtained from _split_to_groups() function.
    measures:
        list of features to be compared across Test groups vs Control group
    iters:
        number of samples with replacements
    alpha:
        Type I error probability
    verbose: Boolean - optional
        whether to print annoying statements :)
        
    Sources:
    1. Chapter 16 of Bradley Efron and Robert J. Tibshirani (1993) An Introduction to the Bootstrap. Boca Raton: Chapman & Hall/CRC.
    2. https://en.wikipedia.org/wiki/Bootstrapping_(statistics)#Bootstrap_hypothesis_testing
    
    """
    random.seed(random_state)

    pval_dictio = {}  # dictionary for measures` p-value
    for measure in measures:

        if verbose:
            print("We are checking", measure, "feature")

        control = df[df["groups"] == "Control 1"][measure]
        # groups to be compared with Control 1
        groups = list(
            filter(lambda x: "control 1" not in x.lower(), df["groups"].unique())
        )
        groups.sort()  # from Control ascending to Test ascending

        if verbose:
            print(f"Sorted groups: {groups}")

        tests_vs_control_pval = []
        for group in groups:
            measure_data = df[measure]
            test = df[df["groups"] == group][measure]
            # if control exceeds test, makes sense to test whether control is significantly better
            sign = np.sign(test.mean() - control.mean())

            if verbose:
                print(
                    f"Initial means: {group}: {test.mean()}; Control 1: {control.mean()}"
                )

            # if Test group metric has smaller value, we will change the test direction (see upper comment)
            if sign < 0:
                test, control = control, test

            # 1
            t_stat_h0 = _t_stat(test, control)
            # 2
            new_test = np.array(test - test.mean() + measure_data.mean())
            new_control = np.array(control - control.mean() + measure_data.mean())

            # Generating samples
            bootstrap_Test = np.random.choice(
                new_test, size=(iters, len(new_test)), replace=True
            )
            bootstrap_Control = np.random.choice(
                new_control, size=(iters, len(new_control)), replace=True
            )

            # Averaging for each sample
            x_bar_star = np.mean(bootstrap_Test, axis=1)
            y_bar_star = np.mean(bootstrap_Control, axis=1)

            # Variance for each sample
            x_var_star = np.var(bootstrap_Test, axis=1)
            y_var_star = np.var(bootstrap_Control, axis=1)

            # t-stats
            t_stats = (x_bar_star - y_bar_star) / np.sqrt(
                x_var_star / len(new_test) + y_var_star / len(new_control)
            )

            # p_value
            pvalue = sign * sum(t_stats >= t_stat_h0) / iters

            tests_vs_control_pval.append(pvalue)

            if verbose:
                if abs(pvalue) <= alpha:
                    print(
                        f"REJECT H0: there is significant difference between test and control. p-value: {pvalue}"
                    )
                else:
                    print(f"FAIL TO REJECT H0. p-value: {pvalue}")

        pval_dictio[measure] = tests_vs_control_pval

    return pval_dictio


def _hash_generate_groups(x, n_buckets, random_state=1):
    """
    Returns a random bucket for a measure, given overall number of buckets.
    """
    random.seed(random_state)

    return (
        int(
            re.sub(
                "[^0-9]", "", hashlib.md5("{}".format(x).encode("utf-8")).hexdigest(),
            )
        )
        + np.random.randint(0, n_buckets)
    ) % n_buckets


def _partial__bucket_test(
    df, measures, n_buckets, alpha, plot, random_state=1, verbose=True
):
    """Returns a dictionary with pvalues for each group for each measure."""

    assert "groups" in df.columns, Exception(
        "'groups' column with group names not found!"
    )

    # creating buckets. (_hash_generate_groups() can be applied to any column)
    df["_buckets"] = df["groups"].apply(
        lambda x: _hash_generate_groups(
            x, n_buckets=n_buckets, random_state=random_state
        )
    )
    ttest_final = {}
    for measure in measures:
        if verbose:
            print(f"Exploring {measure}")

        # dataframe for further groups comparison
        grouper = df.groupby(["groups", "_buckets"]).agg({measure: np.mean})
        groups = df["groups"].unique()
        groups.sort()
        if verbose:
            print(f"Groups order: {groups}")

        # getting p-values of the Normality test
        normaltest_results = {
            group: scipy.stats.normaltest(grouper.loc[group]).pvalue[0]
            for group in groups
        }
        if verbose:
            print("Normality test results: ", normaltest_results, "\n")

        if any(filter(lambda x: x < alpha, list(normaltest_results.values()))):
            if verbose:
                print(
                    "Failed to get to normal distribution for measure: {}".format(
                        measure
                    )
                )
                print("Normality test results: ", normaltest_results)
            return None

        # CAUTION: ttest_ind() returns two-sided p-value, but we need one-sided
        # so we divide by 2, but also need to know the sign of t-stat

        # ttest_results = {group: scipy.stats.ttest_ind(grouper.loc['Control 1'], \
        #                                               grouper.loc[group]).pvalue[0] / 2 \
        #                  for group in groups if 'Control' not in group}

        ttest_results = []
        for group in [el for el in groups if "control" not in el.lower()]:
            res = scipy.stats.ttest_ind(grouper.loc["Control 1"], grouper.loc[group])
            ttest_results.append(res.pvalue[0] * np.sign(res.statistic[0]) / 2)
            assert res.pvalue >= 0, Exception("p-value is negative for some reason...")
        ttest_final[measure] = ttest_results

    if plot:
        for measure in measures:
            plt.tight_layout()
            plt.figure(figsize=(8, 5))
            plt.subplot(len(measures), 1, measures.index(measure) + 1)
            sns.distplot(df.groupby("_buckets").agg({measure: np.mean})[measure])
            plt.title("Bucketed {} distribution".format(measure))
            plt.xlabel(measure)
            plt.ylabel("Density")
            plt.grid()
            plt.show()

    return ttest_final


def _bucket_test(
    df,
    measures,
    n_buckets=None,
    min_obs_per_bucket=25,
    min_buckets=100,
    alpha=0.05,
    plot=False,
    max_iters=7,
    random_state=1,
    verbose=True,
):
    """
    Returns a dictionary of dictionaries with a p-value
        (based on the appropriate ranking test) for each measure for each group.

    Parameters:
    --------------
    df:
        Dataframe with column "groups" - obtained from _split_to_groups() function.
    measures:
        list of features to be compared across Test groups vs Control group
    n_buckets: int
        # buckets to split each metric into
    min_obs_per_bucket:
        minimal number of observations per bucket
    min_buckets:
        minimal number of buckets
    alpha:
        Type I error probability (used while getting to normal distribution)
    plot: [True, False] - optional
        whether to plot a "bucketed" distribution for each measure
    max_iters:
        maximal number of iterations allowed to try splitting into bucket
        to get normal distribution
    """

    assert isinstance(measures, list), Exception(
        '"measures" argument must be of type: list'
    )
    assert "groups" in df.columns, Exception(
        "Column 'groups' with group names not found!"
    )

    # INCORRECT LOGIC! NEED AN ASSERTION THAT ENOUGH OBSERVATIONS ARE PRESENT FOR EACH (!!!) GROUP!!! ALSO, ASSERT UNIQUE user_id COLUMN!!!
    if any(
        df.groupby("groups").agg({measures[0]: len}).values.flatten()
        < min_buckets * min_obs_per_bucket
    ):
        if verbose:
            print(
                "Too few observations to create {} buckets with at least {} obs. each. \
                \nChange settings or use another test.".format(
                    min_buckets, min_obs_per_bucket
                )
            )
        return None

    n_buckets = n_buckets or min_buckets
    if verbose:
        print("> Buckets: ", n_buckets, "\n")

    ret = _partial__bucket_test(
        df=df,
        measures=measures,
        n_buckets=n_buckets,
        alpha=alpha,
        plot=plot,
        verbose=verbose,
    )
    num_iters = 0
    while (not ret) and num_iters <= max_iters:
        num_iters += 1
        if verbose:
            print("\n> TRYING AGAIN...\n")
        ret = _partial__bucket_test(
            df=df,
            measures=measures,
            n_buckets=n_buckets,
            alpha=alpha,
            plot=plot,
            verbose=verbose,
        )
    if not ret:
        if verbose:
            print(
                "\n> MAX_ITERS LIMIT REACHED! FAILED TO GET TO NORMAL DISTRIBUTION.\
            \nINCREASE MAX_ITERS OR SKIP THE TEST."
            )
        return None
    return ret