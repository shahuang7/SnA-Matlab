#!/bin/bash

#SBATCH --partition=batch 
#SBATCH --job-name=nlsa
#SBATCH --mem-per-cpu=20g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=huang229@uwm.edu
#SBATCH --ntasks=1

# Ideally you would source your own conda installation this way
# source ~/miniconda3/bin/activate

# But given that you may not have it installed yet,
# this will load a workable Python installation.
# DO NOT use this Python installation for your own simulations,
# if you have questions about setting up your own Python environment,
# please email research-computing@uwm.edu

#module load pkgsrc/2020Q3
module load matlab/2022a
matlab -batch "hostname"
#mpirun -n 4 python nlsa.py
