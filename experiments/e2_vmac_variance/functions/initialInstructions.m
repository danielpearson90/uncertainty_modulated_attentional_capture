
function initialInstructions

global MainWindow white scr_centre black

instructStr = {'On each trial a cross will appear inside a circle, and a yellow spot will show you where the computer thinks your eyes are looking. You should fix your eyes on the cross. After a short time the cross will turn yellow and the spot will disappear - this shows that the trial is about to start. You should keep your eyes fixed in the middle of the screen until the trial starts.', ...
    'Then a set of shapes will appear; an example is shown below. Your task is to move your eyes to look at the DIAMOND shape as quickly and as directly as possible.'};


instrWin = Screen('OpenOffscreenWindow', MainWindow, black);
Screen('TextSize', instrWin, 42);
Screen('TextStyle', instrWin, 0);
Screen('TextFont', instrWin, 'Segoe UI');


textTop = 120;

stimExample1Img=imread('Image1', 'jpg');
stimExample2Img=imread('Image2', 'jpg');
stimExample3Img=imread('Image3', 'jpg');
stimExampleRect = [0,0,size(stimExample1Img,2),size(stimExample1Img,1)];

RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar

for ii = 1 : length(instructStr)
    Screen('FillRect', instrWin, black);

    DrawFormattedText(instrWin, char(instructStr(ii)), 'centerblock', textTop , white, 80, [], [], 1.4);
    
    if ii == 1
        Screen('PutImage', instrWin, stimExample1Img, CenterRectOnPoint(stimExampleRect, scr_centre(1), 750));
        Screen('DrawTexture', MainWindow, instrWin);
        Screen(MainWindow, 'Flip');
        KbWait([], 2);
        Screen('PutImage', instrWin, stimExample2Img, CenterRectOnPoint(stimExampleRect, scr_centre(1), 750));
    else
        Screen('PutImage', instrWin, stimExample3Img, CenterRectOnPoint(stimExampleRect, scr_centre(1), 750));
    end
    Screen('DrawTexture', MainWindow, instrWin);
    Screen(MainWindow, 'Flip');

    % takeScreenshot;

    KbWait([], 2);

end


Screen('TextSize', MainWindow, 48);
Screen('TextStyle', MainWindow, 1);
Screen('TextFont', MainWindow, 'Courier');

DrawFormattedText(MainWindow, 'Please tell the experimenter when you are ready to begin', 'center', 'center' , white);
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck(KbName('c'));   % Only accept c key
KbWait([], 2);
Screen(MainWindow, 'Flip');
RestrictKeysForKbCheck([]); % Re-enable all keys

clear stimExample1Img stimExample2Img stimExample3Img

Screen('Close', instrWin);

end

