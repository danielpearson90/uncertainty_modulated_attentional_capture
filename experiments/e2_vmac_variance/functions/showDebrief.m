
function showDebrief

global MainWindow white black scr_centre

instructStr = {'The experiment is now complete - thanks for taking part!\n\nIn this study, we were investigating the factors that influence when people will be distracted. You may have found that sometimes, while you were searching for the diamond, you were distracted by the coloured shape shown in the display. This might be because you knew the coloured circle was providing information about how many points you could earn.\n\nWe are interested in whether the ''distractingness'' of the circle is influenced by variability in the reward that it signals: in the task you completed, different colours of circles were associated with different levels of variability in the size of the reward that was available.\n\nWe were measuring how likely it was that you were distracted by the coloured circle--how likely you were to look at the circle before looking at the diamond--as a function of the variability in reward that it signalled.'};

instrWin = Screen('OpenOffscreenWindow', MainWindow, black);
Screen('TextSize', instrWin, 38);
Screen('TextStyle', instrWin, 0);
Screen('TextFont', instrWin, 'Segoe UI');

textTop = 90;

contButtonWidth = 850;
contButtonHeight = 130;
contButtonVert = 950;

contButtonSize = [0 0 contButtonWidth contButtonHeight];
contButtonWin = Screen('OpenOffscreenWindow', MainWindow, [50,50,50], contButtonSize);
Screen('FrameRect', contButtonWin, white, [], 2);
Screen('TextSize', contButtonWin, 32);
Screen('TextFont', contButtonWin, 'Segoe UI');
DrawFormattedText(contButtonWin, 'Please click here to acknowledge that you have\nreceived this debriefing information', 'center', 50, white, [], [], [], 1.3);

contButtonRect = CenterRectOnPoint(contButtonSize, scr_centre(1), contButtonVert);

ShowCursor('Arrow');

for ii = 1 : length(instructStr)
    Screen('FillRect', instrWin, black);

    DrawFormattedText(instrWin, char(instructStr(ii)), 'centerblock', textTop , white, 100, [], [], 1.4);

    Screen('DrawTexture', MainWindow, instrWin);
    Screen('DrawTexture', MainWindow, contButtonWin, [], contButtonRect);
    Screen(MainWindow, 'Flip');

    clickedContButton = 0;
    while clickedContButton == 0
        [~, x, y, ~] = GetClicks(MainWindow, 0);
        if IsInRect(x, y, contButtonRect)
            clickedContButton = 1;
        end
    end
end

Screen(MainWindow, 'Flip');
Screen('Close', instrWin);
Screen('Close', contButtonWin);

end

