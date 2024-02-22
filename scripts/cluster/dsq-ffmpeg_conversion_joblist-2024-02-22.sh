#!/bin/bash
#SBATCH --output dsq-ffmpeg_conversion_joblist-%A_%3a-%N.out
#SBATCH --array 0-199
#SBATCH --job-name dsq-ffmpeg_conversion_joblist
#SBATCH --mem-per-cpu 50g -t 5:00:00 --mail-type FAIL

# DO NOT EDIT LINE BELOW
/gpfs/milgram/apps/hpc.rhel7/software/dSQ/1.05/dSQBatch.py --job-file /gpfs/milgram/pi/chang/pg496/repositories/sg_disp/scripts/cluster/ffmpeg_conversion_joblist.txt --status-dir /gpfs/milgram/pi/chang/pg496/repositories/sg_disp/scripts/cluster

