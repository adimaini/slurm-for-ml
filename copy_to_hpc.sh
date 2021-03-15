#!/bin/sh

BASH_DIR="/Users/adimaini/Documents/GW/Research/CODE.nosync/WEAT-WEFAT/slurm-for-ml/"
LUSTRE_DIR="adimaini@pegasus.colonialone.gwu.edu:/lustre/groups/caliskangrp/adimaini/"
SCORER_PATH="/Users/adimaini/Documents/GW/Research/CODE.nosync/WEAT-WEFAT/deepSpeech/data/kenlm.scorer"
ALPHABET_PATH="/Users/adimaini/Documents/GW/Research/CODE.nosync/WEAT-WEFAT/deepSpeech/data/alphabet.txt"
DATA_DIR=$(dirname "$SCORER_PATH")

if [ $# -eq 0 ]; then
   printf '%s\n' "No input entered"
   exit 1
fi

# copy over the bash files to from local to lustre
if [[ $@ == *"bash"* ]]
then
    find ${BASH_DIR} -name "*.sh" | while read -r file
    do 
        scp -r ${file} ${LUSTRE_DIR}/bash_scripts/
    done
fi


# copy over the scorer file
if [[ $@ == *"scorer"* ]]
then
    scp -r ${SCORER_PATH} ${LUSTRE_DIR}/deepspeech/DeepSpeech/data/
fi

# copy over the alphabet file
if [[ $@ == *"alphabet"* ]]
then
    scp -r ${ALPHABET_PATH} ${LUSTRE_DIR}/deepspeech/DeepSpeech/data/
fi

# copy over the job list file
if [[ $@ == *"joblist"* ]]
then
    scp -r ${LUSTRE_DIR}/bash_scripts/haitian_creole_jobs.txt ${DATA_DIR}/
fi





