def draw_circles(image, circles, color=[255, 0, 0], thickness=12):
    if circles is not None:
        for (x, y, r) in circles[0, :]:
            try:
                cv2.circle(image, (x, y), r, color, thickness)
            except Exception as err:
                print(format(err))


def get_hough_circles(image, method, dp, minDist, param1=None, param2=None, minRadius=None, maxRadius=None):
    circles = cv2.HoughCircles(image, method, dp, minDist, param1=param1, param2=param2, minRadius=minRadius,
                               maxRadius=maxRadius)
    circles = np.uint16(np.around(circles))
    circle_image = np.zeros((image.shape[0], image.shape[1], 3), dtype=np.uint8)

    if circles is None:
        return image

    draw_circles(circle_image, circles)
    return circle_image