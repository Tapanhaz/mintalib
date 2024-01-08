""" data samples """

import numpy as np
import pandas as pd
import datetime as dt

from importlib import resources


def sample_prices(item: str = None):
    """Sample prices dataframe or series

    Args:
        item (optional) : use as column name to return a series

    Returns:
        A prices dataframe or a series if item is specified
    """

    res = resources.files(__name__).joinpath("sample-prices.csv")
    with resources.as_file(res) as file:
        prices = pd.read_csv(file, index_col=0, parse_dates=True)

    if item is not None:
        return prices[item]

    return prices


def load_prices(target: str = None):
    """Load sample prices in target format

    Args:
        target (None | 'pandas` | 'polars') : target dataframe format

    Returns:
        A numpy structured array or a dataframe of specified target
    """

    if target not in (None, "pandas", "polars"):
        raise ValueError(f"Invalid target {target!r}")

    res = resources.files(__name__).joinpath("sample-prices.csv")
    with resources.as_file(res) as file:
        prices = np.genfromtxt(
            file,
            delimiter=",",
            converters={0: dt.datetime.fromisoformat},
            dtype=None,
            names=True,
            encoding="utf-8",
        )

    if target == "pandas":
        import pandas

        prices = pandas.DataFrame(prices).set_index("date")

    elif target == "polars":
        import polars

        prices = polars.DataFrame(prices)

    return prices
