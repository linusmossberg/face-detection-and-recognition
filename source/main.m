%clear

addpath(genpath('skin-models'));
addpath(genpath('color-correction'));
addpath(genpath('color-space'));
addpath(genpath('feature-detection'));
addpath(genpath('external'));

global colormaps; colormaps = load('..\data\colormaps.mat');

% fix image_0138 
%TODO: if ellipse orientation fails, don't use skin mask on eye map
% see image_0024
image = imread('..\..\faces\image_0155.jpg');
%image = imread('..\data\DB2\ex_01.jpg');
%image = imread('..\data\DB2\bl_01.jpg');
%image = imread('..\data\DB2\cl_01.jpg');
%image = imread('..\data\DB2\il_16.jpg');
%image = imread('..\data\DB1\db1_01.jpg');
%image = imread('..\data\DB0\db0_4.jpg');
image = im2double(image);
image = whiteBalance(image);
%imshow(image)
%image = autoExposure(image);

figure(1)
subplot(2,2,2)
[face_mask, skin] = faceMask(image, true);

skin = imdilate(skin, strel('disk', 3));
%skin = imdilate(skin, true(2));

[lower_face, upper_face] = ellipseFaceRegions(face_mask);

eye_mask = upper_face & ~skin;

eye_map = eyeMap(image, eye_mask);
mouth_map = mouthMap(image, lower_face);

subplot(2,2,3)
%imshow(mouth_map);
mouth_mask = mouth_map > 0.8;
imshow(mouth_map)
CC = bwconncomp(mouth_mask);
S = regionprops('table',CC, mouth_map,'MajorAxisLength','MinorAxisLength','Orientation', 'WeightedCentroid');
x = S.WeightedCentroid(:,1);
y = S.WeightedCentroid(:,2);
ellipse(S.MajorAxisLength/2, S.MinorAxisLength/2, deg2rad(-S.Orientation), x, y, 'r');

subplot(2,2,4)
imshow(eye_map);
% eye_mask = eye_map > graythresh(eye_map);
% eye_CC = bwconncomp(eye_mask);
% eye_labels = labelmatrix(eye_CC);
% eye_S = regionprops('table',eye_CC, eye_map,'MajorAxisLength','MinorAxisLength','Orientation', 'MeanIntensity', 'WeightedCentroid', 'Area');
% eye_mass = eye_S.Area .* eye_S.MeanIntensity;
% %eye_mask = ismember(eye_labels, find(ratio <= min(ratio)));
% disp(eye_S);
% disp(eye_mass)
% x = eye_S.WeightedCentroid(:,1);
% y = eye_S.WeightedCentroid(:,2);
% ellipse(eye_S.MajorAxisLength/2, eye_S.MinorAxisLength/2, deg2rad(-eye_S.Orientation), x, y, 'r');

subplot(2,2,1)

eyes = detectEyes(eye_map, eye_mask);
figure(1)

x = eyes(:,1);
y = eyes(:,2);

%[xmin ymin width height]

x_width = max(x) - min(x);

width = round(x_width * 2);
xmin = min(x) - x_width * 0.5;
ymin = min(y) - x_width * 0.5;
height = width;

crop_image = imcrop(image, [xmin ymin width height]);

x = x - xmin;
y = y - ymin;

imshow(crop_image)
hold on; plot(x, y, 'b.', 'MarkerSize', 16);
plot(x, y, 'wx', 'MarkerSize', 5, 'LineWidth', 0.5);
hold off;
% figure(2)
% imshow(image);
% hold on;
% plot(x, y, 'r+', 'MarkerSize', 30, 'LineWidth', 2);
% ellipse(S.MajorAxisLength/2, S.MinorAxisLength/2, deg2rad(-S.Orientation), x, y, 'r')

