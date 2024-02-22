#!/bin/bash
#SBATCH --job-name=08292018_100fps
#SBATCH --output=cluster/08292018_100fps.out
#SBATCH --error=cluster/08292018_100fps.err
#SBATCH --partition=psych_week
#SBATCH --nodes=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=250G
#SBATCH --time=1-00:00:00
#SBATCH --mail-type=FAIL

module load MATLAB/2022b

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/gpfs/milgram/project/chang/pg496/repositories/categorical/lib/linux"

matlab -r "addpath( genpath( '/gpfs/milgram/project/chang/pg496/repositories' ) ); session='08292018'; params=sg_disp.util.get_params_for_cluster(); sg_disp.cluster.generate_video_for_one_session( session, params );"
