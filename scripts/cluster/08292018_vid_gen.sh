#!/bin/bash
#SBATCH --job-name=08292018
#SBATCH --output=cluster/08292018.out
#SBATCH --error=cluster/08292018.err
#SBATCH --partition=psych_week
#SBATCH --nodes=1
#SBATCH --cpus-per-task=15
#SBATCH --mem=150G
#SBATCH --time=7-00:00:00

module load MATLAB/2022b

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/gpfs/milgram/project/chang/pg496/repositories/categorical/lib/linux"

matlab -r "addpath( genpath( '/gpfs/milgram/project/chang/pg496/repositories' ) ); session='08292018'; params=sg_disp.util.get_params_for_cluster(); sg_disp.cluster.generate_video_for_one_session( session, params );"