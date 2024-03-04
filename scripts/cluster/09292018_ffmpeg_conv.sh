#!/bin/bash
#SBATCH --job-name=ffmpeg_conv_09292018
#SBATCH --output=cluster/ffmpeg_conv_09292018.out
#SBATCH --error=cluster/ffmpeg_conv_09292018.err
#SBATCH --partition=psych_day
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --cpus-per-task=2
#SBATCH --mem=24G
#SBATCH --time=20:00:00
#SBATCH --mail-type=FAIL

input_folder="/gpfs/milgram/scratch60/chang/pg496/gaze-signal-videos_2point5sd"
output_folder="/gpfs/milgram/scratch60/chang/pg496/gaze-signal-videos_2point5sd_mp4"

#Create output folder if it doesn't exist
mkdir -p "$output_folder"

subfolder="09292018"
input_subfolder="$input_folder/$subfolder"
output_subfolder="$output_folder/$subfolder"

#Create output subfolder if it doesn't exist
mkdir -p "$output_subfolder"

num_processes=10  # Set the number of concurrent ffmpeg processes
export input_subfolder="$input_subfolder"
export output_subfolder="$output_subfolder"

find "$input_subfolder" -type f -name "*.avi" | \
xargs -I {} -P $num_processes sh -c ' \
    output_file="$output_subfolder${1#$input_subfolder}"; \
    output_file="${output_file%.avi}.mp4"; \
    echo "Input_file:$1"; \
    echo "Output_file:$output_file"; \
    module load FFmpeg/4.3.1-GCCcore-10.2.0.lua; \
    ffmpeg -i "$1" -c:v libx264 -crf 23 -preset medium -vf "fps=100" "$output_file"' _ {} &

wait
