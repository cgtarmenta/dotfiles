#!/bin/bash

# Opened by clicking the updates widget. shelly covers repositories, the AUR,
# Flatpaks and AppImages, so one listing and one upgrade cover everything.
echo "Available updates:"
shelly list-updates all

read -n1 -rep 'Download updates? (y,n) ' UPD
if [[ $UPD == "Y" || $UPD == "y" ]]; then
    shelly upgrade all
fi
