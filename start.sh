#!/bin/bash
cd /mnt/Data/skoda
echo "Lancement"
# 266,160
# 240,240
export ENV=car
/usr/local/bin/flutter-pi -d '320,180' --release .
sudo pkill python3
echo "Programme fermé"
