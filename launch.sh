#!/bin/sh

#SBATCH --job-name=<your job name>
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

## Configuration
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=7n  # count of CPU cores
#SBATCH --partition=gpu # ["batch" (CPU), "bigmem" (large memory)]
#SBATCH --gpus-per-task=n # count of GPUs per task
#SBATCH --qos=normal # Quality of Service  https://hpc-docs.uni.lu/slurm/qos/

#SBATCH --time=2:00:00   # timeout (default)



python $1
