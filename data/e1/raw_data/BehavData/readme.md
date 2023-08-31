# BehavData

This folder contains the raw data from the search task.

Each file contains the data from a single participant. The data are stored in a csv file with the following columns:

| Column name              | Description                                                                                                                                                                |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| block                    | Block number                                                                                                                                                               |
| trial                    | Trial number                                                                                                                                                               |
| trialCounter             | Trial number within block                                                                                                                                                  |
| trials_since_break       | Number of trials since last break                                                                                                                                          |
| targetLoc                | Location of the target around the circular arrangement (1 - 6)                                                                                                             |
| distractLoc1             | Location of the first distractor around the circular arrangement (1 - 6)                                                                                                   |
| distractLoc2             | Location of the second distractor around the circular arrangement (1 - 6). If this is a single-distractor trial, then this is a location of another grey non-target circle |
| fixationTime             | Time (in ms) spent on the fixation cross                                                                                                                                   |
| fixationPropGoodSamples  | Proportion of valid samples during fixation                                                                                                                                |
| fixationTimeout          | Whether or not the fixation period timed out (1 = yes, 0 = no)                                                                                                             |
| trialPropGoodSamples     | Proportion of valid samples during the trial                                                                                                                               |
| timeout                  | Whether or not the trial timed out, RT > 2000 ms (1 = yes, 0 = no)                                                                                                         |
| softTimeoutTrial         | Whether or not the trial reached the "soft" timeout threshold, RT > 800 ms (1 = yes, 0 = no)                                                                               |
| omissionTrial1           | Whether or not gaze was recorded on the distractLoc1 AOI during the trial (1 = yes, 0 = no)                                                                                |
| omissionTrial2           | Whether or not gaze was recorded on the distractLoc2 AOI during the trial (1 = yes, 0 = no)                                                                                |
| rt                       | Response time (in seconds)                                                                                                                                                 |
| trialRewardAvailable     | The reward that was available on that trial (in points)                                                                                                                    |
| trialPay                 | The amount of points that were awarded on that trial                                                                                                                       |
| totalPoints              | Total points accumulated so far                                                                                                                                            |
| trialType                | Trial type (1/2 = "HV, 3/4 = "LV", 5/6 = "NV", 7 = "HV vs LV", 8 = "HV vs NV", 9 = "LV vs NV")                                                                             |
| distractType1            | Distractor type presented in distractLoc1                                                                                                                                  |
| distractType2            | Distractor type presented in distractLoc2                                                                                                                                  |
| timeOnLoc_1 - timeOnLoc7 | The time that gaze was recorded on each of the 6 AOIs (in seconds). The seventh location is everywhere else on the screen.                                                 |
| phase                    | Phase of the experiment                                                                                                                                                    |
| subnum                   | Subject number                                                                                                                                                             |
| gender                   | Reported gender of the participant                                                                                                                                         |
| genderInfo               | If participant self-reports another gender term                                                                                                                            |
| age                      | Reported age of the participant                                                                                                                                            |
| counterbal               | Counterbalance condition                                                                                                                                                   |
