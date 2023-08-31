global screenshotVersion ssNum
if screenshotVersion
    ssNum = ssNum + 1;
    imwrite(Screen('GetImage', MainWindow),['screenshot', num2str(ssNum), '.png']);
end