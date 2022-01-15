import os
import sys
import time
import traceback

import cv2

import processing

cap = cv2.VideoCapture(0)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1920)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 1080)

record_video = False
params_file = 'params.json'
filecount = len([name for name in os.listdir('.') if os.path.isfile(name)])
record_file_name = f'record-{filecount}.avi'

if len(sys.argv) > 1 and len(sys.argv[1]) > 1:
    params_file = sys.argv[1]
if len(sys.argv) > 2 and sys.argv[2] == '1':
    record_video = True

print('Load params ' + params_file)

with open(params_file) as json_file:
    processing.read_params(json_file.read())

if record_video:
    print(f'Save source video to {record_file_name}')
    out = cv2.VideoWriter(record_file_name, cv2.VideoWriter_fourcc('M', 'J', 'P', 'G'), 25, (1920, 1080))

lastProcess = 0
while cap.isOpened():
    _, frame = cap.read()

    if record_video:
        out.write(cv2.resize(frame, (1920, 1080)))

    try:
        if time.time() - lastProcess >= 1:
            result = processing.process_image(frame)
            lastProcess = time.time()
    except Exception as err:
        print(format(err))
        print(traceback.format_exc())
    
cap.release()

if record_video:
    out.release()
    print(f'Saved source video to {record_file_name}')
