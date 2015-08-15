#!/bin/bash

ls -lh .

wget https://github.com/probonopd/AppImageKit/releases/download/1/AppImageAssistant

ls -lh

find .

chmod a+x ./AppImageAssistant 
./AppImageAssistant
