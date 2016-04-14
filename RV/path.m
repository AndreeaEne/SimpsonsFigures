%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% path.m
% Group ID : VGIS 843
% Members : Andreea Daniela Ene
%           Yanis Guichi
%           Daniel Michelsanti
%           Rares Stef
% Date : 04/04/2016
% Robot Vision Mini-Project
% Matlab version: 8.1.0.267246
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global simpsons_number;
global simpsons;
global brick_prop;
global num_colors;
global brick_sorted;

disp('Path generation...');

% col_needed: stores the number of bricks we need for each color
% The order is:
% green, blue, orange, white, yellow
col_needed = zeros(1, num_colors);

for i = 1:length(simpsons_number)
    num_current_simpson = simpsons_number(i);
    for k = 1 : size(simpsons,2)
        curr_col = simpsons(i,k);
        if curr_col ~= 0
            col_needed(curr_col) = ...
                col_needed(curr_col) + num_current_simpson;
        end
    end
end

% If there aren't enough bricks on the black area, it's not possible to
% build the figures. 
buildable = 1;
for i = 1 : length(col_needed) % Go through all the colors
    
    l = i * ones(size(brick_prop,1), 1);
    l = l == brick_prop(:,3);
    
    % Check if we have enough bricks to build the figures
    if col_needed(i) > sum(l);
        buildable = 0;
        break;
    end
end

%% Generate the path that the robot should follow to build the figures

% brick_sorted: stores a sorted list of the bricks
% The sorting is done assuming that the robot should position the brick of
% the same level of all the figures, before going to the next level.
brick_sorted = [];
if ~buildable
    % POP-UP ERROR - NOT ENOUGH BRICKS TO BUILD THE FIGURES
    h = msgbox('ERROR - NOT ENOUGH BRICKS TO BUILD THE FIGURES');
    disp('Figures cannot be built.');
else
    % brick_prop_temp: stores brick_prop and a column of 0s and 1s to 
    %                   see if the brick was taken before
    brick_prop_temp = [brick_prop zeros(size(brick_prop,1),1)];

    % First we place all the bricks of level 1, then the ones of level 2,
    % and so on
    for i = 1:size(simpsons,2)
        for j = 1:size(simpsons,1)
            n = simpsons_number(j);
            for k = 1:n
                col = simpsons(j,i);
                for l = 1:size(brick_prop_temp,1)
                    if col == 0 % Maggie has an height of 2
                            brick_sorted = [brick_sorted; ...
                                zeros(1,4),i];
                            break;
                    elseif brick_prop_temp(l, 5) == 0
                        if brick_prop_temp(l, 3) == col
                            % Take the brick
                            brick_prop_temp(l, 5) = 1;
                            % Add the brick to 'brick_sorted'
                            brick_sorted = [brick_sorted; ...
                                brick_prop_temp(l, 1:4), i];
                            break;
                        end
                    end
                end
            end
            
        end
    end

    disp('Done');
end








