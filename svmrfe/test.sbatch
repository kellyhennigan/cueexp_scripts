#!/bin/bash
# This test just checks for syntax errors and to make sure that our libraries load fine

#all commands that start with SBATCH contain commands that are just  used by SLURM for scheduling
#################
#set a job name
#SBATCH --job-name=sbatchtest
#################
#a file for job output, you can check job progress
#SBATCH --output=sbatchtest.out
#################
# a file for errors from the job
#SBATCH --error=sbatchtest.err
#################
#time you think you need; default is one hour
#in minutes in this case
#SBATCH --time=1:00:00
#################
#quality of service; think of it as job priority
#SBATCH --qos=normal
#################
#number of nodes you are requesting
#SBATCH --nodes=1
#################
#memory per node; default is 4000 MB per CPU
#SBATCH --mem=4gb
#you could use --mem-per-cpu; they mean what we are calling cores
#################
#tasks to run per node; a "task" is usually mapped to a MPI  processes.
# for local parallelism (OpenMP or threads),use "--ntasks-per-node=1 --cpus-per-tasks=16" instead

#################

#now run normal batch commands
ml load python/2.7.5
cd /scratch/PI/knutson/cuesvm/svmrfe/
source /scratch/PI/knutson/cuesvm/svmrfe/venv/bin/activate
srun python -c 'from sgdrfe import *'
