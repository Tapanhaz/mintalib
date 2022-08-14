""" Exponential Moving Average """




@export
def calc_ema(series, long period=20, bint mixed=True):
    """
    Exponential Moving Average

    Args:
        series (series) : data series. required
        period (int) : time period. default 20
        mixed (bool) : whether to start as a simple average until period is reached. default True
    """

    cdef double[:] xs = asarray(series, float)
    cdef long size = xs.size

    cdef object result = np.full(size, NAN)
    cdef double[:] output = result

    cdef double alpha = 2.0 / (period + 1.0)
    cdef double value = NAN
    cdef double ema = NAN
    cdef double sum = 0.0

    cdef long i = 0, count = 0

    for i in range(size):
        value = xs[i]

        if not isnan(value):
            count += 1

            if mixed and count <= period:
                sum += value
                ema = sum / count
            elif isnan(ema):
                ema = value
            else:
                ema += alpha * (value - ema)

        if count >= period:
            output[i] = ema

    result = wrap_result(result, series)

    return result



@export
class EMA(Indicator):
    """
    Exponential Moving Average

    Args:
        period (int) : time period. default 20
    """

    same_scale = True

    def __init__(self, period: int = 20, *, item=None):
        self.period = period
        self.item = item

    def calc(self, data):
        series = self.get_series(data)
        result = calc_ema(series, self.period)
        return result
