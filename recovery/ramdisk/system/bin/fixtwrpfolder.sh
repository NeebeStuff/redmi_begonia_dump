#!/bin/sh

STORAGE_PATH=/sdcard
TWRP_FOLDER_PATH=$STORAGE_PATH/TWRP

if [[ -d $STORAGE_PATH ]]; then
  usergroup=`stat -c %g:%u $STORAGE_PATH`
  secontext=`ls -dZ $STORAGE_PATH`
  secontext=${secontext% *}

  if [[ -d $TWRP_FOLDER_PATH ]]; then
    chown -R $usergroup $TWRP_FOLDER_PATH
    chcon -R $secontext $TWRP_FOLDER_PATH
  fi
fi
