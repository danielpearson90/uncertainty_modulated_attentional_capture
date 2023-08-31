function trackStatusPTB(window, eyetracker)

% Dot size in pixels
dotSizePix = 30;

[screenXpixels, screenYpixels] = Screen('WindowSize', window);

textColour = [255,255,255];

% Start collecting data
% The subsequent calls return the current values in the stream buffer.
% If a flat structure is prefered just use an extra input 'flat'.
% i.e. gaze_data = eyetracker.get_gaze_data('flat');
eyetracker.get_gaze_data();

Screen('TextSize', window, 20);

origin = [screenXpixels/4 screenYpixels/4];
size = [screenXpixels/2 screenYpixels/2];

penWidthPixels = 3;
baseRect = [0 0 size(1) size(2)];
frame = CenterRectOnPointd(baseRect, screenXpixels/2, screenYpixels/2);


while ~KbCheck
    
    DrawFormattedText(window, 'When correctly positioned press any key to start the calibration.', 'center', screenYpixels * 0.1, textColour);
    
    distance = [];
    
    Screen('FrameRect', window, [128,128,128], frame, penWidthPixels);

    gaze_data = eyetracker.get_gaze_data();
    
    if ~isempty(gaze_data)
        last_gaze = gaze_data(end);
        
        validityColor = [255,0,0];
        
        % Check if user has both eyes inside a reasonable tacking area.
        if last_gaze.LeftEye.GazeOrigin.Validity.value && last_gaze.RightEye.GazeOrigin.Validity.value
            left_validity = all(last_gaze.LeftEye.GazeOrigin.InTrackBoxCoordinateSystem(1:2) < 0.85) ...
                && all(last_gaze.LeftEye.GazeOrigin.InTrackBoxCoordinateSystem(1:2) > 0.15);
            right_validity = all(last_gaze.RightEye.GazeOrigin.InTrackBoxCoordinateSystem(1:2) < 0.85) ...
                && all(last_gaze.RightEye.GazeOrigin.InTrackBoxCoordinateSystem(1:2) > 0.15);
            if left_validity && right_validity
                validityColor = [0,255,0];
            end
        end
        
        
        % Left Eye
        if last_gaze.LeftEye.GazeOrigin.Validity.value
            %             distance = [distance; round(last_gaze.LeftEye.GazeOrigin.InUserCoordinateSystem(3)/10,1)];
            left_eye_pos_x = double(1-last_gaze.LeftEye.GazeOrigin.InTrackBoxCoordinateSystem(1))*size(1) + origin(1);
            left_eye_pos_y = double(last_gaze.LeftEye.GazeOrigin.InTrackBoxCoordinateSystem(2))*size(2) + origin(2);
            Screen('DrawDots', window, [left_eye_pos_x left_eye_pos_y], dotSizePix, validityColor, [], 2);
        end
        
        % Right Eye
        if last_gaze.RightEye.GazeOrigin.Validity.value
            %             distance = [distance;round(last_gaze.RightEye.GazeOrigin.InUserCoordinateSystem(3)/10,1)];
            right_eye_pos_x = double(1-last_gaze.RightEye.GazeOrigin.InTrackBoxCoordinateSystem(1))*size(1) + origin(1);
            right_eye_pos_y = double(last_gaze.RightEye.GazeOrigin.InTrackBoxCoordinateSystem(2))*size(2) + origin(2);
            Screen('DrawDots', window, [right_eye_pos_x right_eye_pos_y], dotSizePix, validityColor, [], 2);
        end
        
    end
    
    %      DrawFormattedText(window, sprintf('Current distance to the eye tracker: %.2f cm.',mean(distance)), 'center', screenYpixels * 0.85, textColour);
    
    
    % Flip to the screen. This command basically draws all of our previous
    % commands onto the screen.
    % For help see: Screen Flip?
    Screen('Flip', window);
    
end

eyetracker.stop_gaze_data();

end