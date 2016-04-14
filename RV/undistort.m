%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% undistort.m
% Group ID : VGIS 843
% Members : Andreea Daniela Ene
%           Yanis Guichi
%           Daniel Michelsanti
%           Rares Stef
% Date : 04/04/2016
% Robot Vision Mini-Project
% Matlab version: 8.1.0.267246
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Undistort image generation...');

%% Undistort the image.
load('data/data.mat');

img = imread('cal/jpg/cal00.jpg');
[snapshot_un, newOrigin] = undistortImage(...
    img, cam_params, 'OutputView', 'full');

%     % For debug. Uncomment if necessary
%     figure;
%     subplot(2,1,1), imshow(img);
%     subplot(2,1,2), imshow(snapshot_un);

imwrite(snapshot_un, 'data/cal00_un.jpg');

disp('Done');



