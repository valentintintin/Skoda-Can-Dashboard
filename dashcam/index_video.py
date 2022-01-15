import sys
import traceback

import time

import cv2

import processing

exit = False

params_file = 'params.json'
if len(sys.argv) > 1:
    params_file = sys.argv[1]

video_file = '/home/valentin/Vidéos/dashcam/manu.mp4'
if len(sys.argv) > 2:
    video_file = sys.argv[2]

print('Load params ' + params_file)

with open(params_file) as json_file:
    processing.read_params(json_file.read())

lastProcess = 0
while not exit:
    cap = cv2.VideoCapture(video_file)
    while cap.isOpened():
        if time.time() - lastProcess >= 0.25:
            lastProcess = time.time()
            _, frame = cap.read()

            if frame is None:
                break

            try:
                result = processing.process_image(frame)
                cv2.imshow("results", result)
            except Exception as err:
                print(format(err))
                print(traceback.format_exc())
    
        if cv2.waitKey(1) & 0xFF == ord('q'):
            exit = True
            break
    
    cap.release()
cv2.destroyAllWindows()
