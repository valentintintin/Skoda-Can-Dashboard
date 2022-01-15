#!/bin/bash
cd /mnt/Data/skoda-dev
echo "Lancement dev"
export ENV=car
/usr/local/bin/flutter-pi -d '320,180' .
sudo pkill python3
echo "Programme fermé"
