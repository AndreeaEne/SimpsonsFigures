%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% acquisition.m
% Group ID : VGIS 843
% Members : Andreea Daniela Ene
%           Yanis Guichi
%           Daniel Michelsanti
%           Rares Stef
% Date : 04/04/2016
% Robot Vision Mini-Project
% Matlab version: 8.1.0.267246
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

disp('Acquisition');

%% ACQUISITION FROM A CAMERA

% Get the stream from the camera. We know the information about the
% device we are using. For info of the devices available use the
% 'imaqhwinfo' function
vidobj = videoinput('macvideo', 2, 'ARGB32_1920x1080');

% Default Mac webcam for debug
% vidobj = videoinput('macvideo', 1, 'YCbCr422_640x480');

% Configure the object for manual trigger mode.
triggerconfig(vidobj, 'manual');

% Send data back to MATLAB.
start(vidobj);

% Get 30 snapshots to avoid problems with focus
for i = 1:30
    snapshot = getsnapshot(vidobj);
end

% Stop the device.
stop(vidobj);

% Show the snapshot
%figure(), imshow(snapshot);

% It is possible that the software is not able to detect the chessboard in
% the new image. In this case it will not be possible to perform the
% calibration and know where the points are in world coordinates.
% Verify that there is chessboard in the image
[points_1, ~] = detectCheckerboardPoints(snapshot);
[points_2, ~] = detectCheckerboardPoints(imread('cal/jpg/cal01.jpg'));

% image_captured == 1 if image is captured, 0 otherwise
image_captured = 0;

if size(points_1,1) ~= size(points_2,1)
    % POP-UP ERROR - CHESSBOARD NOT DETECTED
    save('data/data.mat', 'image_captured');
    h = msgbox('ERROR - CHESSBOARD NOT DETECTED');
    disp('Image is not captured');
else
    image_captured = 1;
    save('data/data.mat', 'image_captured');
    % Save the snapshot
    imwrite(snapshot, 'cal/jpg/cal00.jpg');
    disp('Image is captured');
end

