# runnsd
Experiment code for the NSD and NSDmini experiments.

<img width="832" height="636" alt="Screenshot 2026-10-08 at 10 05 21 PM" src="https://github.com/user-attachments/assets/b43c9211-04a2-4e93-a673-3f2ec413769e" />

**NOTE: This documentation refers to the NSD experiment, but those files have not been fully migrated into this repository. Currently, please pay attention only to the "NSDmini"-specific content.**

# Key files:
- "runnsd.m" is the script that runs the experiment (nsd experiment)
- "runnsdmini.m" is the script that runs the experiment (nsdmini experiment)

# Installation:
- You should install [knkutils](https://github.com/cvnlab/knkutils/) and Psychtoolbox, and add those to your MATLAB path.
- Furthermore, go download nsd_stimuli.hdf5 (for nsd) and [nsdmini_stimuli.hdf5](http://cvnlab.net/runnsd/nsdmini_stimuli.hdf5) (for nsdmini) and put these large files into the folder "stimulusfiles".
  
# How to run the experiment:
- Connect your external display (if applicable).
- Edit the parameters at the top of the script (e.g. runnsdmini.m). In particular, you will want to set the spatial and temporal resolution of your display (ptonparams).
- Then run the script!

# On running the experiment:
- For nsd, note that after running the experiment for the first time, the subject ID 
  is preserved and not requested again.
- If you want to start from scratch, just do a clear all and run the script again.

# Stimulus information:
- For nsd, there is a single "brick" of color images:
    425 pixels x 425 pixels x 73,000 images
  This is prepared in one single file prepared by Thomas Naselaris.
  This file is the official list/sequence of 73k images.
- nsd experiment:
  - There is a special shared set of 1,000 images. These images are a subset
    of the 73k. Which images these are is determined by Thomas. All eight
    subjects see the shared 1,000, as well as 9,000 unique images. 
- nsdmini experiment:
  - Here, we use the 515 subset of the shared1000 images, that is, the set of
    515 images for which all 8 NSD subjects got all 3 presentations.
  - In nsdmini, we show the 515 images two times each using a 2/1 design.

# Experiment information:
- nsd experiment:
  - The entire experiment is intended to span 40 distinct scan sessions.
    When asked for the experiment number, you should enter a positive integer
    between 1 and 40.
  - Each experiment (1 through 40) consists of twelve runs. When asked for
    the run number, you should enter a positive integer between 1 and 12.
  - The experiment is set up specifically for eight distinct subjects.
    Thus, the subject ID is critical. There is a deterministic mapping
    between subject ID and the integers 1 through 8 (which is used internally);
    this is configured (and changeable) at the very top of the experiment script.
  - Note that the entire experiment (subjects 1-8, sessions 1-40, runs 1-12)
    is set in advance and is completely deterministic and repeatable.
    However, since it is a memory task, there really isn't any "do-overs" or
    "practice runs".
  - Each experimental run is 300 seconds long (5 min). All runs are unique.
- nsdmini experiment:
  - The experiment consists of 10 runs (in 1 scan session, presumably).
    When asked for the run number, enter an integer between 1 and 10.
  - The experiment is the same for different subjects. Hence, the subject ID 
    is not so critical.
  - Note that the experiment (runs 1-10) is set in advance and is completely 
    deterministic and repeatable. However, since it is a memory task, there 
    really aren't any "do-overs" or "practice runs". For this reason, it is
    recommended to show subjects the "fake cartoon images" video.
  - Each experimental run is 360 seconds long (6 min). All runs are unique.
- There is some loading time before each run.
  Make sure that the stimulus computer reports that it is ready for the trigger.
  Once this is reached, the computer waits for the trigger key, at which point
  the experiment starts. Make sure the stimulus starts at the right time (the
  stimulus computer will indicate when it starts the experiment).
- The fixation dot is always present on the screen. It is semi-transparent
  and superimposed on top of stimulus images.
- The experiment operates at 10 frames per second.
  Thus, at 120 Hz, each frame lasts for 12 monitor refreshes.
- There are periods of time (at the beginning and end of each run and blank trials
  in the middle of each run) where there is no stimulus present. The subject
  should always fixate the central dot, even during these times.
- The size and color of the fixation dot is controlled by parameters 
  in the experiment script. The recommended default behavior is to make the dot size
  0.2° in diameter, red, 50% opacity, and with a 3-pixel black border.
- To quit a run early, press ESC.
- After a run completes, a .mat file is written out with timing information
  and keypress information. These are important; keep these .mat files!

# On experimental design (nsd):
- Each run consists of 12-s blank + (63 stimulus trials + 5 blank trials) * 4-s + 16-s blank = 300 s.
- 63 * 12 = 756 stimulus trials which is 6 more than needed.
  Thus, every even run will have the 63th stimulus trial (which is the last of the 68 trials) 
  actually be a blank trial.
- 750 stimulus trials * 40 = 30,000 stimulus trials, which allows each of the 10,000 to be shown 3 times.
- For the central 63 stimulus trials, blank trials will be placed randomly in between these trials
  such that the minimum continuous duration of stimulus trials is 36 s (9 trials) and the 
  maximum continuous duration of stimulus trials is 56 s (14 trials). (This is done ignoring the
  special even-run case.)
- Each trial is 4 seconds, consisting of 3-seconds of the image and 1-second gap.
- Image sequencing is performed by prepareexpdesign_nsd.m and saved into
  a file called nsd_expdesign.mat. Over the course of a single scan session,
  the number of distinct images and number of image presentations are not 
  straightforward (it is stochastic and imbalanced). Please see the script for details.
  There is a variable called 'basiccnt' which provides some metrics.
- The blank trials are generated stochastically for all 12 runs x 40 sessions,
  and then this set of 480 runs is kept constant across all eight subjects.
- For a collection of 40 scan sessions, the stimulus trial ordering is generated
  through a mixture distribution (Von Mises + uniform). This procedure
  is controlled by a concentration parameter and a mixture parameter.
  The end result of this procedure is a sequencing of the numbers
  repmat(1:10000,[1 3]). The concentration parameter is 3^6 and the 
  mixture parameter is 0.4 (40% is uniform).
- From the perspective of the stimulus trial ordering, there are integers
  1 through 10000 that refer to distinct images. We reserve the first 1000
  of these for the special shared 1,000 images. Moreover, the official IDs
  for these shared 1,000 images (relative to the 73k master list) are kept
  in sorted order and inserted into these first 1000 slots.
- We use the exact same stimulus trial ordering for all eight subjects. Thus,
  the shared 1,000 images get shown in exactly the same chronological trial slots
  across subjects. The difference between subjects lies in the assignment of
  which actual stimulus images are used for the remaining 9,000 images.
- Note that because the same blank trial design and the same stimulus trial
  ordering is used across subjects, the "memory load" for each subject is identical.

# On experimental design (nsdmini):
- Each run consists of 15-s blank + (103 stimulus trials + 6 blank trials) * 3-s + 18-s blank = 360 s.
- 103*10 = 1030 stimulus trials.
- Each run has 120 trials (but only 103 are stimulus trials).
- 1030 stimulus trials corresponds to the 515 images being shown 2 times.
- For the central 103 stimulus trials, blank trials are placed in between these trials
  such that the minimum continuous duration of stimulus trials is 36 s (12 trials) and the
  maximum continuous duration of stimulus trials is 57 s (19 trials).
- Each trial is 3 seconds, consisting of 2-seconds of the image and 1-second gap.
- Image sequencing is performed by prepareexpdesign_nsd.m and saved into
  a file called nsdmini_expdesign.mat.
- The blank trials are generated stochastically for the 10 runs (once).
- The stimulus trial ordering is generated through a mixture distribution
  (Von Mises + uniform). This procedure is controlled by a concentration
  parameter and a mixture parameter. The concentration parameter is 3^3 and the
  mixture parameter is 0.2 (20% is uniform).
- Note that because the exact same sequencing is used across subjects, the
  "memory load" for each subject is identical.

# On anticipatory resources/predictive confounding effects:
- The blank trials are quasi-random, so that is good.
- And most of the time, the subject is working.

# On task:
- The subject is supposed to indicate for each stimulus whether they have
  seen it before (in any of the prior trials or prior scan sessions).
- See runnsd[mini]_subjectinstructions.txt for what subjects should know.
  These instructions are shown to the subject before the run starts.

# Stimulus-size issues:
- The resolution of the prepared stimuli is 425 pixels x 425 pixels.
- We use a PsychToolbox mechanism to resize the stimuli on-the-fly to a desired
  pixel resolution. This resizing mechanism involves linear interpolation, so 
  the results may be blurry (when enlarging) and may have aliasing (when shrinking).
  You should view the stimuli on the actual display setup and think hard 
  about how bad the effects are.
- The script specifies that the desired stimulus side length is 8.4 degrees.
  This is achieved through the interpolation mechanisms mentioned above.
  (Alternatively, set whatever stimulus size you want.)

# Eyetracker:
- There is support for Eyelink eyetracking, but this is very complex and
  should be scrutinized for each setup.
- To turn off eyetracking, just set wanteyetracking to 0.

# Display-calibration issues:
- Our strategy is to use "regular" monitor behavior, especially since
  computer photos are intended for regular monitors.
- The BOLDscreen is a linear device, so when running on the BOLDscreen, we 
  simulate a normal squaring luminance response, as follows:
    `ptonparams = {[1920 1080 120 24],[],-2};`
- The uint8 value for the gray background is 127.
- If you are using a typical device (with expansive gamma behavior), you 
  could use a linear clut, like
    `ptonparams = {[],[],0};`

# Timing issues:
- The experiment code locks to the refresh rate of the display.
  Note that after each run completes, information is reported to the screen regarding the
  empirically measured duration of the experiment.

# Screen capture:
- for "fake cartoon images" (nsd):
  - Kendrick generated this using his home monitor which ran at 1440 x 900 @ 60 Hz resolution.
    Moreover, he used 10 deg as if it corresponds to the 900 vertical pixels.
- for "final" (nsd):
  - Kendrick generated this using his home monitor which ran at 1600 x 1200 @ 60 Hz resolution.
    Moreover, he used 10 deg as if it corresponds to the 1200 vertical pixels.
- Because he turned off synchronization tests (in order to be compatible with QuickTime
  screen capture), the stimuli may have been presented with some slight glitches/jerks, so
  the movies are not as high quality as the actual experiment should be.
- for runnsdminiSCREENCAPTURE [truncated].mp4 (nsdmini):
  - This was run 1.
  - Kendrick generated this at 7TAS+BOLDscreen (1920 x 1080 @ 120 Hz).
    Then HandBrake: Fast 720p.
  - The nsdmini experiment uses -2 for the BOLDscreen to make it behave with a squaring.
    When played on standard monitors, the saved movie looks like what 
    subjects actually see.

# Contents of the behavioral .mat file:
- Here is a description of some of the relevant variables that one might need to know 
  in order to analyze the behavioral data:
  - 'timeframes' - 1 x frames. The numbers indicate the actual empirical time
                 corresponding to the presentation of each stimulus frame.
                 Time is relative to the time of the first frame.
                 With the new implementation (nsdmini), NaNs are possible (for dropped frames).
  - 'timekeys' - N x 2 cell. This tells you what keys/buttons/triggers were pressed and when.
- Hopefully, you won't need to slog through the .mat file, and can instead rely on runnsdminibehavioralanalysis.m.

# Contents of the nsdmini_expdesign.mat file:
- 'masterordering' is 1 x 1030 with the sequence of trials (indices relative to 515)
- 'special515ix' is 1 x 515 with sorted indices of the 515 shared images (relative to 73k)
- 'stimpattern' is 10 runs x 120 trials. elements are 0/1 indicating when stimulus trials actually occur.

Note: special515ix(masterordering) is 1 x 1030 indicating the temporal sequence
       of 73k-ids shown to each subject. This sequence refers only to the
       stimulus trials (ignoring the blank trials and the rest periods at the
       beginning and end of each run).
