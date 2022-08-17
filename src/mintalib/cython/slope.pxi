""" slope """



cdef enum:
    SLOPE_OPTION_SLOPE = 0
    SLOPE_OPTION_INTERCEPT = 1
    SLOPE_OPTION_CORRELATION = 2
    SLOPE_OPTION_RMSERROR = 3
    SLOPE_OPTION_FORECAST = 4
    SLOPE_OPTION_BADOPTION = 5


@export
class SlopeOption(IntEnum):
    """ Slope Option Enumeration """
    def __repr__(self):
        return str(self)

    SLOPE = 0
    INTERCEPT = 1
    CORRELATION = 2
    RMSERROR = 3
    FORECAST = 4



@export
def calc_slope(series, long period=20, int option=0, int offset=0):
    """ Slope (time linear regression) """

    if option < 0 or option >= SLOPE_OPTION_BADOPTION:
        raise ValueError("Invalid option %d" % option)

    cdef double[:] ys = asarray(series, float)
    cdef long size = ys.size

    cdef object result = np.full(size, np.nan)
    cdef double[:] output = result

    cdef double x, y, s, sx, sy, sxy, sxx, syy, vxy, vxx, vyy
    cdef double corr, slope, intercept, mse, rmse, forecast

    cdef long i = 0, j = 0

    if period >= size:
        return result

    # i : 0 to period -1
    # x : 1 to period
    x = s = sx = sxx = 0.0
    for i in range(period):
        x += 1.0
        s += 1
        sx += x
        sxx += x*x

    vxx = (sxx / s - sx * sx / s / s )

    if vxx <= 0:
        return result

    for j in range(period - 1, size):

        x = 0.0
        sy = sxy = syy = 0.0
        i = j - period + 1

        while i <= j:
            x += 1.0
            y = ys[i]
            if isnan(y):
                break
            sy += y
            sxy += x * y
            syy += y * y
            i += 1
        else:
            vxy = (sxy / s - sx * sy / s / s)
            vyy = (syy / s - sy * sy / s / s)
            slope = vxy / vxx
            intercept = (sy - slope * sx) / s
            corr = vxy / sqrt(vxx * vyy) if vyy > 0 else NAN
            mse = vyy * (1 - corr * corr)
            rmse = sqrt(mse) if mse >= 0 else NAN

            if option == SLOPE_OPTION_SLOPE:
                output[j] = slope
            elif option == SLOPE_OPTION_INTERCEPT:
                output[j] = intercept
            elif option == SLOPE_OPTION_CORRELATION:
                output[j] = corr
            elif option == SLOPE_OPTION_RMSERROR:
                output[j] = rmse
            elif option == SLOPE_OPTION_FORECAST:
                forecast = intercept + slope * (period + offset)
                output[j] = forecast


    result = wrap_result(result, series)

    return result




class SLOPE(Indicator):
    """ Slope (time linear Regression) """

    def __init__(self, period : int = 20, *, item=None):
        self.period = period
        self.item = item

    def calc(self, data):
        series = self.get_series(data)
        result = calc_slope(series, self.period, option=SLOPE_OPTION_SLOPE)
        return result


    class CORRELATION(Indicator):
        """ Slope Correlation """

        def __init__(self, period: int = 20, *, item=None):
            self.period = period
            self.item = item

        def calc(self, data):
            series = self.get_series(data)
            result = calc_slope(series, self.period, option=SLOPE_OPTION_CORRELATION)
            return result


    class RMSERROR(Indicator):
        """ Slope Root Mean Square Error """

        def __init__(self, period: int = 20, *, item=None):
            self.period = period
            self.item = item

        def calc(self, data):
            series = self.get_series(data)
            result = calc_slope(series, self.period, option=SLOPE_OPTION_RMSERROR)
            return result


    class FORECAST(Indicator):
        """ Slope Forecast """

        same_scale = True

        def __init__(self, period: int = 20, offset: int = 0, *, item=None):
            self.period = period
            self.offset = offset
            self.item = item

        def calc(self, data):
            series = self.get_series(data)
            result = calc_slope(series, self.period, offset=self.offset, option=SLOPE_OPTION_FORECAST)
            return result
