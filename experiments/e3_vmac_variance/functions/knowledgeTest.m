function knowledgeTest

global MainWindow scr_centre DATA datafilename
global distract_col colourName
global white black gray yellow
global stim_size stimLocs circ_diam
global realVersion


if realVersion
    itiDuration = 0.5;    % 0.5
else
    itiDuration = 0.5;    % 0.5
end

showInstructions;

ShowCursor('Arrow');

numTestTypes = 3;
searchDisplaySize = 580;
displayScaling = 0.4;

searchDisplayVert = 310;

if isempty(stim_size)
    stim_size = 92;
    circ_diam = 200;
end
if isempty(stimLocs)
    stimLocs = 6;
end

perfectDiam = stim_size + 10;   % Used in FillOval to increase drawing speed

testWindow = Screen('OpenOffscreenWindow', MainWindow, black);
Screen('TextFont', testWindow, 'Segoe UI');

buttonText(1) = {'The number of\npoints available was\nthe same on every trial'};
buttonText(2) = {'The number of\npoints available varied\nfrom trial to trial'};


choiceOptionWidth = 450;
choiceOptionHeight = 200;
choiceOptionRect = [0,0,choiceOptionWidth,choiceOptionHeight];

choiceOptionWin = zeros(2,1);
for ii = 1 : 2
    choiceOptionWin(ii) = Screen('OpenOffscreenWindow', MainWindow, [40,40,40], choiceOptionRect);
    Screen('TextFont', choiceOptionWin(ii), 'Segoe UI');
    Screen('TextSize', choiceOptionWin(ii), 36);
    Screen('TextStyle', choiceOptionWin(ii), 1);
    Screen('FrameRect', choiceOptionWin(ii), yellow, [], 3);
    DrawFormattedText(choiceOptionWin(ii), char(buttonText(ii)), 'center', 'center', white, [], [], [], 1.2);
end

buttonOffset = 350;
buttonVertMid = 820;

buttonRect = zeros(2,4);
buttonRect(1,:) = CenterRectOnPoint(choiceOptionRect, scr_centre(1)-buttonOffset, buttonVertMid);
buttonRect(2,:) = CenterRectOnPoint(choiceOptionRect, scr_centre(1)+buttonOffset, buttonVertMid);


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

searchDispRect = [0, 0, searchDisplaySize, searchDisplaySize];
searchDisplayWin = Screen('OpenOffscreenWindow', MainWindow, black, searchDispRect);
Screen('FrameRect', searchDisplayWin, white, [], 1);


% Create the diamond shape as a texture
diamondTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 stim_size stim_size]);
Screen('FillPoly', diamondTex, gray, [stim_size/2, 0; stim_size, stim_size/2; stim_size/2, stim_size; 0, stim_size/2]);


sdRectSmall = displayScaling * searchDispRect;
displayRect = CenterRectOnPoint(sdRectSmall, scr_centre(1), searchDisplayVert);

distractLocArray = [-2, -1, 1, 2];   % Positions away from target for distractor location.

targetLoc = randi(stimLocs);
distractLocOffset = Sample(distractLocArray);

distractLoc = mod(targetLoc + distractLocOffset, stimLocs);

if distractLoc == 0
    distractLoc = 6;
end

testType = 1 : numTestTypes;
testType = Shuffle(testType);


for trial = 1 : numTestTypes

    Screen('Flip', MainWindow);
    WaitSecs(itiDuration);
    
    Screen('FillRect', testWindow, black);     % Blank screen
        
    for jj = 1 : stimLocs
        Screen('FillOval', searchDisplayWin, gray, stimRect(jj,:), perfectDiam);       % Draw stimulus circles
    end
    
    Screen('FillOval', searchDisplayWin, distract_col(testType(trial), :), stimRect(distractLoc,:), perfectDiam);      % Draw coloured circle in distractor location
    Screen('DrawTexture', searchDisplayWin, diamondTex, [], stimRect(targetLoc,:));       % Draw diamond in target location
    
    Screen('DrawTexture', testWindow, searchDisplayWin, [], displayRect);
    
    if strcmp('ORANGE', char(colourName(testType(trial))))
        questionString = ['Imagine you made a fast, correct response when the\ndisplay contained an ', char(colourName(testType(trial))), ' circle. For example...'];
        questionString2 = ['Which of the following options was true for trials with an ', char(colourName(testType(trial))), ' circle?'];
    else
        questionString = ['Imagine you made a fast, correct response when the\ndisplay contained a ', char(colourName(testType(trial))), ' circle. For example...'];
        questionString2 = ['Which of the following options was true for trials with a ', char(colourName(testType(trial))), ' circle?'];
    end
    
    Screen('TextSize', testWindow, 46);
    Screen('TextStyle', testWindow, 0);
    DrawFormattedText(testWindow, questionString, 'center', 70, white, [], [], [], 1.3);
    DrawFormattedText(testWindow, questionString2, 'center', 520, white, [], [], [], 1.3);
    Screen('TextSize', testWindow, 32);
    DrawFormattedText(testWindow, 'Please click on one of the options below to select your answer', 'center', 580, white);

    for ii = 1 : 2
        Screen('DrawTexture', testWindow, choiceOptionWin(ii), [], buttonRect(ii,:));
    end
        
    Screen('DrawTexture', MainWindow, testWindow);
    Screen('Flip', MainWindow);
    
    choiceMade = 0;
    
    while ~choiceMade
        [~, x, y, ~] = GetClicks(MainWindow, 0);
        for ii = 1 : 2
            if IsInRect(x, y, buttonRect(ii,:))
                choiceMade = ii;
            end
        end
    end
    
    trialData = [trial, testType(trial), targetLoc, distractLoc, choiceMade];
    
    if trial == 1
        DATA.knowledgeTestData = zeros(numTestTypes, size(trialData, 2));
    end
    DATA.knowledgeTestData(trial, :) = trialData(:);
    save(datafilename, 'DATA');
    
end

RestrictKeysForKbCheck([]); % Re-enable all keys
Screen(MainWindow, 'Flip');

for i = 1:2
    Screen('Close', choiceOptionWin(i));
end
Screen('Close', diamondTex);
Screen('Close', testWindow);
Screen('Close', searchDisplayWin);

end


function showInstructions()

global MainWindow scr_centre white gray

instructStr(1) = {'Just a few more questions now! Please try to answer as accurately as you can.'};

for ii = 1 : length(instructStr)
    
    oldTextSize = Screen('TextSize', MainWindow, 44);
    oldTextStyle = Screen('TextStyle', MainWindow, 0);
    oldTextFont = Screen('TextFont', MainWindow, 'Segoe UI');
    
    textLeft = 180;
    textTop = 150;
    characterWrap = 84;
    DrawFormattedText(MainWindow, char(instructStr(ii)), textLeft, textTop, white, characterWrap, [], [], 1.3);
    
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






