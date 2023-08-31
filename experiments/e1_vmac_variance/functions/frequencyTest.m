function frequencyTest


global MainWindow scr_centre DATA datafilename
global distract_col colourName
global white black gray yellow
global stim_size stimLocs circ_diam
global realVersion

ShowCursor('Arrow');

if realVersion
    freqTestITI = 1;
    instrPause = 0.001;
else
    freqTestITI = 0.01;
    instrPause = 0.01;
end

showInstructions(instrPause);

if isempty(stim_size)
    stim_size = 92;
    circ_diam = 200;
end
if isempty(stimLocs)
    stimLocs = 6;
end

ShowCursor('Hand');

numTestTypes = 3;

searchDisplaySize = 580;
displayScaling = 0.5;

searchDisplayVert = 350;

maxPoints = 100;    % Highest value on scale
scaleDivisions = 10;    % Divisions marked on rating scale
numDivisions= maxPoints/scaleDivisions;

cyan = [0,255,255];

perfectDiam = stim_size + 10;   % Used in FillOval to increase drawing speed


testType = 1 : numTestTypes;

testType = Shuffle(testType);

questionString2 = 'Please click on the scale to enter a value. You can then adjust your estimate if you like.\nOnce you are happy with your estimate, click the OK button.';


oldTextSize = Screen('TextSize', MainWindow, 44);
oldTextStyle = Screen('TextStyle', MainWindow, 1);
oldTextFont = Screen('TextFont', MainWindow, 'Courier New');


freqTestWin = Screen('OpenOffscreenWindow', MainWindow, black);
Screen('TextFont', freqTestWin, 'Segoe UI');




OKbuttonSize = [0, 0, 200, 80];
OKbuttonTex = Screen('OpenOffscreenWindow', MainWindow, [50, 50, 50], OKbuttonSize);
Screen('TextFont', OKbuttonTex, 'Segoe UI');
Screen('TextStyle', OKbuttonTex, 1);
Screen('TextSize', OKbuttonTex, 46);
DrawFormattedText(OKbuttonTex, 'OK', 'center', 'center', white);
Screen('FrameRect', OKbuttonTex, white , [], 2);

OKbuttonRect = CenterRectOnPoint(OKbuttonSize, scr_centre(1), 1010);


pointerRect = [0, 0, 14, 30];
pointerTex = Screen('OpenOffscreenWindow', MainWindow, [0, 0, 255], pointerRect);
Screen('FrameRect', pointerTex, [255,50,50], [], 2);

sliderBarWidth = 1200;
sliderBarHeight = 15;
sliderBarVert = 730;

sliderBarSize = [0, 0, sliderBarWidth, sliderBarHeight];
clickableArea = [0, 0, sliderBarWidth + 100, 150];

sliderBarRect = CenterRectOnPoint(sliderBarSize, scr_centre(1), sliderBarVert);
sliderClickRect = CenterRectOnPoint(clickableArea, scr_centre(1), sliderBarVert);
shiftClickRectDown = 20;
sliderClickRect(2) = sliderClickRect(2) + shiftClickRectDown;
sliderClickRect(4) = sliderClickRect(4) + shiftClickRectDown;

textLabelRect = [0, 0, 100, 60];
textLabelWin = Screen('OpenOffscreenWindow', MainWindow, black, textLabelRect);
Screen('TextFont', textLabelWin, 'Segoe UI');
Screen('TextStyle', textLabelWin, 0);
Screen('TextSize', textLabelWin, 36);



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


for trial = 1 : 3

    Screen('Flip', MainWindow);
    WaitSecs(freqTestITI);
    
    Screen('FillRect', freqTestWin, black);     % Blank screen
    
    
    for jj = 1 : stimLocs
        Screen('FillOval', searchDisplayWin, gray, stimRect(jj,:), perfectDiam);       % Draw stimulus circles
    end
    
    Screen('FillOval', searchDisplayWin, distract_col(testType(trial), :), stimRect(distractLoc,:), perfectDiam);      % Draw coloured circle in distractor location
    Screen('DrawTexture', searchDisplayWin, diamondTex, [], stimRect(targetLoc,:));       % Draw diamond in target location
    
    Screen('DrawTexture', freqTestWin, searchDisplayWin, [], displayRect);
    
    if strcmp('ORANGE', char(colourName(testType(trial))))
        questionString = ['On average, how many points would you earn\nwhen the display contained an ', char(colourName(testType(trial))), ' circle? For example...'];
    else
        questionString = ['On average, how many points would you earn\nwhen the display contained a ', char(colourName(testType(trial))), ' circle? For example...'];
    end
    
    Screen('TextSize', freqTestWin, 46);
    Screen('TextStyle', freqTestWin, 1);
    DrawFormattedText(freqTestWin, questionString, 'center', 70, white, [], [], [], 1.2);
    
    Screen('TextSize', freqTestWin, 32);
    Screen('TextStyle', freqTestWin, 0);
    DrawFormattedText(freqTestWin, questionString2, 'center', displayRect(4) + 100, white, [], [], [], 1.2);
    
    Screen('FillRect', freqTestWin, yellow, sliderBarRect);
    
    for ii = 0 : numDivisions
        Screen('FillRect', textLabelWin, black);
        DrawFormattedText(textLabelWin, num2str(ii*10), 'center', 30, yellow);
        xPos = round(sliderBarRect(1) + ii * (sliderBarWidth-1) / numDivisions);
        Screen('DrawTexture', freqTestWin, textLabelWin, [], CenterRectOnPoint(textLabelRect, xPos, sliderBarRect(4) + 70));
        Screen('DrawLine', freqTestWin, yellow, xPos+1, sliderBarRect(4), xPos+1, sliderBarRect(4) + 30, 1)
    end
    
    
%     Screen('FrameRect', freqTestWin, [255,100,100], sliderClickRect, 1);
    
    Screen('DrawTexture', MainWindow, freqTestWin);
    Screen('Flip', MainWindow);
    
    % takeScreenshot;
    
    ratingMade = 0;
    meanPoints = -1;
    
    while ~ratingMade
        [mX, mY, mButtons] = GetMouse;
        
        if sum(mButtons) > 0
            if IsInRect(mX, mY, sliderClickRect)
                if mX < sliderBarRect(1)
                    mX = sliderBarRect(1);
                elseif mX > sliderBarRect(3)
                    mX = sliderBarRect(3);
                end
                meanPoints = round((mX - sliderBarRect(1)) * maxPoints / sliderBarWidth);
                Screen('DrawTexture', MainWindow, freqTestWin);
                Screen('DrawTexture', MainWindow, pointerTex, [], CenterRectOnPoint(pointerRect, mX, sliderBarVert));
                DrawFormattedText(MainWindow, ['You have said: "On average, I would win ', num2str(meanPoints), ' points"'], 'center', 910, cyan);
                Screen('DrawTexture', MainWindow, OKbuttonTex, [], OKbuttonRect);
                Screen('Flip', MainWindow);
                
            elseif IsInRect(mX, mY, OKbuttonRect) && meanPoints >= 0
                ratingMade = 1;
                
            end
        end
    end
    
    trialData = [trial, testType(trial), targetLoc, distractLoc, meanPoints];
    
    if trial == 1
        DATA.freqTestData = zeros(numTestTypes, size(trialData, 2));
    end
    DATA.freqTestData(trial, :) = trialData(:);
    save(datafilename, 'DATA');
    
end

ShowCursor('Arrow');

Screen('Flip', MainWindow);

Screen('TextSize', MainWindow, oldTextSize);
Screen('TextStyle', MainWindow, oldTextStyle);
Screen('TextFont', MainWindow, oldTextFont);


Screen('Close', searchDisplayWin);
Screen('Close', diamondTex);
Screen('Close', freqTestWin);
Screen('Close', OKbuttonTex);
Screen('Close', pointerTex);
Screen('Close', textLabelWin);

end



function showInstructions(instrPause)

global MainWindow scr_centre white gray

instructStr(1) = {'As we mentioned previously, during the search task that you completed earlier, the colour of the circle in the display determined the number of points that you could win on each trial. When certain colours appeared in the display, you could potentially win more points than when other colours appeared.'};

instructStr(2) = {'You will now be asked to estimate, ON AVERAGE, how many points you could win in the search task when a particular colour of circle appeared in the display.\n\nPlease note that the reward that went with a particular colour may have varied from trial to trial. We are interested in your estimates of the AVERAGE reward that each colour signalled.\n\nYou should try to make your estimates as accurate as possible.'};


for ii = 1 : length(instructStr)
    
    oldTextSize = Screen('TextSize', MainWindow, 44);
    oldTextStyle = Screen('TextStyle', MainWindow, 0);
    oldTextFont = Screen('TextFont', MainWindow, 'Segoe UI');
    
    textLeft = 180;
    textTop = 150;
    characterWrap = 84;
    DrawFormattedText(MainWindow, char(instructStr(ii)), textLeft, textTop, white, characterWrap, [], [], 1.3);
    
    Screen('Flip', MainWindow, [], 1);
    
    contButtonWidth = 800;
    contButtonHeight = 100;
    contButtonVert = 930;
    
    contButtonSize = [0 0 contButtonWidth contButtonHeight];
    contButtonWin = Screen('OpenOffscreenWindow', MainWindow, gray, contButtonSize);
    Screen('TextSize', contButtonWin, 38);
    Screen('TextFont', contButtonWin, 'Segoe UI');
    DrawFormattedText(contButtonWin, 'Click here to continue', 'center', 'center', white);
    
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



