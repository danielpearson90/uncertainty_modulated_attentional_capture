# ChoiceData

This folder contains the raw data for the Choice Test.

Each file contains the data from a single participant. The data are stored in a csv file with the following columns:

| Column name  | Description                                                         |
| ------------ | ------------------------------------------------------------------- |
| block        | Block number                                                        |
| trial        | Trial number                                                        |
| trialCounter | Trial number within block                                           |
| testType     | Type of test (1/4 = "HV vs LV", 2/5 = "HV vs NV", 3/6 = "LV vs NV") |
| option1      | Option 1 (1 = "HV", 2 = "LV", 3 = "NV")                             |
| option2      | Option 2 (1 = "HV", 2 = "LV", 3 = "NV")                             |
| stimOrder    | Order of the stimuli (1 = Option 1 left, 2 = Option 2 left)         |
| targetLoc    | The location of the target in the example stimulus (1 - 6)          |
| distractLoc  | The location of the distractor in the example stimulus (1 - 6)      |
| choice       | The choice made by the participant (1 = Option 1, 2 = Option 2)     |
| subnum       | Subject ID                                                          |
