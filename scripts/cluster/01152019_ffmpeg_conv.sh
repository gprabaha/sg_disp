#!/bin/bash
#SBATCH --job-name=ffmpeg_conv_01152019
#SBATCH --output=cluster/ffmpeg_conv_01152019.out
#SBATCH --error=cluster/ffmpeg_conv_01152019.err
#SBATCH --partition=psych_day
#SBATCH --nodes=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=240G
#SBATCH --time=5:00:00
#SBATCH --mail-type=FAIL

input_folder="/gpfs/milgram/scratch60/chang/pg496/gaze_signal_videos_100fps"
output_folder="/gpfs/milgram/scratch60/chang/pg496/gaze_signal_videos_100fps_mp4"

#Create output folder if it doesn't exist
mkdir -p "$output_folder"

subfolder="01152019"
input_subfolder="$input_folder/$subfolder"
output_subfolder="$output_folder/$subfolder"

#Create output subfolder if it doesn't exist
mkdir -p "$output_subfolder"

num_processes=5  # Set the number of concurrent ffmpeg processes
export input_subfolder="$input_subfolder"
export output_subfolder="$output_subfolder"

find "$input_subfolder" -type f -name "*.avi" | \
xargs -I {} -P $num_processes sh -c ' \
    output_file="$output_subfolder${1#$input_subfolder}"; \
    echo "$output_subfolder"; \
    echo "${1#$input_subfolder}"; \
    echo "$input_subfolder"; \
    output_file="${output_file%.avi}.mp4"; \
    echo "Input_file:$1"; \
    echo "Output_file:$output_file"; \
    module load FFmpeg/4.3.1-GCCcore-10.2.0.lua; \
    ffmpeg -i "$1" -c:v libx265 -crf 28 -preset medium -vf "fps=100" "$output_file"' _ {} &

wait
