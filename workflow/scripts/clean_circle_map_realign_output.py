import sys

sys.stderr = open(snakemake.log[0], "w")

import pandas as pd

circles = pd.read_csv(
    snakemake.input[0],
    sep="\t",
    names=[
        "chromosome",
        "start",
        "end",
        "discordant_reads",
        "split_reads",
        "circle_score",
        "mean_coverage",
        "standard_deviation_coverage",
        "cov_increase_at_start",
        "cov_increase_at_end",
        "uncovered_fraction",
    ],
)

# Circle-Map returns int chromosome names (e.g. '7') as floats ('7.0'), but we could also have str already (e.g. 'chr7')
circles["chromosome"] = circles["chromosome"].apply(lambda chr: chr if isinstance(chr, str) else str(int(chr)) )

int_cols = [
    "start",
    "end",
    "discordant_reads",
    "split_reads",
]

# turn int cols into int
circles.loc[:, int_cols] = circles.loc[:, int_cols].round(0).applymap(lambda v: int(v) if not pd.isna(v) else pd.NA)

# filter out low-quality circles, according to:
# https://github.com/iprada/Circle-Map/wiki/Circle-Map-Realign-output-files
circles = circles.loc[
    circles["circle_score"] >= 50
]


circles["region"] = circles.agg(
    lambda row: f"{row['chromosome']}:{row['start']}-{row['end']}",
    axis='columns',
)

circles.drop(
    labels=[
        "chromosome",
        "start",
        "end",
    ],
    axis='columns',
    inplace=True
)

# move region column to the front
circles = circles[ ['region'] + [ col for col in circles.columns if col != 'region' ] ]

circles.to_csv(snakemake.output[0], sep="\t", index=False)