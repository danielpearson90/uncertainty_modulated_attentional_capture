function exptInstructions

global MainWindow white black
global upperBonus lowerBonus
global eyeVersion


instructStr = {'The rest of this experiment is similar to the trials you have just completed.\nOn each trial, you should move your eyes to the DIAMOND shape as quickly and directly as possible.', ...
    ['From now on, you will be able to earn points for correct responses. This is important, because the points you earn will determine how much you get paid as a bonus at the end of the experiment.\n\nDepending on how many points you earn, your bonus will typically be between $', num2str(lowerBonus), ' and $', num2str(upperBonus), '.'], ...
    'On different trials, different numbers of points will be available to win. The number of points available on each trial will be between 0 and 100.', ...
    'The display on each trial will contain a coloured circle: either BLUE, GREEN, or ORANGE.\n\nThe number of points that are available on each trial depends on the coloured circle that is in the display.', ...
    'BUT NOTE: Your task is to look at the DIAMOND as quickly as you can, since this is how you actually win the points!\n\nSo the best strategy in this task is to ignore the coloured circles and look at the diamond as quickly and directly as possible.', ...
    'If you take too long to move your eyes to the diamond, you will receive no points. So you will need to move your eyes quickly!'};
    

instrWin = Screen('OpenOffscreenWindow', MainWindow, black);
Screen('TextSize', instrWin, 42);
Screen('TextStyle', instrWin, 0);
Screen('TextFont', instrWin, 'Segoe UI');


for ii = 1 : length(instructStr)
    
    if ii == 4 || ii == 5
        Screen('PutImage', instrWin, imread('distractor_example.tif', 'tif'));
    end
    
    textTop = 150;
    DrawFormattedText(instrWin, char(instructStr(ii)), 'centerblock', textTop , white, 83, [], [], 1.4);
    
    Screen('DrawTexture', MainWindow, instrWin);
    Screen('Flip', MainWindow);
    Screen('FillRect', instrWin, black);
    % takeScreenshot;
    RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar
    KbWait([], 2);
      
end

Screen('Flip', MainWindow);

DrawFormattedText(instrWin, 'Please tell the experimenter when you are ready to begin', 'center', 'center' , white);
DrawFormattedText(instrWin, 'EXPERIMENTER: Press C to recalibrate, T to continue with test', 'center', 800, white);
Screen('DrawTexture', MainWindow, instrWin);
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck([]); % Re-enable all keys

RestrictKeysForKbCheck([KbName('c'), KbName('t')]);   % Only accept keypresses from keys C and t
KbWait([], 2);
[~, ~, keyCode] = KbCheck;      % This stores which key is pressed (keyCode)
keyCodePressed = find(keyCode, 1, 'first');     % If participant presses more than one key, KbCheck will create a keyCode array. Take the first element of this array as the response
keyPressed = KbName(keyCodePressed);    % Get name of key that was pressed
RestrictKeysForKbCheck([]); % Re-enable all keys

if keyPressed == 'c' && eyeVersion == true
    runCalibSpectrum;
end

Screen('TextSize', MainWindow, 48);
DrawFormattedText(MainWindow, 'Please press SPACE when you are ready to begin', 'center', 'center' , [255 255 255]);
Screen(MainWindow, 'Flip');
RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar
KbWait([], 2);
Screen(MainWindow, 'Flip');

Screen('Close', instrWin);

end