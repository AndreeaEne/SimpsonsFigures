%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main.m
% Group ID : VGIS 843
% Members : Andreea Daniela Ene
%           Yanis Guichi
%           Daniel Michelsanti
%           Rares Stef
% Date : 04/04/2016
% Robot Vision Mini-Project
% Matlab version: 8.1.0.267246
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% IMPORTANT: Run the main from its directory in Matlab

clear all, close all, clc;

%% VARIABLE DEFINITIONS

global num_colors;
global simpsons;
global simpsons_number;
global brick_prop;
global brick_sorted;
global speed;

% num_colors: stores the number of colors of the bricks
num_colors = 5;

% simpsons: stores the colors of the bricks needed to build a simpson
% - - - - - - - - -
% Columns:
% 0 - no color
% 1 - green
% 2 - blue
% 3 - orange
% 4 - white
% 5 - yellow
% - - - - - - - - -
% 1 - homer  - [5 4 2]
% 2 - bart   - [5 3 2]
% 3 - maggie - [5 2 0]
% 4 - lisa   - [5 3 5]
% 5 - marge  - [2 5 1]
% fliplr is used because we start to build the figures from the base to the
% top
simpsons = fliplr([5 4 2; 5 3 2; 0 5 2; 5 3 5; 2 5 1]);

% simpsons_number: stores the number of simpsons to be built
% The order is homer, bart, maggie, lisa, and marge, as for 'simpsons'
simpsons_number = [0,0,0,0,0];

% brick_prop: properties of the bricks after detection
% Each row has a different brick, while the columns represent:
% X position; Y position; Color; Orientation.
brick_prop = [0,0,0,0];

% brick_sorted: stores a sorted list of the bricks
% the last column represents the level
brick_sorted = [];

% robot_speed: speed of the robot, between 0 and 1.
robot_speed = 0;
 
%% GUI
gui;
