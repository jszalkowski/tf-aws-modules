#!/bin/bash

for TFDIR in `find * -type d`; do
    terraform validate $TFDIR 
    if [ "$?" == "1" ]; then
        exit 1
    fi
done
