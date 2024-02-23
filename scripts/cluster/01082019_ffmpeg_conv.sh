#!/bin/bash
#SBATCH --job-name=ffmpeg_conv_01082019
#SBATCH --output=cluster/ffmpeg_conv_01082019.out
#SBATCH --error=cluster/ffmpeg_conv_01082019.err
#SBATCH --partition=psych_day
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=240G
#SBATCH --time=5:00:00
#SBATCH --mail-type=FAIL

module load FFmpeg/4.3.1-GCCcore-10.2.0.lua

input_folder="/gpfs/milgram/scratch60/chang/pg496/gaze_signal_videos_100fps"
output_folder="/gpfs/milgram/scratch60/chang/pg496/gaze_signal_videos_100fps_mp4"

#Create output folder if it doesn't exist
mkdir -p "$output_folder"

subfolder="01082019"
input_subfolder="$input_folder/$subfolder"
output_subfolder="$output_folder/$subfolder"

#Create output subfolder if it doesn't exist
mkdir -p "$output_subfolder"

find "$input_subfolder" -type f -name "*.avi" | while IFS= read -r file; do
    output_file="$output_subfolder${file#$input_subfolder}"
    echo "$file"
    echo "$output_file"
    #ffmpeg -i "$file" -c:v libx265 -crf 28 -preset medium -vf "fps=100" "$output_file" &
done

wait
