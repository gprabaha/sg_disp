#!/bin/bash
#SBATCH --job-name=10022018_100fps
#SBATCH --output=cluster/10022018_100fps.out
#SBATCH --error=cluster/10022018_100fps.err
#SBATCH --partition=psych_week
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=200G
#SBATCH --time=3-00:00:00
#SBATCH --mail-type=FAIL

module load MATLAB/2022b

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/gpfs/milgram/project/chang/pg496/repositories/categorical/lib/linux"

matlab -r "addpath( genpath( '/gpfs/milgram/project/chang/pg496/repositories' ) ); session='10022018'; params=sg_disp.util.get_params_for_cluster(); sg_disp.cluster.generate_video_for_one_session( session, params );"
