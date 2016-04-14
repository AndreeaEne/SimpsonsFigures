%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% detection.m
% Group ID : VGIS 843
% Members : Andreea Daniela Ene
%           Yanis Guichi
%           Daniel Michelsanti
%           Rares Stef
% Date : 04/04/2016
% Robot Vision Mini-Project
% Matlab version: 8.1.0.267246
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

global brick_prop;

disp('Detection of the bricks...');

load('data/data.mat');
img_RGB = imread('data/cal00_un.jpg');

%% Compute camera extrinsics for the undistorted image 

% Detect the checkerboard.
[imagePoints, boardSize] = detectCheckerboardPoints(img_RGB);

% Compute rotation R and translation t of the camera.
% The 'extrinsics' function (which uses a numeric method) assumes that
% there is no lens distortion.
[R, t] = extrinsics(imagePoints, cam_params.WorldPoints, cam_params);

%% Convert the image using 2 color spaces:
% - HSV (to avoid that light affects the detection)
img_HSV = im2uint8(rgb2hsv(img_RGB));
% - HSL (to detect the white block)
img_HSL = im2uint8(rgb2hsl(im2double(img_RGB)));

% Split the channels
H=img_HSV(:,:,1);
S=img_HSV(:,:,2);
V=img_HSV(:,:,3);

H2=img_HSL(:,:,1);
S2=img_HSL(:,:,2);
L=img_HSL(:,:,3);

%    %% For debug, uncomment to use it
%     figure();
%     subplot(3,2,1), imshow(H)
%     subplot(3,2,2), imshow(S)
%     subplot(3,2,3), imshow(V)
%     subplot(3,2,4), imshow(img_RGB)
%     subplot(3,2,5), imshow(img_HSV)
% 
%     figure();
%     subplot(3,2,1), imshow(H2)
%     subplot(3,2,2), imshow(S2)
%     subplot(3,2,3), imshow(L)
%     subplot(3,2,4), imshow(img_RGB)
%     subplot(3,2,5), imshow(img_HSL)
% 
%     figure();imshow(img_RGB);
%     figure();imshow(img_HSV);
%     figure();imshow(img_HSL);


%% We use thresholds to detect the bricks
% IMPORTANT: The intervals should be disjoint

% H and S range for yellow
hY = [25 45];
sY = [100 220];

% H and S range for blue
hB = [140 160];
sB = [190 255];

% H and S range for green
hG = [100 120];
sG = [80 255];

% H and S range for orange
hO = [8 20];
sO = [160 255];

% L range for white
lW = [215 255];

% output: stores the binary image
output = logical(zeros(size(img_HSV,1), size(img_HSV,2)));

for i = 1:size(img_HSV,1)
    for j = 1:size(img_HSV,2)
        
        % Thresholds
        Y=img_HSV(i,j,2) > sY(1) && img_HSV(i,j,2) < sY(2);
        Y=img_HSV(i,j,1) > hY(1) && img_HSV(i,j,1) < hY(2) && Y;

        B=img_HSV(i,j,2) > sB(1) && img_HSV(i,j,2) < sB(2);
        B=img_HSV(i,j,1) > hB(1) && img_HSV(i,j,1) < hB(2) && B;

        G=img_HSV(i,j,2) > sG(1) && img_HSV(i,j,2) < sG(2);
        G=img_HSV(i,j,1) > hG(1) && img_HSV(i,j,1) < hG(2) && G;

        O=img_HSV(i,j,2) > sO(1) && img_HSV(i,j,2) < sO(2);
        O=img_HSV(i,j,1) > hO(1) && img_HSV(i,j,1) < hO(2) && O;
        
        W=img_HSL(i,j,3) > lW(1) && img_HSL(i,j,3) < lW(2);
        
        % Apply the conditions
        if Y || B || G || O || W
           output(i,j) = 1;
        end
    end
end

% figure(); imshow(output);


%% This step was not performed at the end
%     %% Perform the opening morphological operation to reduce noise
%      SE = strel('square',3);
%      output=imerode(output,SE);
%      output=imdilate(output,SE);
% 
%     %% For debug, uncomment to use it
%      figure(); imshow(output);


%% Detect the bricks by imposing constraints on the bounding boxes

% Set a range for width, height, and w/h ratio of the boxes in order to
% detect the bricks
w_bb = [65 150]; h_bb = [65 150];
ratio = [0.9 1.1];

% Find the bounding boxes of all the connected components
cc = bwconncomp(output);
stats = regionprops(cc, 'BoundingBox');
allBoundingBox = reshape([stats.BoundingBox], [4,size(stats,1)])';

% discard the bounding boxes that does not respect the conditions
condition = allBoundingBox(:,3)>w_bb(1) & allBoundingBox(:,3)<w_bb(2)...
    & allBoundingBox(:,4)>h_bb(1) & allBoundingBox(:,4)<h_bb(2) ...
    & allBoundingBox(:,3)./allBoundingBox(:,4) > ratio(1)...
    * ones(size(allBoundingBox,1),1)...
    & allBoundingBox(:,3)./allBoundingBox(:,4) < ratio(2)...
    * ones(size(allBoundingBox,1),1);
idx = find(condition); 
output = ismember(labelmatrix(cc), idx);  

% figure, imshow(output)

%% Draw the bounding boxes, the centroids, and the extrema

figure(); imshow(img_RGB);
hold on;

% save the parameters of the bounding box, the centroid and the extrema of
% each brick in 'stats'
stats = regionprops(output, 'BoundingBox', 'Centroid', 'Extrema');

% In brick_prop we store centroids (in world coordinates), color, and
% orientation of the bricks
brick_prop = zeros(length(stats),4);

% Draw the red rectangle for the bounding box
for k = 1 : length(stats)
    thisBB = stats(k).BoundingBox;
    rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
  'EdgeColor','r','LineWidth',2 )
end

% Draw the black star for the centroid
centroids = cat(1, stats.Centroid);
plot(centroids(:,1), centroids(:,2), 'k*');
world_centroids = pointsToWorld(cam_params, R, t, ...
        centroids);
brick_prop(:,1:2) = world_centroids;

% Draw the extrema for each brick
for i = 1:length(stats)
    world_extrema = pointsToWorld(cam_params, R, t, ...
        [stats(i).Extrema(4,:); stats(i).Extrema(6,:)]);
    sides = world_extrema(1,:) - world_extrema(2,:);
    
    plot(stats(i).Extrema(4,1), stats(i).Extrema(4,2), 'y*');
    plot(stats(i).Extrema(6,1), stats(i).Extrema(6,2), 'g*');
    
    % We calculate the orientation angle from the world coordinates of the
    % extrema, not from the pixel positions. In this way it is the actual
    % orientation in the world and it does not rely on the
    % position/orientation of the camera.
    OrientationAngle = 90+rad2deg(atan(-sides(2)/sides(1)));
    brick_prop(i,4) = OrientationAngle;
end

hold off;

f=getframe; imwrite(f.cdata,'data/cal00_det.jpg');
close(gcf);

%% Assign a color label to each brick

for k = 1 : length(stats)
    
    thisBB = stats(k).BoundingBox;
    % Upperleft corner of the bounding box
    ul = [thisBB(1),thisBB(2)];
    % Width and height of the bounding box 
    dim = [thisBB(3),thisBB(4)];
    % get a small image of the part inside the bounding box only 
    sub_image = output(ul(2):ul(2)+dim(2),ul(1):ul(1)+dim(1));
    
    % figure, imshow(sub_image);
    
    % H channel of sub_image region
    H_SI = H(ul(2):ul(2)+dim(2),ul(1):ul(1)+dim(1));
    % Get the mean value of the brick for H
    v = H_SI(:);
    sum_colorpixel = sum(v(sub_image(:)));
    sum_pixel = sum(sub_image(:));
    mean_color = floor(sum_colorpixel / sum_pixel);
    
    % S channel of sub_image region
    S_SI = S(ul(2):ul(2)+dim(2),ul(1):ul(1)+dim(1));
    % Get the mean value of the brick for S
    v = S_SI(:);
    sum_colorpixel = sum(v(sub_image(:)));
    mean_color = [mean_color floor(sum_colorpixel / sum_pixel)];
    
    % Condition on the colors, like before
    Y=mean_color(1) > hY(1) && mean_color(1) < hY(2);
    Y=mean_color(2) > sY(1) && mean_color(2) < sY(2) && Y;
    B=mean_color(1) > hB(1) && mean_color(1) < hB(2);
    B=mean_color(2) > sB(1) && mean_color(2) < sB(2) && B;
    G=mean_color(1) > hG(1) && mean_color(1) < hG(2);
    G=mean_color(2) > sG(1) && mean_color(2) < sG(2) && G;
    O=mean_color(1) > hO(1) && mean_color(1) < hO(2);
    O=mean_color(2) > sO(1) && mean_color(2) < sO(2) && O;

    % Encode the colors and put the value in brick_prop
    if G
        brick_prop(k,3) = 1;
    elseif B
        brick_prop(k,3) = 2;
    elseif O
        brick_prop(k,3) = 3;
    elseif Y
        brick_prop(k,3) = 5;
    else %White
        brick_prop(k,3) = 4;
    end
end

disp('Done');

