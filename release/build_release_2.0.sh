#!/bin/bash
home_dir=/home/sna/release
mkdir $home_dir/2.0
mkdir $home_dir/2.0/connecting
mkdir $home_dir/2.0/core
mkdir $home_dir/2.0/validation
mkdir $home_dir/2.0/variations
mkdir $home_dir/2.0/export_fig

# Start from 1.0
ln -s $home_dir/1.0/connecting/* $home_dir/2.0/connecting/
ln -s $home_dir/1.0/core/*       $home_dir/2.0/core/
ln -s $home_dir/1.0/validation/* $home_dir/2.0/validation/
ln -s $home_dir/1.0/variations/* $home_dir/2.0/variations/
ln -s $home_dir/1.0/export_fig/* $home_dir/2.0/export_fig/
# Changes in 1.1
ln -s $home_dir/1.1/core/check_job_ticket_progress.m $home_dir/2.0/core/
# Changes in 1.2
rm -f $home_dir/2.0/core/SnA.m
rm -f $home_dir/2.0/variations/SnA*.m
ln -s $home_dir/1.2/core/SnA.m $home_dir/2.0/core/
# Changes in 1.2.2
rm -f $home_dir/2.0/core/parallel_SnA.m
rm -f $home_dir/2.0/variations/parallel_SnA*.m
cat $home_dir/1.2.2/core/parallel_SnA.m | sed 's\1.2.2\2.0\g' > $home_dir/2.0/core/parallel_SnA.m
rm -f $home_dir/2.0/validation/run_parallel_SnA*.m
cat $home_dir/1.2.2/validation/run_parallel_SnA_quick_tests.m | sed 's\1.2.2\2.0\g' > $home_dir/2.0/validation/run_parallel_SnA_quick_tests.m
