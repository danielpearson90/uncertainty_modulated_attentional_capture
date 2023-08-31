function [calibrated, calibration_result] = calibrationPTB(window, eyetracker)        % Returns 1 if calibrated, 0 if calibration failed

Screen('Flip', window);     % Blank the screen

points_to_calibrate = [[0.2,0.2];[0.8,0.2];[0.5,0.5];[0.2,0.8];[0.8,0.8]];      % These are the locations (in proportions of screen width and height) that will be used for the calibration - e.g. [0.8,0.2] places a calibration point at 80% of screen width and 20% of screen height

% SET GENERAL SCREEN PARAMETERS
backgroundColour = [0,0,0];     % Screen background colour
textColour = [255,255,255];     % Text colour for instructions etc

% SET PARAMETERS FOR CALIBRATION PLOT
leftColor = [255, 0, 0];    % Colour of gaze markers for left eye in calibration plot
rightColor = [0, 255, 0] * 255;     % Colour of gaze markers for right eye in calibration plot
dotSizePix = 30;    % Size of markers for gaze points in calibration plot


% SET PARAMETERS FOR ANIMATED CIRCLES IN CALIBRATION DISPLAY
outerMarkerColour = [0, 255, 255];     % Colour of large (animated) marker in calibration display
innerMarkerColour = [255, 0, 0];       % Colour of small (inner) marker for participants to fixate in calibration display

maxMarkerSize = 80;     % Largest size of animated circle
minMarkerSize = 15;     % Size of small (inner) marker - and smallest size of animated circle
step = 3;   % Step size for frames of shrinking animation: set to smaller values for smoother animation
calibAnimationLoops = 2;    % Full loops of animation (shrinks from large to small)
calibFramePause = 0.01;  % Use this to slow down the animation (larger number = slower)

% Create frames for shrinking circle animation
maxMarkerRect = [0, 0, maxMarkerSize, maxMarkerSize];
numMarkerTex = 0;

for aa = minMarkerSize : step : maxMarkerSize
    numMarkerTex = numMarkerTex + 1;
    calibMarker(numMarkerTex) = Screen('OpenOffscreenWindow', window, backgroundColour, maxMarkerRect); %#ok<AGROW>
    Screen('FillOval', calibMarker(numMarkerTex), outerMarkerColour, CenterRect([0,0,aa,aa], maxMarkerRect));
    Screen('FillOval', calibMarker(numMarkerTex), innerMarkerColour, CenterRect([0,0,minMarkerSize,minMarkerSize], maxMarkerRect));
end


[screenWidth, screenHeight] = Screen('WindowSize', window);     % Get screen size
screenPixels = [screenWidth, screenHeight];

points_to_calibrate = Shuffle(points_to_calibrate, 2);  % Shuffle calibration points so they appear in a random order
points_to_calibrate_pixels = points_to_calibrate .* screenPixels;   % Multiply proportions by screen size so positions are in pixels

% Create window for showing calibration display and plot
calibWindow = Screen('OpenOffscreenWindow', window, backgroundColour);
Screen('BlendFunction', calibWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);     % This allows drawing of smooth, semi-transparent lines and points in calibration plot
Screen('TextFont', calibWindow, 'Calibri');    % Set font name etc for calibration window
Screen('TextSize', calibWindow, 32);
Screen('TextStyle', calibWindow, 0);


% Create calibration object
calib = ScreenBasedCalibration(eyetracker);

calibrating = true;

while calibrating
    eyetracker.get_gaze_data();     % Start tracker recording, so it's up and running when it's required to collect data for calibration
    % Enter calibration mode
    calib.enter_calibration_mode();

    WaitSecs(0.5);
    
    for i=1:length(points_to_calibrate)
        
        Screen('FillRect', calibWindow, backgroundColour);
        
        breakLoopFlag = 0;
        markerFrame = numMarkerTex;
        firstLoop = true;
        loopNum = 0;
        
        while ~breakLoopFlag
            
            Screen('DrawTexture', calibWindow, calibMarker(markerFrame), [], CenterRectOnPoint(maxMarkerRect, points_to_calibrate_pixels(i,1), points_to_calibrate_pixels(i,2)));
            Screen('DrawTexture', window, calibWindow);
            Screen('Flip', window);
            
            if firstLoop
                WaitSecs(0.5);
                firstLoop = false;
            end
            
            if markerFrame == 1
                markerFrameDirection = 1;
                loopNum = loopNum + 1;
            elseif markerFrame == numMarkerTex
                markerFrameDirection = -1;
            end
            markerFrame = markerFrame + 1 * markerFrameDirection;
            
            if loopNum == calibAnimationLoops
                
                calib.collect_data(points_to_calibrate(i,:));
                
                WaitSecs(0.2);
                Screen('Flip', window);
                breakLoopFlag = true;
            end
            
            WaitSecs(calibFramePause);
        end
        
    end
    
    Screen('FillRect', calibWindow, backgroundColour);
    DrawFormattedText(calibWindow, 'Calculating calibration result....', 'center', 'center', textColour);
    
    Screen('DrawTexture', window, calibWindow);
    Screen('Flip', window);
    Screen('FillRect', calibWindow, backgroundColour);
    
    % Blocking call that returns the calibration result
    calibration_result = calib.compute_and_apply();
    
    
    calib.leave_calibration_mode();
    
    if calibration_result.Status ~= CalibrationStatus.Success
        DrawFormattedText(calibWindow, 'Insufficient data for calibration\n\nPress any key to recalibrate, or escape to quit', 'center', 'center', textColour)
        Screen('DrawTexture', window, calibWindow);
        Screen('Flip', window);
        
        RestrictKeysForKbCheck([]);   % Re-enable all keys
        [~, keyCode, ~] = KbWait([], 2);
        if sum(keyCode) > 0
            if find(keyCode, 1, 'first') == KbName('ESCAPE')
                calibrated = 0;
                Screen('Close', calibWindow);
                Screen('Close', calibMarker);
                return;
            end
            clear keyCode;
            trackStatusPTB(window, eyetracker);
        end
        Screen('Flip', window);
        
        
    else    % If calibrated successfully
        
        % Calibration Result
        
        points = calibration_result.CalibrationPoints;
        
        for i=1:length(points)
            Screen('DrawDots', calibWindow, points(i).PositionOnDisplayArea.*screenPixels, dotSizePix*0.5, outerMarkerColour, [], 2);
            for j=1:length(points(i).RightEye)
                if points(i).LeftEye(j).Validity.value == CalibrationEyeValidity.ValidAndUsed
                    Screen('DrawDots', calibWindow, points(i).LeftEye(j).PositionOnDisplayArea.*screenPixels, dotSizePix*0.3, [leftColor, 128], [], 2);
                    Screen('DrawLines', calibWindow, ([points(i).LeftEye(j).PositionOnDisplayArea; points(i).PositionOnDisplayArea].*screenPixels)', 2, [leftColor, 128], [0 0], 2);
                end
                if points(i).RightEye(j).Validity.value == CalibrationEyeValidity.ValidAndUsed
                    Screen('DrawDots', calibWindow, points(i).RightEye(j).PositionOnDisplayArea.*screenPixels, dotSizePix*0.3, [rightColor, 128], [], 2);
                    Screen('DrawLines', calibWindow, ([points(i).RightEye(j).PositionOnDisplayArea; points(i).PositionOnDisplayArea].*screenPixels)', 2, [rightColor, 128], [0 0], 2);
                end
            end
            
        end
        
        
        DrawFormattedText(calibWindow, 'Press the ''R'' key to recalibrate or ''Space'' to continue....', 'center', screenPixels(2) * 0.95, textColour);
        
        Screen('DrawTexture', window, calibWindow);
        Screen('Flip', window);
        Screen('FillRect', calibWindow, backgroundColour);
        
        RestrictKeysForKbCheck([KbName('Space'), KbName('R')]);
        
        while 1
            [keyIsDown, ~, keyCode] = KbCheck;
            keyCode = find(keyCode, 1);
            if keyIsDown
                if keyCode == KbName('Space')
                    calibrating = false;
                    calibrated = 1;
                    break;
                elseif keyCode == KbName('R')
                    trackStatusPTB(window, eyetracker);
                    break;
                end
                KbReleaseWait;
            end
        end
        
        Screen('Flip', window);
        
    end
    
end

eyetracker.stop_gaze_data();

Screen('Close', calibWindow);
Screen('Close', calibMarker);

end