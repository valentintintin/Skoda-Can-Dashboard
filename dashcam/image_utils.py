import math

import cv2
import numpy as np


def grayscale(image):
    return cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)


def canny(image, low_threshold, high_threshold):
    return cv2.Canny(image, low_threshold, high_threshold)


def gaussian_blur(image, kernel_size):
    return cv2.GaussianBlur(image, (kernel_size, kernel_size), 0)


def mask_with_polygon(image, polygon):
    mask = np.zeros_like(image)

    # filling pixels inside the polygon with white
    cv2.fillPoly(mask, polygon, 255)

    return mask


def mask_image_with_polygon(image, polygon):
    mask = mask_with_polygon(image, polygon)

    # returning the image only where mask pixels are nonzero
    masked_image = cv2.bitwise_and(image, mask)

    return masked_image, mask


def weighted_image(image, initial_image, initial_multiplier=1., image_multiplier=1., offset=0.):
    """
    The result image is initial_image * initial_multiplier + image * image_multiplier + offset
    """
    return cv2.addWeighted(initial_image, initial_multiplier, image, image_multiplier, offset)


def resize_image(image, scale_percent):
    # calculate the 50 percent of original dimensions
    width = int(image.shape[1] * scale_percent / 100)
    height = int(image.shape[0] * scale_percent / 100)

    return cv2.resize(image, (width, height))


def blank_from_image(image):
    return np.zeros((image.shape[0], image.shape[1], 3), dtype=np.uint8)


def draw_lines(image, lines, color=(255, 0, 0), thickness=3):
    for line in lines:
        x1, y1, x2, y2 = line[0]
        cv2.line(image, (x1, y1), (x2, y2), color, thickness)


def text(image, text_to_write, pos, color=(0, 0, 255)):
    cv2.putText(image, text_to_write, pos, cv2.FONT_HERSHEY_PLAIN, 1, color, 2)


def rotate_image(image, angle):
    if angle == 0:
        return image

    h, w = image.shape[:2]
    img_c = (w / 2, h / 2)

    rot = cv2.getRotationMatrix2D(img_c, angle, 1)

    rad = math.radians(angle)
    sin = math.sin(rad)
    cos = math.cos(rad)
    b_w = int((h * abs(sin)) + (w * abs(cos)))
    b_h = int((h * abs(cos)) + (w * abs(sin)))

    rot[0, 2] += ((b_w / 2) - img_c[0])
    rot[1, 2] += ((b_h / 2) - img_c[1])

    return cv2.warpAffine(image, rot, (b_w, b_h), flags=cv2.INTER_LINEAR)


def bincount_app(a):
    a_shape = a.reshape(-1,a.shape[-1])
    col_range = (256, 256, 256) # generically : a_shape.max(0)+1
    a_ravel = np.ravel_multi_index(a_shape.T, col_range)
    return np.unravel_index(np.bincount(a_ravel).argmax(), col_range)