# Repo for Socal Gaze Signal Viewer

Plots gaze location in free viewing task along with other neural signals

## Current implementation

### Viewer
Currently the repo has a viewer that opens up a matlab figure window and lets the user 
observe gaze position and the corresponding spike raster of recorded neurons. The 
sampling rate of the eye tracket is 1KHz so matlab needs to make each frame of the plots
within 1ms for us to be able to see the signal in real time but the process is much
slower in reality

### Video export
Since the viewer in itself is really slow, it can work as a general proof of concept
or even be used for debugging. For proper signal visualization, jobs can be submitted
on the cluster to generate videos for each run of behavior. The basic functions that
are used are same as the viewer, only the script grabs the figure frame for the plot 
of each time point, and then saves a video for the run at a particular framerate.

Below is an example frame from the video output
![Video output example](https://github.com/gprabaha/sg_disp/blob/main/video_outout_example.png "Video output example")
