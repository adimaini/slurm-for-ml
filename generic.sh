#!/bin/sh

# This is a generic running script. It can run in two configurations:
# Single job mode: pass the python arguments to this script
# Batch job mode: pass a file with first the job tag and second the commands per line
#SBATCH --time 72:00:00
#SBATCH -o testing%j.out
#SBATCH -e testing%j.err
#SBATCH -p large-gpu -N 4
#SBATCH --mail-user=adimaini@gwu.edu 
#SBATCH --mail-type=ALL

set -e # fail fully on first line failure

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

# Find what was passed to --output_folder
regexp="--export_dir\s+(\S+)"
if [[ $JOB_CMD =~ $regexp ]]
then
    JOB_OUTPUT=${BASH_REMATCH[1]}
else
    echo "Error: did not find a --export_dir argument"
    exit 1
fi

# Check if results exists, if so remove slurm log and skip
if [ -f  "$JOB_OUTPUT/output_graph.pb" ]
then
    echo "Results already done - exiting"
    rm "slurm-${JOB_ID}.out"
    exit 0
fi

# Check if the output folder exists at all. We could remove the folder in that case.
if [ -d  "$JOB_OUTPUT" ]
then
    echo "Folder exists, but was unfinished or is ongoing (no results.json)."
    echo "Starting job as usual"
    # It might be worth removing the folder at this point:
    # echo "Removing current output before continuing"
    # rm -r "$JOB_OUTPUT"
    # Since this is a destructive action it is not on by default
fi

# Use this line if you need to create the environment first on a machine
# ./run_locked.sh ${path_to_conda}/bin/conda-env update -f environment.yml
module load python3/3.7.2

# Activate the environment
source ${path_to_env}

# Go to the correct directory
cd /lustre/groups/caliskangrp/adimaini/deepspeech/DeepSpeech

# Train the model
srun python -u $JOB_CMD

# Move the log file to the job folder
mv "slurm-${JOB_ID}.out" "${JOB_OUTPUT}/"
