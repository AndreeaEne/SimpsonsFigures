%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% showImage.m
% Group ID : VGIS 843
% Members : Andreea Daniela Ene
%           Yanis Guichi
%           Daniel Michelsanti
%           Rares Stef
% Date : 04/04/2016
% Robot Vision Mini-Project
% Matlab version: 8.1.0.267246
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function [ ] = showImage( s )
    img = imread(s);
    AxesH = axes('position', [0.25, 0.25, 0.75, 0.6], 'Visible', 'off');
    image(img, 'Parent', AxesH);
    imshow(img,[]);
end

