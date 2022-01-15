"""
Line function
f(x) = slope * x + intercept
"""


def find_slope(x1, y1, x2, y2):
    return (y2 - y1) / (x2 - x1)


def find_intercept(x, y, slope):
    return y - slope * x


def find_x_from_function_and_y(slope, intercept, y):
    return (y - intercept) / slope


def make_line_points(y1, y2, line):
    """
    Convert a line represented in slope and intercept into pixel points
    The x co-ordiates are calcuated from the slope and lenghth of the average
    values of the lane lines.
    The Y co-ordinates are constant.
    """
    if line is None:
        return None

    slope, intercept = line

    """
    Get X from Y
    y = slope * x + intercept
    y - intercept = slope * x
    (y - intercept) / slope = x 

    Make sure it is integer for pixels
    """

    x1 = int(find_x_from_function_and_y(slope, intercept, y1))
    x2 = int(find_x_from_function_and_y(slope, intercept, y2))
    y1 = int(y1)
    y2 = int(y2)

    return [x1, y1, x2, y2]


def find_intersect(slope_1, intercept_1, slope_2, intercept_2):
    """
    ax+b = cx+d
    x = (d-b)/(a-c)
    """
    return int((intercept_2 - intercept_1) / (slope_1 - slope_2))
