#!/bin/bash
################################################################################
#### Run Megadetector Batch on a Directory
################################################################################
# Author: David Hofmann
# Author: David Hofmann
# $1 = folder where detections should run
# $2 = megadetector directory
# $3 = megadetector model
# $4 = conda/mamba installation
# $5 = checkpoint frequency

# Change directory to the one provided
cd $1

# Identify the subdirectories through which we need to loop
dirs=$(ls -d */)

# Activate the appropriate megadetector environment and load the required files
source $4/etc/profile.d/conda.sh
conda activate cameratraps-detector

# Export relevant paths
export PYTHONPATH="$PYTHONPATH:$2/cameratraps:$2/ai4eutils:$2/yolov5"

# Loop through the directories and run the megadetector if necessary (handles whitespace)
OIFS="$IFS"
IFS=$'\n'
for subdir in $dirs
do

  # Check if an output file already exists
  output=$subdir"Output_"$(basename $subdir)".json"
  if test -f "$output"; then
	  echo "$output exists. Skipping to next folder..."
  else
	  echo "$output does not exist"

	  # Check if a checkpoint already exists
	  checkpoint=$(ls $subdir | grep "checkpoint")
	  if test -f $subdir$checkpoint; then
		  echo "Continue from checkpoint $subdir$checkpoint"
      python $2/cameratraps/detection/run_detector_batch.py $2/$3 $subdir $output --output_relative_filenames --recursive --threshold 0.2 --checkpoint_frequency $5 --resume_from_checkpoint $subdir$checkpoint
      rm $subdir$checkpoint
	  else
		  echo "No checkpoint found. Initiate new detection batch"
      python $2/cameratraps/detection/run_detector_batch.py $2/$3 $subdir $output --output_relative_filenames --recursive --threshold 0.2 --checkpoint_frequency $5
    fi
  fi
done
IFS="$OIFS"
echo All done...
