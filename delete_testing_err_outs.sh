#!/bin/sh

# copy over the bash files to from local to lustre
if [[ $@ == *"DO IT"* ]]
then
    find . -type f -name testing\* -exec rm {} \;
fi