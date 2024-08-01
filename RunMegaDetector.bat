@echo off
REM #### Run Megadetector Batch on a Directory
REM Author: David Hofmann
REM %1 = folder where detections should run
REM %2 = megadetector directory
REM %3 = megadetector model
REM %4 = checkpoint frequency

SETLOCAL ENABLEDELAYEDEXPANSION

REM Change working directory
set "init_dir=%CD%"
cd %1

REM Activate megadetector environment
call conda activate megadetector

REM Export utilities
set PYTHONPATH=%2\MegaDetector;%2\yolov5

REM Loop through sub-directories
for /D %%D in (*) do (

	REM Define the filename of the output file
	set "output=%1\%%D\Detections.json"
	
	REM If output file already exists, skip to the next folder
	if exist !output! (
		echo !output! exists. Skipping to next folder...

	REM Otherwise, we run the detection
	) else (
		echo !output! does not exist

		REM Check if there is a checkpoint
		for %%F in ("%1\%%D\*checkpoint_*.json") do (
			if exist %%F (
				echo %%F
				set "found=1"
				goto :found_checkpoint
			)
		)
		:found_checkpoint
		if !found! equ 1 (
			echo Continue from checkpoint.
			python %2\MegaDetector\megadetector\detection\run_detector_batch.py %3 %1 !output! --output_relative_filenames --recursive --quiet --threshold 0.2 --checkpoint_frequency %4 --resume_from_checkpoint "auto"
		) else (
			echo No checkpoint found. Initiate new detection batch
			python %2\MegaDetector\megadetector\detection\run_detector_batch.py %3 %1 !output! --output_relative_filenames --recursive --quiet --threshold 0.2 --checkpoint_frequency %4
		)
		
	)
)


REM Reset working directory
cd %init_dir%

echo All done...

