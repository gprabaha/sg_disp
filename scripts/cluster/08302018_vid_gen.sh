#!/bin/bash
#SBATCH --job-name=08302018_500fps
#SBATCH --output=cluster/08302018_500fps.out
#SBATCH --error=cluster/08302018_500fps.err
#SBATCH --partition=psych_week
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=250G
#SBATCH --time=3-00:00:00
#SBATCH --mail-type=END,FAIL

module load MATLAB/2022b

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/gpfs/milgram/project/chang/pg496/repositories/categorical/lib/linux"

matlab -r "addpath( genpath( '/gpfs/milgram/project/chang/pg496/repositories' ) ); session='08302018'; params=sg_disp.util.get_params_for_cluster(); sg_disp.cluster.generate_video_for_one_session( session, params );"
