#!/bin/bash

# Load dSQ module and python
module load dSQ
module load Python/3.8.6-GCCcore-10.2.0

# Define input and output directories
input_dir="/gpfs/milgram/scratch60/chang/pg496/gaze_signal_videos_100fps"
output_dir="/gpfs/milgram/scratch60/chang/pg496/gaze_signal_videos_100fps_mp4"
# input_dir="/Volumes/Stash/changlab/data_visualization/social_gaze"
# output_dir="/Volumes/Stash/changlab/data_visualization/social_gaze/test"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Function to convert AVI to MP4
convert_to_mp4() {
    input_file="$1"
    output_file="$output_dir/${input_file#$input_dir}"  # Retain subfolder structure

    echo "module load FFmpeg/4.3.1-GCCcore-10.2.0.lua; ffmpeg -i \"$input_file\" -c:v libx265 -crf 28 -preset medium -vf \"fps=100\" \"$output_file\""
}

# Iterate through all AVI files and create joblist
joblist="ffmpeg_conversion_joblist.txt"
rm -f "$joblist"  # Remove if exists

find "$input_dir" -type f -name "*.avi" | while IFS= read -r file; do
    mkdir -p "$(dirname "$output_dir/${file#$input_dir}")"  # Create subfolders in output directory
    convert_to_mp4 "$file" >> "$joblist"
done

dsq --job-file "$joblist" --mem-per-cpu 50g -t 5:00:00 --mail-type FAIL

dsq_job_script=$(find . -type f -name "*dsq*${joblist%.txt}*.sh")
sbatch "$dsq_job_script"
