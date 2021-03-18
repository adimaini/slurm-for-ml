#!/bin/sh

set -xe

_train_path="data/cmu/train.csv"
_test_path="data/cmu/test.csv"
_dev_path="data/cmu/dev.csv"
_alphabet_path="data/alphabet.txt"
_scorer_path="data/kenlm.scorer"

dataset="haitian_creole"

# Create a fresh file
> ${dataset}_jobs.txt

for _dropout in 0.15 0.25 0.30 0.35 0.40
do 
    for _neurons in 100 1024 1500 2048
    do
        for _learning_rate in 0.0001 0.001 0.005 0.00005
        do
            output_folder=data/${dataset}/${_dropout}_${_neurons}_${_learning_rate}
            command_to_pass="DeepSpeech.py  --train_files ${_train_path} --test_files ${_test_path} --dev_files ${_dev_path} "
            command_to_pass+="--alphabet_config_path ${_alphabet_path} --train_batch_size 40 --dev_batch_size 40 --test_batch_size 40 "
            command_to_pass+="--n_hidden ${_neurons} --early_stop True --export_dir ${output_folder} --epochs 500 --learning_rate ${_learning_rate} "
            command_to_pass+="--dropout_rate ${_dropout} --checkpoint_dir ${output_folder} --scorer_path ${_scorer_path} "
            command_to_pass+="--export_tflite True"
            echo ${command_to_pass} >> ${dataset}_jobs.txt
            
        done
    done
done
