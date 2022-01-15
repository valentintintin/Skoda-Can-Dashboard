import sys
import traceback

import time

import cv2

import processing

exit = False

params_file = 'params.json'
if len(sys.argv) > 1:
    params_file = sys.argv[1]

image_file = '/home/valentin/Vidéos/dashcam/perso/images/image1.png'
if len(sys.argv) > 2:
    image_file = sys.argv[2]

print('Load params ' + params_file)

with open(params_file) as json_file:
    processing.read_params(json_file.read())

frame = cv2.imread(image_file)

lastProcess = 0
while not exit and frame is not None:
    try:
        if time.time() - lastProcess >= 0.25:
            result = processing.process_image(frame)
            lastProcess = time.time()
    except Exception as err:
        print(format(err))
        print(traceback.format_exc())

    if cv2.waitKey(1) & 0xFF == ord('q'):
        exit = True
        break
    
cv2.destroyAllWindows()
