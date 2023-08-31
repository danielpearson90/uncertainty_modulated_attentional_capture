
function trial = runTrials(exptPhase)

global MainWindow
global scr_centre DATA datafilename EGdataFilenameBase
global distract_col
global black gray yellow
global stim_size stimLocs circ_diam
global stimCentre aoiRadius
global fix_aoi_radius
global realVersion eyeVersion
global maxPointsPhase totalPoints
% SPECTRUM STUFF
global eyetracker trackerSampleRate


gamma = 0.35;    % SPECTRUM STUFF: Controls smoothing of displayed gaze location. Lower values give more smoothing

rewardHV(1) = 0;
rewardHV(2) = 100;
rewardLV(1) = 70;
rewardLV(2) = 100;
rewardNV = 50;

if eyeVersion
    gazePointDuration = 1 / trackerSampleRate;
end

if realVersion
    
    softTimeoutDuration = 0.8;     % soft timeout limit for later trials
    
    timeoutDuration = [4, 2, 2];     % [4, 2] timeout duration
    fixationTimeoutDuration = 4;    % 5 fixation timeout duration
    
    iti = 1.2;            % 1.2
    feedbackDuration = [0.7, 1.3, 1.3];       % [0.7, 1.4, 1.4]  FB duration: Practice, first block of expt phase, later in expt phase
    
    yellowFixationDuration = 0.3;     % Duration for which fixation cross turns yellow to indicate trial about to start
    blankScreenAfterFixationPause = 0.15;        % UPDATED 14/01/16 IN LINE WITH FAILING ET AL. PAPER
    
    initialPause = 2;   % 2 ***
    breakDuration = 15;  % 15 ***
    
    % SPECTRUM STUFF
    requiredTargetDwellTime = 0.1;     % Time that target must be fixated for trial to be successful
    omissionTimeLimit = 0;          % Dwell time on distractor that means this will be an omission trial
    requiredFixationDwellTime = 0.7;       % Time that fixation cross must be fixated for trial to begin
    
    pracTrials = 8;
    numExptBlocksPhase = [1, 8, 8];   % Phase 1 = practice, Phase 2 = single distractor only, Phase 3 = mixed single and double distractor
    
    singlePerBlock = [0, 7, 6];
    doublePerBlock = [0, 0, 2];

    blocksPerBreak = 1;

else
    
    softTimeoutDuration = 0.8;     % soft timeout limit for later trials
    
    timeoutDuration = [4, 2, 2];     % [4, 2] timeout duration
    fixationTimeoutDuration = 4;    % 5 fixation timeout duration
    
    iti = 1.2;            % 1.2
    feedbackDuration = [0.7, 1.3, 1.3];       % [0.7, 1.5, 1.5]  FB duration: Practice, first block of expt phase, later in expt phase
    
    yellowFixationDuration = 0.3;     % Duration for which fixation cross turns yellow to indicate trial about to start
    blankScreenAfterFixationPause = 0.15;        % UPDATED 14/01/16 IN LINE WITH FAILING ET AL. PAPER
    
    initialPause = 2;   % 2 ***
    breakDuration = 0.01;  % 15 ***
    
    % SPECTRUM STUFF
    requiredTargetDwellTime = 0.1;     % Time that target must be fixated for trial to be successful
    omissionTimeLimit = 0;          % Dwell time on distractor that means this will be an omission trial
    requiredFixationDwellTime = 0.7;       % Time that fixation cross must be fixated for trial to begin
    
    pracTrials = 8;
    numExptBlocksPhase = [1, 1, 2];   % Phase 1 = practice, Phase 2 = single distractor only, Phase 3 = mixed single and double distractor
    
    singlePerBlock = [0, 2, 2];
    doublePerBlock = [0, 0, 2];

    blocksPerBreak = 1;

end

savingGazeData = false;

if exptPhase == 1
    numTrials = pracTrials;
    distractorTypes = [5, 4];
    exptTrialsPerBlock = pracTrials;
    trialTypeArray = ones(exptTrialsPerBlock, 1);
    rewardAvailable = 0;
    numDoubleDistractPerBlock = 0;
else
    
    if eyeVersion
        % SPECTRUM STUFF
        savingGazeData = true;
    end
    
    numSingleDistractType = 6;
    numDoubleDistractType = 3;
    
    numTrialTypes = numSingleDistractType + numDoubleDistractType;
    
    distractorTypes = zeros(numTrialTypes,2);
    distractorTypes(1,:) = [1, 4];
    distractorTypes(2,:) = [1, 4];
    distractorTypes(3,:) = [2, 4];
    distractorTypes(4,:) = [2, 4];
    distractorTypes(5,:) = [3, 4];
    distractorTypes(6,:) = [3, 4];
    distractorTypes(7,:) = [1, 2];
    distractorTypes(8,:) = [1, 3];
    distractorTypes(9,:) = [2, 3];
    
    rewardAvailable = zeros(numTrialTypes, 1);
    rewardAvailable(1) = rewardHV(1);
    rewardAvailable(2) = rewardHV(2);
    rewardAvailable(3) = rewardLV(1);
    rewardAvailable(4) = rewardLV(2);
    rewardAvailable(5) = rewardNV;
    rewardAvailable(6) = rewardNV;
    rewardAvailable(7) = rewardNV;
    rewardAvailable(8) = rewardNV;
    rewardAvailable(9) = rewardNV;
    
    numSingleDistractPerBlock = singlePerBlock(exptPhase);
    numDoubleDistractPerBlock = doublePerBlock(exptPhase);
    
    numExptBlocks = numExptBlocksPhase(exptPhase);
    
    exptTrialsPerBlock = numSingleDistractType * numSingleDistractPerBlock + numDoubleDistractType * numDoubleDistractPerBlock;
    
    trialTypeArray = zeros(exptTrialsPerBlock, 1);
    
    loopCounter = 0;
    for ii = 1 : numSingleDistractType
        for jj = 1 : numSingleDistractPerBlock
            loopCounter = loopCounter + 1;
            trialTypeArray(loopCounter) = ii;
        end
    end
    
    for ii = 1 : numDoubleDistractType
        for jj = 1 : numDoubleDistractPerBlock
            loopCounter = loopCounter + 1;
            trialTypeArray(loopCounter) = numSingleDistractType + ii;
        end
    end
    
    numTrials = numExptBlocks * exptTrialsPerBlock;
    maxPointsPhase(exptPhase) = numExptBlocks*(sum(numSingleDistractPerBlock * rewardAvailable(1:numSingleDistractType)) + sum(numDoubleDistractPerBlock * rewardAvailable(numSingleDistractType+1:numSingleDistractType+numDoubleDistractType)));
end

shTrialTypeArray = shuffleTrialorder(trialTypeArray, numDoubleDistractPerBlock);

exptTrialsBeforeBreak = exptTrialsPerBlock * blocksPerBreak; %48 trials before each break


if ~eyeVersion
    ShowCursor('Arrow');
end


fixationPollingInterval = 0.02;    % SPECTRUM STUFF: Duration between successive polls of the eyetracker for gaze contingent stuff; during fixation display
trialPollingInterval = 0.01;      % Duration between successive polls of the eyetracker for gaze contingent stuff; during stimulus display

junkFixationPeriod = 0.1;   % Period to throw away at start of fixation before gaze location is calculated


stimLocs = 6;       % Number of stimulus locations
stim_size = 92;%    % 92 Size of stimuli
perfectDiam = stim_size + 10;   % Used in FillOval to increase drawing speed

circ_diam = 200; %200;    % Diameter of imaginary circle on which stimuli are positioned

fix_size = 20; %20;      % This is the side length of the fixation cross
fix_aoi_radius = 60; %fix_size * 3;

gazePointRadius = fix_size/2; %10;


% Create a rect for the fixation cross
fixRect = [scr_centre(1) - fix_size/2    scr_centre(2) - fix_size/2   scr_centre(1) + fix_size/2   scr_centre(2) + fix_size/2];


% Create a rect for the circular fixation AOI
fixAOIrect = [scr_centre(1) - fix_aoi_radius    scr_centre(2) - fix_aoi_radius   scr_centre(1) + fix_aoi_radius   scr_centre(2) + fix_aoi_radius];


[diamondTex, fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow] = setupStimuli(fix_size, gazePointRadius);


% Create a matrix containing the six stimulus locations, equally spaced
% around an imaginary circle of diameter circ_diam
stimRect = zeros(stimLocs,4);

for i = 0 : stimLocs - 1    % Define rects for stimuli and line segments
    stimRect(i+1,:) = [scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) - stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) - stim_size / 2   scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) + stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) + stim_size / 2];
end

stimCentre = zeros(stimLocs, 2);
for i = 1 : stimLocs
    stimCentre(i,:) = [stimRect(i,1) + stim_size / 2,  stimRect(i,2) + stim_size / 2];
end
distractorAOIradius = 2 * (circ_diam / 2) * sin(pi / stimLocs);       % This gives circular AOIs that are tangent to each other
targetAOIradius = round(stim_size * 0.75);        % This gives a smaller AOI that will be used to determine target fixations on each trial

aoiRadius = zeros(stimLocs);

distractOffsetArray = [-2, -1, 1, 2];   % Positions away from target for distractor location.

distractLoc = zeros(1,2);
trialDistractType = zeros(1,2);

trialCounter = 0;
block = 1;
trials_since_break = 0;



%% SPECTRUM STUFF
if eyeVersion
    gotFieldNames = 0;
    while ~gotFieldNames
        gazeData = eyetracker.get_gaze_data('flat');
        if ~isempty(gazeData)
            gazeFieldNames = fieldnames(gazeData);
            gotFieldNames = 1;
        end
    end
end
%%


WaitSecs(initialPause);

for trial = 1 : numTrials
    
    trialCounter = trialCounter + 1;    % This is used to set distractor type below; it can cycle independently of trial
    trials_since_break = trials_since_break + 1;
        
    if exptPhase == 1
        FB_duration = feedbackDuration(1);
    else
        if (exptPhase == 2 && block == 1)
            FB_duration = feedbackDuration(2);
        else
            FB_duration = feedbackDuration(3);
        end
        
    end
    
    targetLoc = randi(stimLocs);
    
    distractLocOffset = Sample(distractOffsetArray);
    distractLoc(1) = mod(targetLoc + distractLocOffset, stimLocs);
    distractLoc(2) = mod(targetLoc - distractLocOffset, stimLocs);
    for ii = 1:2
        if distractLoc(ii) == 0 ; distractLoc(ii) = 6; end
    end

    trialType = shTrialTypeArray(trialCounter);
    trialDistractType(1) = distractorTypes(trialType, 1);
    trialDistractType(2) = distractorTypes(trialType, 2);
    trialRewardAvailable = rewardAvailable(trialType);

    postFixationPause = blankScreenAfterFixationPause; %UPDATED IN LINE WITH FAILING ET AL. 14/01/16
    
    Screen('FillRect', stimWindow, black);  % Clear the screen from the previous trial by drawing a black rectangle over the whole thing
    
    
    for ii = 1 : stimLocs
        Screen('FillOval', stimWindow, gray, stimRect(ii,:), perfectDiam);       % Draw stimulus circles
        aoiRadius(ii) = distractorAOIradius;     % Set large AOIs around all locations (we'll change the AOI around the target location in a minute)
    end
    for ii = 1 : 2
        Screen('FillOval', stimWindow, distract_col(trialDistractType(ii),:), stimRect(distractLoc(ii),:), perfectDiam);      % Draw first coloured circle in distractor 1 location
    end
    Screen('DrawTexture', stimWindow, diamondTex, [], stimRect(targetLoc,:));       % Draw diamond in target location
    
    aoiRadius(targetLoc) = targetAOIradius;     % Set a special (small) AOI around the target
  
    Screen('FillRect',MainWindow, black);
    
    Screen('DrawTexture', MainWindow, fixationAOIsprite, [], fixAOIrect);
    Screen('DrawTexture', MainWindow, fixationTex, [], fixRect);
    
    
    %% SPECTRUM STUFF
    trialGazeData = struct;
    timeOnFixation = 0;
    lookingAtFixation = 0;
    fixated_on_fixation_cross = 0;
    fixationBadSamples = 0;
    fixationTimeout = 0;
    currentGazePoint = zeros(1,2);
    sampleCounter = 0;
    
    startFixationTime = Screen(MainWindow, 'Flip', [], 1);     % Present fixation cross

    % takeScreenshot;
    
    if eyeVersion
        
        eyetracker.get_gaze_data('flat');   % Immediately empty buffer
        
        while fixated_on_fixation_cross == 0
            Screen('DrawTexture', MainWindow, fixationAOIsprite, [], fixAOIrect);   % Redraw fixation cross and AOI, and draw gaze point on top of that
            Screen('DrawTexture', MainWindow, fixationTex, [], fixRect);
            
            WaitSecs(fixationPollingInterval);      % Pause between updates of eye position
            gazeData = eyetracker.get_gaze_data('flat');
            
            elapsedTime = GetSecs - startFixationTime;
            
            if ~isempty(gazeData)
                
                [eyeX, eyeY, goodSample] = findMeanGazeLocation(gazeData);    % Find mean gaze location during the previous polling interval
                
                numGazePointsInSample = length(gazeData.system_time_stamp);
                sampleCounter = sampleCounter + 1;
                
                if goodSample
                    if elapsedTime <= junkFixationPeriod
                        currentGazePoint = [eyeX, eyeY];        % If in junk period at start of trial, keep track of gaze location; this will determine starting point of gaze when the junk period ends
                    else
                        currentGazePoint = (1 - gamma) * currentGazePoint + gamma * [eyeX, eyeY];       % Calculate smoothed gaze location using weighted moving average of current and previous locations
                        Screen('DrawTexture', MainWindow, gazePointSprite, [], [currentGazePoint(1) - gazePointRadius, currentGazePoint(2) - gazePointRadius, currentGazePoint(1) + gazePointRadius, currentGazePoint(2) + gazePointRadius]);
                        Screen('DrawingFinished', MainWindow);
                        lookingAtFixation = checkEyesOnFixation(eyeX, eyeY);     % If some gaze has been detected, check whether this is on the fixation cross, or "everywhere else"
                    end
                    
                else
                    lookingAtFixation = 0;   % If no gaze detected, record gaze as not on fixation
                    fixationBadSamples = fixationBadSamples + 1;
                end
                
                if lookingAtFixation
                    timeOnFixation = timeOnFixation + numGazePointsInSample * gazePointDuration;
                end
                
            end
            
            if timeOnFixation >= requiredFixationDwellTime         % If fixated on target
                fixated_on_fixation_cross = 1;
            elseif elapsedTime >= fixationTimeoutDuration        % If time since start of fixation period > fixation timeout limit
                fixated_on_fixation_cross = 2;
                fixationTimeout = 1;
            end
            
            Screen(MainWindow, 'Flip');     % Update display with gaze point
            
        end
        
    else
        
        while fixated_on_fixation_cross == 0
            WaitSecs(fixationPollingInterval);
            [mouseX, mouseY] = GetMouse;
            
            lookingAtFixation = checkEyesOnFixation(mouseX, mouseY);
            
            if lookingAtFixation
                timeOnFixation = 1;
            end
            
            if timeOnFixation == 1
                fixated_on_fixation_cross = 1;
            elseif GetSecs - startFixationTime >= fixationTimeoutDuration
                fixated_on_fixation_cross = 2;
                fixationTimeout = 1;
            end
        end
    end
    
    fixationPropGoodSamples = 1 - double(fixationBadSamples) / double(sampleCounter);
    
    %%
    
    fixationTime = GetSecs - startFixationTime;      % Length of fixation period in ms
    
    
    Screen('DrawTexture', MainWindow, colouredFixationAOIsprite, [], fixAOIrect);
    Screen('DrawTexture', MainWindow, colouredFixationTex, [], fixRect);
    Screen(MainWindow, 'Flip');     % Present coloured fixation cross
    % takeScreenshot;
    
    WaitSecs(yellowFixationDuration);
    
    FixOff = Screen(MainWindow, 'Flip');     % Show fixation cross without circle (and record off time)
    
    Screen('DrawTexture', MainWindow, stimWindow);      % Copy stimuli to main window
    
    WaitSecs(postFixationPause-(GetSecs-FixOff)); % UPDATED 14/01/16 to ensure that post-fixation pause is as close to 150ms as possible
    
    
    
    %% SPECTRUM STUFF
    trialEnd = 0;
    timeOnLoc = zeros(1, stimLocs + 1);    % a slot for each stimulus location, and one for "everywhere else"
    trialBadSamples = 0;
    sampleCounter = 0;
    
    startTrialTime = Screen(MainWindow, 'Flip', [], 1);      % Present stimuli, and record start time (st) when they are presented.
    
    % takeScreenshot;

    if eyeVersion
        eyetracker.get_gaze_data('flat');   % Empty buffer
        
        while trialEnd == 0
            WaitSecs(trialPollingInterval);      % Pause between updates of eye position
            gazeData = eyetracker.get_gaze_data('flat');
            
            elapsedTime = GetSecs - startTrialTime;
            
            if ~isempty(gazeData)
                
                [eyeX, eyeY, goodSample] = findMeanGazeLocation(gazeData);    % Find mean gaze location during the previous polling interval
                
                numGazePointsInSample = length(gazeData.system_time_stamp);
                sampleCounter = sampleCounter + 1;
                
                if savingGazeData
                    trialGazeData.sample(sampleCounter) = gazeData;
                end
                
                if goodSample
                    stimSelected = checkEyesOnStim(eyeX, eyeY);     % If some gaze has been detected, check whether this is on the fixation cross, or "everywhere else"
                else
                    trialBadSamples = trialBadSamples + 1;
                    stimSelected = stimLocs + 1;
                end
                
                timeOnLoc(stimSelected) = timeOnLoc(stimSelected) + numGazePointsInSample * gazePointDuration;
                
            end
            
            if timeOnLoc(targetLoc) >= requiredTargetDwellTime         % If fixated on target
                trialEnd = 1;
            elseif elapsedTime >= timeoutDuration(exptPhase)        % If time since start of trial > timeout limit for this phase
                trialEnd = 2;
            end
            
        end
        
    else
        
        while trialEnd == 0
            WaitSecs(trialPollingInterval);
            [mouseX, mouseY] = GetMouse;
            
            stimSelected = checkEyesOnStim(mouseX, mouseY);
            
            timeOnLoc(stimSelected) = 1;
            
            if timeOnLoc(targetLoc) == 1
                trialEnd = 1;
            elseif GetSecs - startTrialTime >= timeoutDuration(exptPhase)
                trialEnd = 2;
            end
        end
    end
    
    trialPropGoodSamples = 1 - double(trialBadSamples) / double(sampleCounter);
    
    
    %%
    
    rt = GetSecs - startTrialTime;      % Response time
    
    Screen('Flip', MainWindow);
    
    timeout = 0;
    softTimeoutTrial = 0;
    omissionTrial = zeros(1,2);
    trialPay = 0;
    
    if trialEnd == 2
        timeout = 1;
    end
    
    if exptPhase == 1       % If this is practice
        fbStr = 'correct';
        if timeout == 1
            fbStr = 'TOO SLOW\n\nPlease try to look at the diamond more quickly';
        end
        
    else     % if this is NOT practice
        
        couldHaveWonStr = ['TOO SLOW\n\nYou could have won ', num2str(trialRewardAvailable), ' points'];
        
        for ii = 1 : 2
            if timeOnLoc(distractLoc(ii)) > omissionTimeLimit
                omissionTrial(ii) = 1;
            end
        end
        
        if rt > softTimeoutDuration      % If RT is greater than the "soft" timeout limit, don't get reward (but also don't get explicit timeout feedback)
            softTimeoutTrial = 1;
        end
        
        if timeout ~= 1 && softTimeoutTrial ~= 1      % If this trial is NOT an omission trial or a soft timeout then reward, otherwise pay zero
            trialPay = trialRewardAvailable;
            if trialPay == 1
                centCents = 'point';
            else
                centCents = 'points';
            end
            fbStr = ['+', num2str(trialPay), ' ', centCents];
        else
            trialPay = 0;
            fbStr = couldHaveWonStr;
        end
        
        totalPoints = totalPoints + trialPay;
        
    end
    
    Screen('TextSize', MainWindow, 48);
    DrawFormattedText(MainWindow, fbStr, 'center', 'center', yellow, [], [], [], 1.3);
    Screen('Flip', MainWindow);
    % takeScreenshot;
    
    WaitSecs(FB_duration);
    
    %            1      2      3             4                   5          6 7          8             9                        10               11                    12       13                14  15         16  17                    18        19           20         21  22           
    trialData = [block, trial, trialCounter, trials_since_break, targetLoc, distractLoc, fixationTime, fixationPropGoodSamples, fixationTimeout, trialPropGoodSamples, timeout, softTimeoutTrial, omissionTrial, rt, trialRewardAvailable, trialPay, totalPoints, trialType, trialDistractType, timeOnLoc(1,:)];
    
    if trial == 1
        DATA.trialInfo(exptPhase).trialData = zeros(numTrials, size(trialData, 2));
    end
    DATA.trialInfo(exptPhase).trialData(trial,:) = trialData(:);
    
    DATA.fixationTimeouts(exptPhase) = DATA.fixationTimeouts(exptPhase) + fixationTimeout;
    DATA.trialTimeouts(exptPhase) = DATA.trialTimeouts(exptPhase) + timeout;
    DATA.totalPoints = totalPoints;
        
    save(datafilename, 'DATA');
        
    %% SPECTRUM STUFF
    if savingGazeData
        EGdatafilename = [EGdataFilenameBase, 'Ph', num2str(exptPhase), 'T', num2str(trial), '.mat'];
        
        % This next bit puts the trial gaze data into a tidier format that will make later analysis easier
        GAZEDATA = struct;
        numTrialGazeSamples = length(trialGazeData.sample);
        overallRowCounter = 0;
        for ii = 1 : numTrialGazeSamples
            numSubsamples = length(trialGazeData.sample(ii).device_time_stamp);
            if numSubsamples > 0
                for jj = 1 : numSubsamples
                    overallRowCounter = overallRowCounter + 1;
                    for kk = 1 : length(gazeFieldNames)
                        GAZEDATA.(gazeFieldNames{kk})(overallRowCounter,:) = trialGazeData.sample(ii).(gazeFieldNames{kk})(jj,:);
                    end
                end
            end
        end
        
        save(EGdatafilename, 'GAZEDATA');
        
    end
    %%
    
    RestrictKeysForKbCheck(KbName('c'));
    startITItime = Screen('Flip', MainWindow);
    
    [~, keyCode, ~] = KbWait([], 2, startITItime + iti);    % Wait for ITI duration while monitoring keyboard
    
    RestrictKeysForKbCheck([]);
    
    % If pressed C during ITI period, run an extraordinary calibration, otherwise
    % carry on with the experiment
    if sum(keyCode) > 0
        if eyeVersion
            %% SPECTRUM STUFF
            try
                eyetracker.stop_gaze_data()    % Stop tracker
            catch
                a = 1; %#ok<NASGU>
            end
            runCalibSpectrum;     % Calibrate
            eyetracker.get_gaze_data('flat');   % Re-start tracker
            WaitSecs(initialPause);
            %%
        end
    end
    
    if mod(trial, exptTrialsPerBlock) == 0
        shTrialTypeArray = shuffleTrialorder(trialTypeArray, numDoubleDistractPerBlock);     % Re-shuffle order of distractors
        trialCounter = 0;
        DATA.blocksCompleted = block;
        block = block + 1;
    end
    
    if mod(trial, exptTrialsBeforeBreak) == 0
        if (trial ~= numTrials) || (trial == numTrials && exptPhase == 2)
            take_a_break(breakDuration, initialPause, 0, totalPoints); %removed the additional calibrations that would occur throughout expt 14/01/16
            trials_since_break = 0;
        end
    end
    
end

if eyeVersion
    try
        eyetracker.stop_gaze_data()    % SPECTRUM STUFF
    catch
        a = 1; %#ok<NASGU>
    end
end


Screen('Close', diamondTex);
Screen('Close', fixationTex);
Screen('Close', colouredFixationTex);
Screen('Close', fixationAOIsprite);
Screen('Close', colouredFixationAOIsprite);
Screen('Close', gazePointSprite);
Screen('Close', stimWindow);


end


%% SPECTRUM STUFF
function [eyeXpos, eyeYpos, goodSample] = findMeanGazeLocation(gazeData)
global screenRes

numGazePoints = length(gazeData.device_time_stamp);

goodSample = 1;

xPos = NaN(numGazePoints,2);    % Second dimension refers to eye (1 = left, 2 = right)
yPos = NaN(numGazePoints,2);

for ii = 1 : numGazePoints
    
    if gazeData.left_gaze_point_validity(ii)    % If left sample is valid, then copy the left-eye data to the position array
        xPos(ii,1) = gazeData.left_gaze_point_on_display_area(ii, 1);
        yPos(ii,1) = gazeData.left_gaze_point_on_display_area(ii, 2);
    end
    if gazeData.right_gaze_point_validity(ii)    % If right sample is valid, then copy the right-eye data to the position array
        xPos(ii,2) = gazeData.right_gaze_point_on_display_area(ii, 1);
        yPos(ii,2) = gazeData.right_gaze_point_on_display_area(ii, 2);
    end
    
    if ~gazeData.left_gaze_point_validity(ii)   % If left sample invalid, then duplicate the right-eye data in both slots (this may also be invalid, in which case we end up with NaN in both slots; that's OK)
        xPos(ii,1) = xPos(ii,2);
        yPos(ii,1) = yPos(ii,2);
    end
    if ~gazeData.right_gaze_point_validity(ii)   % If right sample invalid, then duplicate the left-eye data in both slots (this may also be invalid, in which case we end up with NaN in both slots; that's OK)
        xPos(ii,2) = xPos(ii,1);
        yPos(ii,2) = yPos(ii,1);
    end
    
end

eyeXpos = mean(xPos, 'all', 'omitnan');
eyeYpos = mean(yPos, 'all', 'omitnan');

if ~isnan(eyeXpos)  % If this is a real number, i.e. there are valid gaze samples
    eyeXpos = screenRes(1) * eyeXpos;
    eyeYpos = screenRes(2) * eyeYpos;
    
    if eyeXpos > screenRes(1)       % This guards against the possible bug that Tom identified where gaze can be registered off-screen
        eyeXpos = screenRes(1);
    end
    if eyeYpos > screenRes(2)
        eyeYpos = screenRes(2);
    end
    
else
    goodSample = 0;
    eyeXpos = 0;
    eyeYpos = 0;
end

end
%%


function detected = checkEyesOnStim(x, y)
global stimCentre aoiRadius stimLocs

detected = stimLocs + 1;
for s = 1 : stimLocs
    if (x - stimCentre(s,1))^2 + (y - stimCentre(s,2))^2 <= aoiRadius(s)^2
        detected = s;
        return
    end
end

end


function detected = checkEyesOnFixation(x, y)
global scr_centre fix_aoi_radius

detected = 0;
if (x - scr_centre(1))^2 + (y - scr_centre(2))^2 <= fix_aoi_radius^2
    detected = 1;
    return
end

end



function shuffArray = shuffleTrialorder(inArray, numDoubleDistractPerBlock)


acceptShuffle = 0;

while acceptShuffle == 0
    shuffArray = inArray(randperm(length(inArray)));     % Shuffle order of trial types
    acceptShuffle = 1;   % Shuffle always OK in practice phase
    if numDoubleDistractPerBlock > 0
        if shuffArray(1) > 6 || shuffArray(2) > 6
            acceptShuffle = 0;   % Reshuffle if either of the first two trials (which may well be discarded) are double distractor types
        end
    end
end

end



%%
function take_a_break(breakDur, pauseDur, runCalib, totalPointsSoFar)

global MainWindow white

if runCalib == 0
    
    [~, ny, ~] = DrawFormattedText(MainWindow, ['Time for a break\n\nSit back, relax for a moment! You will be able to carry on in ', num2str(breakDur),' seconds\n\nRemember that you should be trying to move your eyes to the diamond as quickly and as accurately as possible!'], 'center', 'center', white, 50, [], [], 1.5);
    
    DrawFormattedText(MainWindow, ['Total so far = ', separatethousands(totalPointsSoFar, ','), ' points'], 'center', ny + 150, white, 50, [],[], 1.5);
    
    Screen(MainWindow, 'Flip');
    WaitSecs(breakDur);
    % takeScreenshot;

else
    
    DrawFormattedText(MainWindow, 'Please fetch the experimenter', 'center', 'center', white);
    Screen(MainWindow, 'Flip');
    RestrictKeysForKbCheck(KbName('c'));   % Only accept C key to begin calibration
    KbWait([], 2);
    RestrictKeysForKbCheck([]);   % Re-enable all keys
    runCalibration;
    
end

RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar

DrawFormattedText(MainWindow, 'Please put your chin back in the chinrest,\nand press the spacebar when you are ready to continue', 'center', 'center' , white, [], [], [], 1.5);
Screen(MainWindow, 'Flip');
    % takeScreenshot;

KbWait([], 2);
Screen(MainWindow, 'Flip');

WaitSecs(pauseDur);

end

%%
function [diamondTex, fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow] = setupStimuli(fs, gpr)

global MainWindow
global fix_aoi_radius
global white black gray yellow
global stim_size

perfectDiam = stim_size + 10;   % Used in FillOval to increase drawing speed

% This plots the points of a large diamond, that will be filled with colour
d_pts = [stim_size/2, 0;
    stim_size, stim_size/2;
    stim_size/2, stim_size;
    0, stim_size/2];


% Create an offscreen window, and draw the two diamonds onto it to create a diamond-shaped frame.
diamondTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 stim_size stim_size]);
Screen('FillPoly', diamondTex, gray, d_pts);

% Create an offscreen window, and draw the fixation cross in it.
fixationTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 fs fs]);
Screen('DrawLine', fixationTex, white, 0, fs/2, fs, fs/2, 2);
Screen('DrawLine', fixationTex, white, fs/2, 0, fs/2, fs, 2);


colouredFixationTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 fs fs]);
Screen('DrawLine', colouredFixationTex, yellow, 0, fs/2, fs, fs/2, 4);
Screen('DrawLine', colouredFixationTex, yellow, fs/2, 0, fs/2, fs, 4);

% Create a sprite for the circular AOI around the fixation cross
fixationAOIsprite = Screen('OpenOffscreenWindow', MainWindow, black, [0 0  fix_aoi_radius*2  fix_aoi_radius*2]);
Screen('FrameOval', fixationAOIsprite, white, [], 1, 1);   % Draw fixation aoi circle

colouredFixationAOIsprite = Screen('OpenOffscreenWindow', MainWindow, black, [0 0  fix_aoi_radius*2  fix_aoi_radius*2]);
Screen('FrameOval', colouredFixationAOIsprite, yellow, [], 2, 2);   % Draw fixation aoi circle


% Create a marker for eye gaze
gazePointSprite = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 gpr*2 gpr*2]);
Screen('FillOval', gazePointSprite, yellow, [0 0 gpr*2 gpr*2], perfectDiam);       % Draw stimulus circles

% Create a full-size offscreen window that will be used for drawing all
% stimuli and targets (and fixation cross) into
stimWindow = Screen('OpenOffscreenWindow', MainWindow, black);
end
