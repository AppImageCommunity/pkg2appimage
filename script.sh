#!/bin/bash

ls -lh .

wget -c https://github.com/probonopd/AppImageKit/releases/download/1/AppImageAssistant

ls -lh

ls -lh /dev/fuse
which fusermount
fusermount

chmod a+x ./AppImageAssistant 
./AppImageAssistant
