import json
import math
import socket
import time

import cv2
import numpy as np

import compute
import finder
import image_utils

tcpServerAddress = '127.0.0.1'
tcpServerPort = 38500
isConnected = False

imageCounter = 0

params = None
socketPanels = None
socketImage = None


def connect():
    global isConnected
    if not isConnected:
        global socketPanels
        global socketImage

        socketPanels = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            socketPanels.connect((tcpServerAddress, tcpServerPort))
            socketImage.setblocking(False)
            isConnected = True
            print('Connected to panel image server')
        except:
            isConnected = False

        socketImage = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            socketImage.connect((tcpServerAddress, tcpServerPort + 1))
            socketImage.setblocking(False)
            print('Connected to image server')
        except:
            pass


def read_params(params_json):
    if len(params_json) >= 500:  # just security
        global params
        params = json.loads(params_json)
        print(params)

        params['panels']['size_detection']['width_computed'] = {
            'min': convert_pixel(params['panels']['size_detection']['width']['min']),
            'max': convert_pixel(params['panels']['size_detection']['width']['max'])
        }

        params['panels']['size_detection']['height_computed'] = {
            'min': convert_pixel(params['panels']['size_detection']['height']['min']),
            'max': convert_pixel(params['panels']['size_detection']['height']['max'])
        }

        params['lanes']['hough_lines']['min_line_length_computed'] = convert_pixel(params['lanes']['hough_lines']['min_line_length'])
        params['lanes']['hough_lines']['max_line_gap_computed'] = convert_pixel(params['lanes']['hough_lines']['max_line_gap'])
        params['lanes']['angle']['center_computed'] = convert_pixel(params['lanes']['angle']['center'])
        params['lanes']['angle']['interval_computed'] = convert_pixel(params['lanes']['angle']['interval'])
    else:
        print('Params JSON length < 500 : ' + params_json)


def convert_pixel(value_pixel):
    return int(value_pixel / 50 * params['resize_percent'])
    

def get_left_and_right_lines_from_hough_lines(lines):
    left_lines = []
    right_lines = []

    for line in lines:
        for x1, y1, x2, y2 in line:
            if x2 == x1:
                continue

            # Find slope of the lane lines.
            slope = compute.find_slope(x1, y1, x2, y2)
            # slope of an vertical line is infinity or illogic, just continue.
            if slope == 0 or abs(slope) < 0.2:
                continue

            intercept = compute.find_intercept(x1, y1, slope)

            # The slope of left lane lines are less than 0.
            if slope < 0:
                left_lines.append((slope, intercept))
            else:
                right_lines.append((slope, intercept))

    left_line = None
    right_line = None

    if len(left_lines) >= 1:
        left_lines.sort(key=lambda x: abs(x[0]), reverse=False)
        left_line = left_lines[0]

    if len(right_lines) >= 1:
        right_lines.sort(key=lambda x: abs(x[0]), reverse=True)
        right_line = right_lines[0]

    return left_line, right_line


def get_lane_lines(image, lines, percent_size=0.65):
    left_line_function, right_line_function = get_left_and_right_lines_from_hough_lines(lines)

    # first point at the image bottom
    y1 = image.shape[0]
    # line length
    y2 = y1 * percent_size

    left_line = compute.make_line_points(y1, y2, left_line_function)
    right_line = compute.make_line_points(y1, y2, right_line_function)

    left_angle = None
    if left_line_function is not None:
        left_angle = math.degrees(math.atan(left_line_function[0]))

    right_angle = None
    if right_line_function is not None:
        right_angle = math.degrees(math.atan(right_line_function[0]))

    return (left_line, left_line_function, left_angle), (right_line, right_line_function, right_angle)


def process_image(image):
    global isConnected
    global imageCounter

    connect()

    if isConnected:
        try:
            nb_bytes = int.from_bytes(socketImage.recv(2), 'little', signed=False)
            print(nb_bytes)
            params_json = socketImage.recv(nb_bytes).decode('utf-8').strip()
            read_params(params_json)
        except BlockingIOError:
            pass
        except BrokenPipeError:
            isConnected = False
            pass

    if params is None:
        raise 'No params !'

    image_resized = image
    if params['resize_percent'] > 0:
        image_resized = image_utils.resize_image(image, params['resize_percent'])

    image_source_to_use = image_rotated = image_utils.rotate_image(image_resized, params['rotation_angle'])
    image_grayscale = image_utils.grayscale(image_rotated)

    image_gauss = image_grayscale
    if params['gaussian_blur'] > 0:
        image_gauss = image_utils.gaussian_blur(image_grayscale, params['gaussian_blur'])

    image_canny = image_utils.canny(image_gauss, low_threshold=params['canny']['low_threshold'],
                                    high_threshold=params['canny']['high_threshold'])

    # Defining the region of interest to look for lane lines.
    height, width = image_source_to_use.shape[:2]

    """ Find lanes """
    bottom_left = [width * params['lanes']['polygon_multiplier']['bottom_left'][0],
                   height * params['lanes']['polygon_multiplier']['bottom_left'][1]]
    top_left = [width * params['lanes']['polygon_multiplier']['top_left'][0],
                height * params['lanes']['polygon_multiplier']['top_left'][1]]
    bottom_right = [width * params['lanes']['polygon_multiplier']['bottom_right'][0],
                    height * params['lanes']['polygon_multiplier']['bottom_right'][1]]
    top_right = [width * params['lanes']['polygon_multiplier']['top_right'][0],
                 height * params['lanes']['polygon_multiplier']['top_right'][1]]

    polygon = np.array([[bottom_left, top_left, top_right, bottom_right]], dtype=np.int32)

    # Mask the region outside of the region of interest.
    image_masked_lanes, mask_lanes = image_utils.mask_image_with_polygon(image_canny, polygon)
    mask_lanes_with_source = image_utils.weighted_image(mask_lanes, image_grayscale, image_multiplier=0.5)

    result = image_source_to_use

    # distance resolution in pixels of the Hough grid
    rho = 1
    # angular resolution in radians of the Hough grid
    theta = np.pi / 180
    # minimum number intersections in Hough grid cell.
    threshold = params['lanes']['hough_lines']['threshold']
    # minimum number of pixels making up a line
    min_line_length = params['lanes']['hough_lines']['min_line_length_computed']
    # maximum gap in pixels between connectable line segments
    max_line_gap = params['lanes']['hough_lines']['max_line_gap_computed']
    lines_lanes = finder.get_hough_lines(image_masked_lanes, rho, theta, threshold, min_line_length, max_line_gap)

    line_size = params['lanes']['length_multiplier']

    lanes_image = image_utils.blank_from_image(image_source_to_use)

    if lines_lanes is not None:
        left_lane, right_lane = get_lane_lines(image_masked_lanes, lines_lanes, line_size)

        color = params['lanes']['drawing']['lanes']['color']
        thickness = params['lanes']['drawing']['lanes']['thickness']

        if left_lane[0] is not None:
            left = left_lane[0]
            cv2.line(lanes_image, (left[0], left[1]), (left[2], left[3]), color, thickness)
            print('Left lane', str(left_lane[1][0]), str(left_lane[1][1]), str(left_lane[2]))
            image_utils.text(lanes_image, str(round(left_lane[1][0])) + ' ' + str(round(left_lane[1][1])) + ' ' + str(
                round(left_lane[2])), (left[2] - convert_pixel(300), left[3] - convert_pixel(10)), color)

        if right_lane[0] is not None:
            right = right_lane[0]
            cv2.line(lanes_image, (right[0], right[1]), (right[2], right[3]), color, thickness)
            print('Right lane', str(right_lane[1][0]), str(right_lane[1][1]), str(right_lane[2]))
            image_utils.text(lanes_image, str(round(right_lane[1][0])) + ' ' + str(round(right_lane[1][1])) + ' ' + str(
                round(right_lane[2])), (right[2] + convert_pixel(50), right[3] - convert_pixel(10)), color)

        if left_lane[1] is not None and right_lane[1] is not None:
            left = left_lane[1]
            right = right_lane[1]
            x_intersect = compute.find_intersect(left[0], left[1], right[0], right[1]) - convert_pixel(3) # why -3px ?
            y = int(height * line_size)

            color = params['lanes']['drawing']['angle']['color']

            center = params['lanes']['angle']['center_computed']
            interval = params['lanes']['angle']['interval_computed']
            min_interval = center - interval
            max_interval = center + interval

            if min_interval <= x_intersect <= max_interval:
                color = params['lanes']['drawing']['angle']['color_alert']

            cv2.line(lanes_image, (x_intersect, y), (center, int(height)), color, thickness)

            print('Diff center lane', str(min_interval), str(x_intersect), str(max_interval))
            image_utils.text(lanes_image, str(min_interval) + ' ' + str(x_intersect) + ' ' + str(max_interval),
                             (center - convert_pixel(100), y + convert_pixel(100)), color)

        # todo this line draws lines on panel ! Why ??
        result = image_utils.weighted_image(lanes_image, image_source_to_use)

    """ Find panels """
    bottom_left = [width * params['panels']['polygon_multiplier']['bottom_left'][0],
                   height * params['panels']['polygon_multiplier']['bottom_left'][1]]
    top_left = [width * params['panels']['polygon_multiplier']['top_left'][0],
                height * params['panels']['polygon_multiplier']['top_left'][1]]
    bottom_right = [width * params['panels']['polygon_multiplier']['bottom_right'][0],
                    height * params['panels']['polygon_multiplier']['bottom_right'][1]]
    top_right = [width * params['panels']['polygon_multiplier']['top_right'][0],
                 height * params['panels']['polygon_multiplier']['top_right'][1]]

    polygon = np.array([[bottom_left, top_left, top_right, bottom_right]], dtype=np.int32)

    # Mask the region outside of the region of interest.
    image_masked_panels, mask_panels = image_utils.mask_image_with_polygon(image_canny, polygon)
    mask_panels_with_source = image_utils.weighted_image(mask_panels, image_grayscale, image_multiplier=0.5)

    panels_image = image_utils.blank_from_image(image_source_to_use)
    panels_image_only = image_utils.blank_from_image(image_source_to_use)

    force_panel = False
    panel_color_min = (120, 120, 120)
    contours, hierarchy = cv2.findContours(image_masked_panels, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
    for cnt in contours:
        approx = cv2.approxPolyDP(cnt, 0.01 * cv2.arcLength(cnt, True), True)
        x, y, w, h = cv2.boundingRect(approx)
        ratio = w / h
        if (force_panel and w >= 20 and h >= 20 and ratio >= 0.2) \
                or (params['panels']['size_detection']['ratio']['min'] <= ratio <= params['panels']['size_detection']['ratio'][
            'max'] \
                and params['panels']['size_detection']['width_computed']['min'] <= w <= \
                params['panels']['size_detection']['width_computed']['max'] \
                and params['panels']['size_detection']['height_computed']['min'] <= h <= \
                params['panels']['size_detection']['height_computed']['max']):

            (x_panel, xw_panel), (y_panel, yh_panel) = box_oversize_with_offset((x, y), (w, h),
                                                                                (convert_pixel(25), convert_pixel(25)), image_masked_panels.shape)

            panel = result[y_panel:yh_panel, x_panel:xw_panel]

            panel_dominant_color = [int(x) for x in image_utils.bincount_app(panel)]
            print(panel_dominant_color)

            if not force_panel \
                    and panel_dominant_color[0] <= panel_color_min[0] \
                    and panel_dominant_color[1] <= panel_color_min[1] \
                    and panel_dominant_color[2] <= panel_color_min[2]:
                continue

            if isConnected:
                print('Sending')
                try:
                    socketPanels.sendall(cv2.imencode('.jpg', panel)[1].tobytes())
                except BrokenPipeError:
                    isConnected = False
                    pass

            panels_image_only[y_panel:yh_panel, x_panel:xw_panel] = panel

            image_utils.text(panels_image, str(round(w / h, 2)) + ' ' + str(w) + ' ' + str(h), (x - convert_pixel(100), y - convert_pixel(10)), panel_dominant_color)
            image_utils.text(panels_image_only, str(round(w / h, 2)) + ' ' + str(w) + ' ' + str(h), (x - convert_pixel(100), y - convert_pixel(10)), panel_dominant_color)

            cv2.rectangle(panels_image, (x, y), (x + w, y + h), panel_dominant_color,
                          params['panels']['drawing']['thickness'])
            cv2.rectangle(panels_image_only, (x, y), (x + w, y + h), panel_dominant_color,
                          params['panels']['drawing']['thickness'])

            print('Panel', str(x), str(y), str(w), str(h), str(ratio))
            # cv2.imwrite('images/' + str(imageCounter) + '.jpg', result)
            imageCounter += 1

    result = image_utils.weighted_image(panels_image, result)
    image_to_return = result

    if params['result'] == 'source':
        image_to_return = image
    elif params['result'] == 'resized':
        image_to_return = image_resized
    elif params['result'] == 'rotated':
        image_to_return = image_rotated
    elif params['result'] == 'gray':
        image_to_return = image_grayscale
    elif params['result'] == 'gaussian':
        image_to_return = image_gauss
    elif params['result'] == 'canny':
        image_to_return = image_canny
    elif params['result'] == 'mask_lanes':
        image_to_return = mask_lanes_with_source
    elif params['result'] == 'masked_lanes':
        image_to_return = image_masked_lanes
    elif params['result'] == 'lanes':
        image_to_return = lanes_image
    elif params['result'] == 'mask_panels':
        image_to_return = mask_panels_with_source
    elif params['result'] == 'masked_panels':
        image_to_return = image_masked_panels
    elif params['result'] == 'panels':
        image_to_return = panels_image_only

    if isConnected:
        try:
            socketImage.sendall(cv2.imencode('.jpg', image_to_return)[1].tobytes())
        except BrokenPipeError:
            isConnected = False
            pass

    return image_to_return


"""
Add size + offset to pos.
If result is oversized than size_total, set component to max
"""
def box_oversize_with_offset(pos, size, offset_wanted, size_total):
    x, y = pos
    width, height = size
    width_offset, height_offset = offset_wanted
    max_height, max_width = size_total

    size_final = [
        x - width_offset,
        x + width + width_offset,
        y - height_offset,
        y + height + height_offset
    ]

    if size_final[0] < 0:
        size_final[0] = 0

    if size_final[1] > max_width:
        size_final[1] = max_width

    if size_final[2] < 0:
        size_final[2] = 0

    if size_final[3] > max_height:
        size_final[3] = max_height

    return (size_final[0], size_final[1]), (size_final[2], size_final[3])
