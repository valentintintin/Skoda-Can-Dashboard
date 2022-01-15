import cv2
import numpy as np


def get_hough_lines(image, rho, theta, threshold, min_line_len, max_line_gap):
    return cv2.HoughLinesP(image, rho, theta, threshold, np.array([]), minLineLength=min_line_len,
                            maxLineGap=max_line_gap)