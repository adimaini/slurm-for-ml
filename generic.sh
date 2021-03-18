#!/bin/sh

# This is a generic running script. It can run in two configurations:
# Single job mode: pass the python arguments to this script
# Batch job mode: pass a file with first the job tag and second the commands per line
#SBATCH --time 100:00:00
#SBATCH -e testing%j.err
#SBATCH -p large-gpu,small-gpu -N 2

#SBATCH --mail-user=adimaini@gwu.edu 
#SBATCH --mail-type=ALL

# Customize this line to point to virtualenv installation
path_to_env="/lustre/groups/caliskangrp/adimaini/deepspeech/deepspeech2-env/bin/activate"

echo "Running on $(hostname)"

if [ -z "$SLURM_ARRAY_TASK_ID" ]
then
    # Not in Slurm Job Array - running in single mode

    JOB_ID=$SLURM_JOB_ID

    # Just read in what was passed over cmdline
    JOB_CMD="${@}"
else
    # In array

    JOB_ID="${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}"

    # Get the line corresponding to the task id
    JOB_CMD=$(head -n ${SLURM_ARRAY_TASK_ID} "$1" | tail -1)
fi

# Use this line if you need to create the environment first on a machine
# ./run_locked.sh ${path_to_conda}/bin/conda-env update -f environment.yml
module load python3/3.7.2
export TF_FORCE_GPU_ALLOW_GROWTH=true

# Activate the environment
source ${path_to_env}

# Go to the correct directory
cd /lustre/groups/caliskangrp/adimaini/deepspeech/DeepSpeech


# Find what was passed to --output_folder
regexp="--export_dir\s+(\S+)"
if [[ $JOB_CMD =~ $regexp ]]
then
    JOB_OUTPUT=${BASH_REMATCH[1]}
else
    echo "Error: did not find a --export_dir argument"
    exit 1
fi

# Check if results exists, if so skip this JOB_ID
if [ -f  "${JOB_OUTPUT}/output_graph.tflite" ]
then
    echo "Results already done - exiting"
    exit 0
fi

# Check if the output folder exists at all. We could remove the folder in that case.
if [ -d  "$JOB_OUTPUT" ]
then
    echo "Folder exists, but has unfinished results (no output_graph.tflite)."
    echo "Starting job as usual"
fi


# Train the model
python -u $JOB_CMD

# Move the log file to the job folder
mv "/lustre/groups/caliskangrp/adimaini/bash_scripts/slurm-${JOB_ID}.out" "${JOB_OUTPUT}/"