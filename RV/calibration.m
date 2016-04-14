%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calibration.m
% Group ID : VGIS 843
% Members : Andreea Daniela Ene
%           Yanis Guichi
%           Daniel Michelsanti
%           Rares Stef
% Date : 04/04/2016
% Robot Vision Mini-Project
% Matlab version: 8.1.0.267246
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

disp('Running calibration...');

%% Calibration of the camera
%  Performed by using the tutorial 'Measuring Planar Objects with a
%  Calibrated Camera' on the Mathworks website

% Create a set of calibration images.
images = imageSet('cal/jpg');
imageFileNames = images.ImageLocation;

% Detect calibration pattern.
[imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);

% Generate world coordinates of the corners of the squares of the
% checkerboard, knowing the actual size of a square (23.5x23.5)
squareSize = 23.5; % millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Calibrate the camera.
[cam_params, ~, estimationErrors] = estimateCameraParameters(...
    imagePoints, worldPoints);

%     % For debug. Uncomment if necessary
%     % Evaluate calibration accuracy.
%     figure; showReprojectionErrors(cam_params);
%     title('Reprojection Errors');
%     % show pattern-centric extrinsics
%     figure;
%     showExtrinsics(cam_params, 'PatternCentric');

disp('Calibration done');

clearvars -except cam_params;
load('data/data.mat');
save('data/data.mat');