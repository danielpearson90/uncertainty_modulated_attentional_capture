function pointsWon = choiceTest

global MainWindow scr_centre DATA datafilename
global distract_col
global white black gray yellow
global stim_size stimLocs circ_diam
global realVersion


if realVersion
    choiceTestFB = 1.8;   % 1.8
    choiceTestITI = 0.5;    % 0.5
    instrPause = 0.001;
    
    postPhasePause = 3;     % 3
    
    numChoiceBlocks = 2;    % 2
    
else
    choiceTestFB = 0.001;   % 2
    choiceTestITI = 0.001;    % 0.5
    instrPause = 0.001;
    
    postPhasePause = 0.001;
    
    numChoiceBlocks = 1;    %2
    
end

simTrialChoice = 50;    % Participants told this many trials will be run.

showInstructions(instrPause, simTrialChoice);

ShowCursor('Arrow');

numTestTypes = 6;


searchDisplaySize = 580;
displayScaling = 0.75;

searchDisplayVert = 600;
searchDisplayHoriz = 360;

oldTextSize = Screen('TextSize', MainWindow);
oldTextStyle = Screen('TextStyle', MainWindow, 0);
oldTextFont = Screen('TextFont', MainWindow, 'Segoe UI');

if isempty(stim_size)
    stim_size = 92;
    circ_diam = 200;
end
if isempty(stimLocs)
    stimLocs = 6;
end

perfectDiam = stim_size + 10;   % Used in FillOval to increase drawing speed

testType = 1 : numTestTypes;

testDistractType = [1,2,3,1,2,3];

testDistract = zeros(3, 2);

testDistract(1,1) = 1;
testDistract(1,2) = 2;

testDistract(2,1) = 1;
testDistract(2,2) = 3;

testDistract(3,1) = 2;
testDistract(3,2) = 3;


stimOrder = [1,1,1,2,2,2];


questionString = ['If you could choose one of these displays to appear for\nthe next ', num2str(simTrialChoice), ' trials of the search task, which would you choose?'];
questionString2 = ['Remember: You should choose the colour that will earn you as many points as possible over ', num2str(simTrialChoice), ' trials'];
questionString3 = 'Please make your choice by clicking on one of the displays';

choiceTestWin = Screen('OpenOffscreenWindow', MainWindow, black);
Screen('TextFont', choiceTestWin, 'Segoe UI');

Screen('TextStyle', choiceTestWin, 1);
Screen('TextSize', choiceTestWin, 46);
DrawFormattedText(choiceTestWin, questionString, 'center', 100, white, [], [], [], 1.2);

Screen('TextStyle', choiceTestWin, 0);
Screen('TextSize', choiceTestWin, 36);
DrawFormattedText(choiceTestWin, questionString2, 'center', round(searchDisplayVert - searchDisplaySize*displayScaling/2 - 80), white);

Screen('TextSize', choiceTestWin, 32);
DrawFormattedText(choiceTestWin, questionString3, 'center', round(searchDisplayVert + searchDisplaySize*displayScaling/2 + 140), white);


FBwindow = Screen('OpenOffscreenWindow', MainWindow, black);
Screen('TextFont', FBwindow, 'Segoe UI');
Screen('TextStyle', FBwindow, 0);
Screen('TextSize', FBwindow, 44);
DrawFormattedText(FBwindow, ['Choice registered.\n\nPoints for ', num2str(simTrialChoice), ' trials with this colour have been added to your total.'], 'center', 'center', white);


% Create a matrix containing the six stimulus locations, equally spaced
% around an imaginary circle of diameter circ_diam
stimRect = zeros(stimLocs,4);

for ii = 0 : stimLocs - 1    % Define rects for stimuli and line segments
    stimRect(ii+1,:) = [searchDisplaySize/2 - circ_diam * sin(ii*2*pi/stimLocs) - stim_size / 2, searchDisplaySize/2 - circ_diam * cos(ii*2*pi/stimLocs) - stim_size / 2, searchDisplaySize/2 - circ_diam * sin(ii*2*pi/stimLocs) + stim_size / 2, searchDisplaySize/2 - circ_diam * cos(ii*2*pi/stimLocs) + stim_size / 2];
end

stimCentre = zeros(stimLocs, 2);
for ii = 1 : stimLocs
    stimCentre(ii,:) = [stimRect(ii,1) + stim_size / 2,  stimRect(ii,2) + stim_size / 2];
end

searchDisplayWin = zeros(2,1);
searchDispRect = [0, 0, searchDisplaySize, searchDisplaySize];
for ii = 1 : 2
    searchDisplayWin(ii) = Screen('OpenOffscreenWindow', MainWindow, black, searchDispRect);
    Screen('FrameRect', searchDisplayWin(ii), white, [], 1);
end

% Create the diamond shape as a texture
diamondTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 stim_size stim_size]);
Screen('FillPoly', diamondTex, gray, [stim_size/2, 0; stim_size, stim_size/2; stim_size/2, stim_size; 0, stim_size/2]);


sdRectSmall = displayScaling * searchDispRect;
leftRect = CenterRectOnPoint(sdRectSmall, scr_centre(1) - searchDisplayHoriz, searchDisplayVert);
rightRect = CenterRectOnPoint(sdRectSmall, scr_centre(1) + searchDisplayHoriz, searchDisplayVert);

distractLocArray = [-2, -1, 1, 2];   % Positions away from target for distractor location.

displayRect = zeros(2,4);

trialCounter = 0;
pointsWon = 0;

for block = 1 : numChoiceBlocks
    
    testType = Shuffle(testType);
    
    for trial = 1 : numTestTypes
        
        Screen('Flip', MainWindow);
        WaitSecs(choiceTestITI);
        
        trialCounter = trialCounter + 1;
        
        targetLoc = randi(stimLocs);
        distractLocOffset = Sample(distractLocArray);
        
        distractLoc = mod(targetLoc + distractLocOffset, stimLocs);
        
        if distractLoc == 0
            distractLoc = 6;
        end
        
        if stimOrder(testType(trial)) == 1
            displayRect(1, :) = leftRect;
            displayRect(2, :) = rightRect;
        else
            displayRect(2, :) = leftRect;
            displayRect(1, :) = rightRect;
        end
        
        for ii = 1: 2
            for jj = 1 : stimLocs
                Screen('FillOval', searchDisplayWin(ii), gray, stimRect(jj,:), perfectDiam);       % Draw stimulus circles
            end
            
            Screen('FillOval', searchDisplayWin(ii), distract_col(testDistract(testDistractType(testType(trial)), ii), :), stimRect(distractLoc,:), perfectDiam);      % Draw coloured circle in distractor location
            Screen('DrawTexture', searchDisplayWin(ii), diamondTex, [], stimRect(targetLoc,:));       % Draw diamond in target location
            
            Screen('DrawTexture', choiceTestWin, searchDisplayWin(ii), [], displayRect(ii,:));
        end
        
        
        Screen('DrawTexture', MainWindow, choiceTestWin);
        
        Screen('Flip', MainWindow);
        
        % takeScreenshot;

        Screen('DrawTexture', MainWindow, FBwindow);
        
        choiceMade = 0;
        
        while ~choiceMade
            [~, x, y, ~] = GetClicks(MainWindow, 0);
            for ii = 1 : 2
                if IsInRect(x, y, displayRect(ii,:))
                    choiceMade = ii;
                end
            end
        end

        if testDistract(testDistractType(testType(trial)), choiceMade) == 2     % if chosen low-variance distractor
            meanReward = 85;
        else
            meanReward = 50;
        end

        trialData = [block, trial, trialCounter, testType(trial), testDistract(testDistractType(testType(trial)), :), stimOrder(testType(trial)), targetLoc, distractLoc, choiceMade, meanReward];
        
        if trialCounter == 1
            DATA.choiceTestData = zeros(numChoiceBlocks * numTestTypes, size(trialData, 2));
        end
        DATA.choiceTestData(trialCounter, :) = trialData(:);
        save(datafilename, 'DATA');
        
        pointsWon = pointsWon + meanReward * simTrialChoice;
        
        Screen('Flip', MainWindow);
        
        WaitSecs(choiceTestFB);
        
    end
end

DATA.choicePoints = pointsWon;

Screen('Flip', MainWindow);

Screen('TextSize', MainWindow, 46);
DrawFormattedText(MainWindow, ['ALL CHOICES MADE.\n\nYour choices have earned you an extra ', separatethousands(pointsWon, ','), ' points.\n\nThese points have been added to your total.'], 'center', 'center', white);

Screen(MainWindow, 'Flip', [], 1);

Screen('TextSize', MainWindow, 36);
DrawFormattedText(MainWindow, 'Press space to continue', 'center', 800, yellow);

WaitSecs(postPhasePause);
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar
KbWait([], 2);
RestrictKeysForKbCheck([]); % Re-enable all keys
Screen(MainWindow, 'Flip');


Screen('TextSize', MainWindow, oldTextSize);
Screen('TextStyle', MainWindow, oldTextStyle);
Screen('TextFont', MainWindow, oldTextFont);


for i = 1:2
    Screen('Close', searchDisplayWin(i));
end
Screen('Close', diamondTex);
Screen('Close', choiceTestWin);
Screen('Close', FBwindow);

end




function showInstructions(instrPause, simTrialChoice)

global MainWindow scr_centre white gray


instructStr(1) = {'The eye tracking task is now finished - it''s fine to take your chin out of the chin rest.\n\nDuring the previous task (which we call the SEARCH TASK), the number of points that you could win on each trial was determined by the colour of the coloured circle in the display. When certain colours appeared, you could potentially win more points than when other colours appeared.\n\nIn the next phase we will test what you have learned about the different colours of circles.'};
instructStr(2) = {['Imagine you could choose the colour of the circle that will appear in the display for the next ', num2str(simTrialChoice), ' trials of the search task.\n\nYou should pick the colour that will allow you to win the greatest number of points over those trials, since that will result in the largest cash bonus at the end of the experiment.']};
instructStr(3) = {['You will be shown two displays containing different colours and will be asked which you would prefer to have for the next ', num2str(simTrialChoice), ' trials of the search task.\n\nWe will then add to your total the number of points that you would have earned over ', num2str(simTrialChoice), ' trials with the colour of circle that you picked.\n\nSo you should try to pick the colour that will give the most points over the course of ', num2str(simTrialChoice), ' trials.']};


for ii = 1 : length(instructStr)
    
    oldTextSize = Screen('TextSize', MainWindow, 44);
    oldTextStyle = Screen('TextStyle', MainWindow, 0);
    oldTextFont = Screen('TextFont', MainWindow, 'Segoe UI');
    
    textLeft = 180;
    textTop = 150;
    characterWrap = 84;
    DrawFormattedText(MainWindow, char(instructStr(ii)), textLeft, textTop, white, characterWrap, [], [], 1.3);
    
    Screen('Flip', MainWindow, [], 1);
    
    contButtonWidth = 1000;
    contButtonHeight = 100;
    contButtonVert = 930;
    
    contButtonSize = [0 0 contButtonWidth contButtonHeight];
    contButtonWin = Screen('OpenOffscreenWindow', MainWindow, gray, contButtonSize);
    Screen('TextSize', contButtonWin, 38);
    Screen('TextFont', contButtonWin, 'Segoe UI');
    DrawFormattedText(contButtonWin, 'Click here with the mouse to continue', 'center', 'center', white);
    
    contButtonRect = CenterRectOnPoint(contButtonSize, scr_centre(1), contButtonVert);
    Screen('DrawTexture', MainWindow, contButtonWin, [], contButtonRect);
    
    
    WaitSecs(instrPause);
    
    Screen('Flip', MainWindow);
    ShowCursor('Arrow');
    
    % takeScreenshot;

    clickedContButton = 0;
    while clickedContButton == 0
        [~, x, y, ~] = GetClicks(MainWindow, 0);
        
        if IsInRect(x, y, contButtonRect)
            clickedContButton = 1;
        end
        
    end
    
    Screen('TextSize', MainWindow, oldTextSize);
    Screen('TextStyle', MainWindow, oldTextStyle);
    Screen('TextFont', MainWindow, oldTextFont);
    
    Screen('Close', contButtonWin);
    
end


end






