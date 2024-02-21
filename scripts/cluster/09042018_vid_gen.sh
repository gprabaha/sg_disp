#!/bin/bash
#SBATCH --job-name=09042018_rt
#SBATCH --output=cluster/09042018_rt.out
#SBATCH --error=cluster/09042018_rt.err
#SBATCH --partition=psych_week
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=250G
#SBATCH --time=7-00:00:00

module load MATLAB/2022b

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/gpfs/milgram/project/chang/pg496/repositories/categorical/lib/linux"

matlab -r "addpath( genpath( '/gpfs/milgram/project/chang/pg496/repositories' ) ); session='09042018'; params=sg_disp.util.get_params_for_cluster(); sg_disp.cluster.generate_video_for_one_session( session, params );"
