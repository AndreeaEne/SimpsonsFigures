%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% robot.m
% Group ID : VGIS 843
% Members : Andreea Daniela Ene
%           Yanis Guichi
%           Daniel Michelsanti
%           Rares Stef
% Date : 04/04/2016
% Robot Vision Mini-Project
% Matlab version: 8.1.0.267246
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global brick_sorted;
global simpsons_number;
global simpsons;
global speed;

disp('Robot movements...');

%% Connection with the robot

r = RobotConnectorKUKA

%% Place the tool to home position

% Coordinates of the home position
home_Coord = [405.1720, 0.3470, 624.3108];
% Orientation of the tool in home position
home_Orient = [90.0000, 0, 180.0000];
% Home position
home = [home_Coord, home_Orient];

% Move the robot to home position
r.moveLinear(home, speed);

%% Variables definition

% brick_h: height of one brick
brick_h = 20;

% z_base: z coordinate for the first level (height above the bricks)
% It should be 459, but in debug use 479 so that the robot does not go down
% to take the bricks
z_base = 459;

% sec_h: security height to avoid collision with bricks in the same level
% when the robot moves over the the bricks
sec_h = 30;

% greenboard_orig: origin of the green board
greenboard_orient = [45, 0, 180];
greenboard_orig = [427, -230, z_base, greenboard_orient];

% checkerboard_orig: origin of the checkerboard
checkerboard_orig = [423, -515, z_base, greenboard_orient];

% switch_point: position where we switch between the different levels
z_black = z_base + sec_h;
switch_point = [300, -350, z_black, greenboard_orient];

% The gripper does not allow to build two figures too close. The distance
% between two bricks in the green board should be 63
dist = 63;

% Matrices to store the initial position (black area near to the
% checkerboard) and the final position (green board) of the bricks
init_position = [];
end_position = [];

%% Build the figures
if sum(simpsons_number) == 0 % Check if there are figures to build
    disp('No figures to build.');
else
    % We calculate the positions to place the bricks.
    % We place the simpsons in the following way (top view):
    %
    %     x o o o o o o
    %     o o o o o o o
    %     x o x o o o o
    %     o o o o o o o
    %     o o x o x o o
    %     o o o o o o o
    %     . . . . . . .
    %

    % start from the green board origin
    end_position = greenboard_orig;

    for i = 2:sum(simpsons_number)
        % we want to add dist once to x and once to y
        p = end_position(i-1,:);
        if mod(i,2) == 0 % if i is even
            % increase the x
            p(1) = p(1)+dist;
            end_position = [end_position; p];
        else
            %increase the y
            p(2) = p(2)+dist;
            end_position = [end_position; p];
        end
    end

    % Generate the position of all the bricks by changing the z value
    % (based on the level the brick sould be placed)
    for i = 2:size(simpsons,2)
        for j = 1:sum(simpsons_number)
            p = end_position(j,:);
            p(3) = p(3) + (i-1) * brick_h;
            end_position = [end_position; p];
        end
    end

    % At this point 'end_position' stores the location of the bricks in
    % the final position

    % Calculate the initial position of the bricks
    for i = 1 : size(brick_sorted,1)
        % Check if there is a brick to take
        if brick_sorted(i,3) == 0 % If it is 0 (eg last level of Maggie
                                  % no brick)
            % put a row of 0s in init_position
            init_position = [init_position; zeros(1,6)];
        else
            % Take the orientation from 'brick_sorted'
            if brick_sorted(i,4) > 90
                % To avoid that the last joint reaches the limit
                brick_sorted(i,4) = 180 - brick_sorted(i,4)
            end
            orientation =  ...
                [brick_sorted(i,4) checkerboard_orig(5:6)];

            % The coordinates of the bricks to take are expressed wrt the
            % coordinates of the checkerboard. For simplification, we place
            % the checkerboard so that its x and y axis are parallel to
            % the x and y axis of the world.
            % However, the y axis has an opposite direction.
            init_position = [ init_position; ...
                [checkerboard_orig(1) + brick_sorted(i,1), ...
                checkerboard_orig(2) - brick_sorted(i,2), ...
                checkerboard_orig(3), ...
                orientation]];
        end
    end

    % Start the movements

    % move the robot from home to switch_point
    r.moveLinear(switch_point,speed);

    % Repeat for all the bricks
    for i = 1 : size(init_position,1)
        if sum(init_position(i,:)) % if there is a brick to take (so
                                   % init_position(i,:) is not a row of 0s)
            % Go over the brick
            p_0 = [init_position(i,1:2),switch_point(3),[45 0 180]];
             r.moveLinear(p_0,speed);

            % Rotate the tool (by moving the last joint)
            joints = r.getJoint;
            joints(6) = joints(6) + init_position(i, 4);
            r.moveJoint(joints, speed);

            p_1 = r.getPosition;

            % Open the gripper
            openGrapper(r);

            % Go to the brick
            r.moveLinear([p_1(1:2), init_position(i,3), p_1(4:end)], speed);

            % Close the gripper
            closeGrapper(r);

            % Go up
            r.moveLinear(p_1,speed);

            % Rotate the tool
            r.moveLinear(p_0,speed);

            % Go back to switch_point
            r.moveLinear(switch_point,speed);

            % Go up with the security height
            z = end_position(i,3) + sec_h;
            p_2 = switch_point;
            p_2(3) = z;
            r.moveLinear(p_2, speed);

            % Go over the end position
            p_3 = end_position(i,:);
            p_3(3) = z;
            r.moveLinear(p_3, speed);

            % Go to the brick
            r.moveLinear(end_position(i,:),speed);

            % Open the gripper to release the brick
            openGrapper(r);

            % Go up
            r.moveLinear(p_3, speed);

            % Close the gripper
            closeGrapper(r);

            % Go over the switch point
            r.moveLinear(p_2, speed);

            % Go to switch_point
            r.moveLinear(switch_point,speed);

        end
    end

    % At the end move the robot to home position
    r.moveLinear(home, speed);

    disp('Done...');
end
