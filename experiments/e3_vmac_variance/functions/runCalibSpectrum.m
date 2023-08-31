function calibratedStatus = runCalibSpectrum

global MainWindow eyetracker
global p_number
global calibrationNum

trackStatusPTB(MainWindow, eyetracker);
[calibratedStatus, calibration_result] = calibrationPTB(MainWindow, eyetracker);

calibrationNum = calibrationNum + 1;

filepath = ['Data\CalibrationData\P', num2str(p_number), '_Cal', num2str(calibrationNum)];

save(filepath,'calibration_result');

clear filepath;

end