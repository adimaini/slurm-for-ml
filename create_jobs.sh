#!/bin/bash

set -e

TRAIN_PATH="data/cmu/train.csv"
TEST_PATH="data/cmu/test.csv"
DEV_PATH="data/cmu/dev.csv"
ALPHABET_PATH="data/alphabet.txt"
SCORER_PATH="data/kenlm.scorer"
# VOCAB_PATH = "data/vocab-4500.txt"
# BINARY_PATH = "data/lm.binary"

dataset="haitian_creole"

# Create a fresh file
> ${dataset}_jobs.txt

for dropout in 0.15 0.25
do 
    for neurons in 100 500 1024 
    do
        for learning_rate in 0.0001 0.001 0.005 
        do
            output_folder=data/${dataset}/${dropout}_${neurons}_${learning_rate}
            command_to_pass="DeepSpeech.py --noshow_progressbar --train_files ${TRAIN_PATH} --test_files ${TEST_PATH} --dev_files ${DEV_PATH} "
            command_to_pass+="--alphabet_config_path ${ALPHABET_PATH} --train_batch_size 40 --dev_batch_size 40 --test_batch_size 40 "
            command_to_pass+="--n_hidden ${neurons} --early_stop True --export_dir ${output_folder} --epochs 600 --learning_rate ${learning_rate} "
            command_to_pass+="--dropout_rate ${dropout} --checkpoint_dir ${output_folder} --scorer_path ${SCORER_PATH} --ignore_longer_outputs_than_inputs True --export_tflite" 
            echo ${command_to_pass} >> ${dataset}_jobs.txt
            
        done
    done
done
