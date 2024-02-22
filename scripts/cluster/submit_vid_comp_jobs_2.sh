#!/bin/bash

# Load dSQ module
#module load dSQ

# Define input and output directories
#input_dir="/gpfs/milgram/scratch60/chang/pg496/gaze_signal_videos_100fps"
#output_dir="/gpfs/milgram/scratch60/chang/pg496/gaze_signal_videos_100fps_mp4"
input_dir="/Volumes/Stash/changlab/data_visualization/social_gaze/gaze_signal_videos"
output_dir="/Volumes/Stash/changlab/data_visualization/social_gaze/gaze_signal_videos_2"

# Function to convert AVI to MP4 for a given subfolder
convert_subfolder() {
    subfolder="$1"
    input_subfolder="$input_dir/$subfolder"
    output_subfolder="$output_dir/$subfolder"
    
    # Create output subfolder if it doesn't exist
    mkdir -p "$output_subfolder"
    
    # Iterate through all AVI files in the subfolder and convert them in parallel
    find "$input_subfolder" -type f -name "*.avi" | while IFS= read -r file; do
        output_file="$output_subfolder/${file#$input_subfolder}"
        echo "ffmpeg -i \"$file\" -c:v libx265 -crf 28 -preset medium -vf \"fps=100\" \"$output_file\"" &
    done
    
    # Wait for all ffmpeg commands in parallel to finish
    wait
}

# Iterate through all subfolders and submit jobs for each subfolder
for subfolder in "$input_dir"/*/; do
    subfolder=${subfolder%*/}  # Remove trailing slash
    subfolder_name=$(basename "$subfolder")
    
    # Submit job for each subfolder
    dsq_job_script="dsq-job-$subfolder_name.sh"
    echo '#!/bin/bash' > "$dsq_job_script"
    echo "cd \"$PWD\"" >> "$dsq_job_script"
    echo "module load FFmpeg/4.3.1-GCCcore-10.2.0.lua" >> "$dsq_job_script"
    echo "convert_subfolder \"$subfolder_name\"" >> "$dsq_job_script"
    
    # Submit the job
    chmod +x "$dsq_job_script"
    #sbatch "$dsq_job_script"
done

