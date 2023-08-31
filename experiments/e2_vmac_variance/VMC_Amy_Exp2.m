clear all %#ok<*CLALL> 

Screen('Preference', 'VisualDebuglevel', 3);    % Hides the hammertime PTB startup screen

Screen('CloseAll');

clc;

functionFoldername = fullfile(pwd, 'functions');    % Generate file path for "functions" folder in current working directory
addpath(genpath(functionFoldername));       % Then add path to this folder and all subfolders

global MainWindow screenNum
global scr_centre DATA datafilename p_number EGdataFilenameBase
global screenRes
global distract_col colourName
global white black gray yellow
global calibrationNum
global totalPoints maxPointsPhase
global orange green blue pink
global realVersion
global eyeVersion
global screenshotVersion
global upperBonus lowerBonus

%% set some paramaters
eyeVersion = true; % set to true to run eyetracker, otherwise uses mouse position
realVersion = true; % set to true for correct numbers of trials etc.
screenshotVersion = false;
upperBonus = 12;    %Max with perfect performance. Included in instructions as the upper amount that 'most people' earn
lowerBonus = 7;   %Min with terrible performance Included in instructions as the lower amount that 'most people' earn
exptName = 'VMAC_Amy_E2';

%% Important for EG information at the end - for which phases do we want to process the EG data and DELETE ORIGINALS!
minPhase = 2;
maxPhase = 3;
%%

counterbalConditions = 6;

calibrationNum = 0;

commandwindow;

if realVersion
    screenNum = 0;
    Screen('Preference', 'SkipSyncTests', 0); % Enables PTB calibration
else
    screenNum = 0;
    Screen('Preference', 'SkipSyncTests', 2); %Skips PTB calibrations
    fprintf('\n\nEXPERIMENT IS BEING RUN IN DEBUGGING MODE!!! IF YOU ARE RUNNING A ''REAL'' EXPT, QUIT AND CHANGE realVersion TO true\n\n');
end


%%
% *************************************************************************
%
% Initialization and connection to the Tobii Eye-tracker
%
% *************************************************************************
% Set up folders and then connect to eye tracker

if exist('Data', 'dir') == 0
    mkdir('Data');
end
if exist('Data\BehavData', 'dir') == 0
    mkdir('Data\BehavData');
end


%% SPECTRUM STUFF
global eyetracker trackerSampleRate
if eyeVersion
    disp('Initializing Tobii SDK...');
    Tobii = EyeTrackingOperations();
    disp('Browsing for trackers...');
    foundEyetrackers = Tobii.find_all_eyetrackers();
    for ii = 1:size(foundEyetrackers,2)      % Sometimes a computer might be connected to more than one eye-tracking device - get info from all of them
        disp(['Address:',foundEyetrackers(ii).Address]);
        disp(['Name:',foundEyetrackers(ii).Name]);
        disp(['Model:',foundEyetrackers(ii).Model]);
        disp(['Firmware Version:',foundEyetrackers(ii).FirmwareVersion]);
        fprintf('\n');
    end
    trackerId = foundEyetrackers(1).Address;     % Connect to the first one of the eye-trackers in the list (if there is only one eye-tracker connected, this will be it)
    fprintf('Connecting to tracker "%s"...\n', trackerId);
    eyetracker = Tobii.get_eyetracker(trackerId);   % This gets an eyetracker object for the specified tracker, that we can then control and use to record data
    trackerSampleRate =  eyetracker.get_gaze_output_frequency();
    fprintf('Connected!  Sample rate: %d Hz.\n', trackerSampleRate);
end


%%
if exist('Data\CalibrationData', 'dir') == 0
    mkdir('Data\CalibrationData');
end
% if exist('EyeData', 'dir') == 0
%     mkdir('EyeData');
% end


%% prompt user for some input
genderInfo = 'x';
if realVersion
    inputError = 1;
    while inputError == 1
        inputError = 0;
        p_number = input('Participant number ---> ');
        datafilename = ['Data\BehavData\', exptName, '_P', num2str(p_number), '.mat'];
        if exist(datafilename, 'file') == 2
            disp(['Data for participant ', num2str(p_number),' already exist'])
            inputError = 1;
        end
    end
        
    colBalance = 0;
    while colBalance < 1 || colBalance > counterbalConditions
        try
            colBalance = input(['Counterbalance (1-', num2str(counterbalConditions), ') ---> ']);
        catch
            colBalance = 0;
        end
        if isempty(colBalance); colBalance = 0; end
    end
    clc;
    
    p_age = input('Please enter your age and then press enter (leave blank if you would rather not say) ---> ');
    if isempty(p_age); p_age = NaN; end
    
    fprintf('How do you describe your gender?\n   1. Man / male\n   2. Woman / female\n   3. Non-binary\n   4. I use a different term\n   5. I prefer not to answer\n')
    repeatQ = true;
    while repeatQ
        repeatQ = false;
        try
            p_gender = input('---> ');
        catch
            repeatQ = true;
        end
        if isempty(p_gender) || p_gender < 1 || p_gender > 5; repeatQ = true; end
    end
    
    if p_gender == 4
        genderInfo = input('(Optional) Please specify the term you use, or leave blank if you would rather not say --> ', 's');
    end
    
else
    p_number = 1;
    colBalance = 1;
    p_gender = 1;
    p_age = 123;
    datafilename = ['Data\BehavData\debug', num2str(p_number), '.mat'];
end


%%
DATA.subject = p_number;
DATA.counterbal = colBalance;
DATA.eyeVersion = eyeVersion;
DATA.realVersion = realVersion;
DATA.age = p_age;
DATA.gender = p_gender;
DATA.genderInfo = genderInfo;
DATA.start_time = datestr(now,0);
DATA.fixationTimeouts = zeros(1, maxPhase);
DATA.trialTimeouts = zeros(1, maxPhase);
if eyeVersion
    DATA.trackerID = trackerId;
end
DATA.session_Bonus = 0;
DATA.session_Points = 0;

if eyeVersion
    EGfolderName = 'Data\EyeData';
    EGsubfolderNameString = ['P', num2str(p_number)];
    mkdir(EGfolderName, EGsubfolderNameString);
    EGdataFilenameBase = [EGfolderName, '\', EGsubfolderNameString, '\GazeData', EGsubfolderNameString];
    DATA.trackerID = trackerId;
    DATA.trackerSampleRate = trackerSampleRate;     %SPECTRUM STUFF
end


%% *******************************************************
%let's do this!

KbName('UnifyKeyNames');    % Important for some reason to standardise keyboard input across platforms / OSs.

Screen('Preference', 'DefaultFontName', 'Courier New');

% generate a random seed using the clock, then use it to seed the random
% number generator
rng('shuffle');
randSeed = randi(30000);
DATA.rSeed = randSeed;
rng(randSeed);

% Get screen resolution, and find location of centre of screen

if realVersion
    [scrWidth, scrHeight] = Screen('WindowSize',screenNum);
else
    scrWidth = 1920;
    scrHeight = 1080;
end
screenRes = [scrWidth scrHeight];
scr_centre = screenRes / 2;

if realVersion
    MainWindow = Screen(screenNum, 'OpenWindow', [0 0 0], [], 32);
else
    MainWindow = Screen(screenNum, 'OpenWindow', [0 0 0], [0, 0, scrWidth, scrHeight], 32);
end

Screen('Preference', 'DefaultFontName', 'Courier New');
Screen('TextSize', MainWindow, 34);
Screen('TextStyle', MainWindow, 1);

if realVersion
    HideCursor;
end

DATA.frameRate = round(Screen(MainWindow, 'FrameRate'));

% now set colors - UPDATED TO FOUR COLOURS 3/5/16 yet to check luminance
white = [255,255,255];
black = [0,0,0];
gray = [70 70 70];   %[100 100 100]
orange = [193 95 30];
green = [54 145 65];
blue = [37 141 165]; %[87 87 255];
pink = [193 87 135];
yellow = [255 255 0];
Screen('FillRect',MainWindow, black);

distract_col = zeros(5,3);

switch colBalance
    case 1
        distract_col(1,:) = blue;      % HV
        distract_col(2,:) = orange;      % LV
        distract_col(3,:) = green;      % NV
    case 2
        distract_col(1,:) = blue;
        distract_col(2,:) = green;
        distract_col(3,:) = orange;
    case 3
        distract_col(1,:) = orange;
        distract_col(2,:) = blue;
        distract_col(3,:) = green;
    case 4
        distract_col(1,:) = orange;
        distract_col(2,:) = green;
        distract_col(3,:) = blue;
    case 5
        distract_col(1,:) = green;
        distract_col(2,:) = blue;
        distract_col(3,:) = orange;
    case 6
        distract_col(1,:) = green;
        distract_col(2,:) = orange;
        distract_col(3,:) = blue;
end

distract_col(4,:) = gray;       % distractor absent trials
distract_col(5,:) = yellow;       % Practice colour

colourName = cell(3,1);

for ii = 1 : length(colourName)
    if distract_col(ii,:) == blue(1, :)
        colourName(ii) = {'BLUE'};
    elseif distract_col(ii,:) == orange(1, :)
        colourName(ii) = {'ORANGE'};
    elseif distract_col(ii,:) == green(1, :)
        colourName(ii) = {'GREEN'};
    end
end


phaseLength = zeros(3,1);
maxPointsPhase = zeros(1,3);

totalPoints = 0;

initialInstructions;

if eyeVersion
    %% SPECTRUM STUFF
    calibratedStatus = runCalibSpectrum;
    if calibratedStatus == 0    % If failed to calibrate
        disp('Failed to calibrate, so program has quit.');
        sca;
        rmpath(genpath(functionFoldername));
        return;
    end
end

Screen('TextSize', MainWindow, 42);
DrawFormattedText(MainWindow, 'Please let the experimenter know when you are ready', 'center', 'center' , white);
Screen(MainWindow, 'Flip');
RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar
KbWait([], 2);
Screen(MainWindow, 'Flip');

phaseLength(1) = runTrials(1);     % Practice phase

save(datafilename, 'DATA');

DrawFormattedText(MainWindow, 'Please let the experimenter know\n\nyou are ready to continue', 'center', 'center' , white);
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck(KbName('t'));   % Only accept T key to continue
KbWait([], 2);

exptInstructions;

if realVersion
    save(datafilename, 'DATA');
end

phaseLength(2) = runTrials(2);
phaseLength(3) = runTrials(3);

choicePointsWon = choiceTest;
frequencyTest;
knowledgeTest;

totalMaxPointsSearch = sum(maxPointsPhase(2:end));

propPoints = totalPoints / totalMaxPointsSearch;

sessionBonus = propPoints * upperBonus * 100;   % convert points into cents.

sessionBonus = 20 * ceil(sessionBonus/20);        % ... round this value UP to nearest 20 cents
sessionBonus = sessionBonus / 100;    % ... then convert back to dollars

if sessionBonus < lowerBonus
    sessionBonus = lowerBonus;
end

if sessionBonus > upperBonus
    sessionBonus = upperBonus;
end

DATA.session_Bonus = sessionBonus;
DATA.session_Points = totalPoints;
DATA.propPoints = propPoints;

DATA.end_time = datestr(now,0);

save(datafilename, 'DATA');

if exist('choicePointsWon', 'var')
    totalPoints = totalPoints + choicePointsWon;
end

DATA.totalPointsInclChoice = totalPoints;

if (realVersion == false && screenshotVersion == true)
    totalPoints = 25830;
    sessionBonus = 11.3;
end

showDebrief;

Screen('TextSize', MainWindow, 48);
Screen('TextStyle', MainWindow, 1);
[~, ny, ~] = DrawFormattedText(MainWindow, ['EXPERIMENT COMPLETE\n\nTotal points earned = ', separatethousands(totalPoints, ','), '\n\nTotal Bonus = ', num2str(sessionBonus, '%0.2f'), '\n\nWell done!'], 'center', 'center' , white, [], [], [], 1.4);

fid1 = fopen('Data\BehavData\_TotalBonus_summary.csv', 'a');
fprintf(fid1,'%d,%f\n', p_number, sessionBonus);
fclose(fid1);

DrawFormattedText(MainWindow, '\n\nPlease fetch the experimenter', 'center', ny , white, [], [], [], 1.5);

Screen(MainWindow, 'Flip');
% takeScreenshot;

%%
if eyeVersion
    overallEGdataFilename = [EGfolderName, '\GazeData', EGsubfolderNameString, '.mat'];
        
    for exptPhase = minPhase:maxPhase
        
        for trial = 1:phaseLength(exptPhase)
            inputFilename = [EGdataFilenameBase, 'Ph', num2str(exptPhase), 'T', num2str(trial), '.mat'];
            load(inputFilename);
            ALLGAZEDATA.EGdataPhase(exptPhase).EGdataTrial(trial).data = GAZEDATA;
            clear GAZEDATA;
        end
    end
    
    save(overallEGdataFilename, 'ALLGAZEDATA');
    rmdir([EGfolderName,'\',EGsubfolderNameString], 's');
end

RestrictKeysForKbCheck(KbName('ESCAPE'));   % Only accept ESC key to quit
KbWait([], 2);

rmpath(genpath(functionFoldername));       % Then add path to this folder and all subfolders

Screen('Preference', 'SkipSyncTests',0);

clc;

Screen('CloseAll');

clear all
