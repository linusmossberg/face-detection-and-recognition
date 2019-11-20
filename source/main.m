%clear

addpath(genpath('skin-models'));
addpath(genpath('color-correction'));
addpath(genpath('color-space'));
addpath(genpath('feature-detection'));
addpath(genpath('external'));

global colormaps; colormaps = load('..\data\colormaps.mat');

% fix image_0138
%image = imread('..\..\faces\image_0201.jpg');
%image = imread('..\data\DB2\ex_12.jpg');
%image = imread('..\data\DB2\bl_12.jpg');
image = imread('..\data\DB2\cl_09.jpg');
%image = imread('..\data\DB2\il_09.jpg');
%image = imread('..\data\DB1\db1_16.jpg');
image = im2double(image);
image = whiteBalance(image);
%imshow(image)
%image = autoExposure(image);

figure(1)
subplot(2,2,2)
[face_mask, skin] = faceMask(image, true);

[lower_face, upper_face] = ellipseFaceRegions(face_mask);

eye_map = eyeMap(image, upper_face & ~skin);
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

imshow(image)
%figure(2)
eyes = detectEyes(eye_map, upper_face);
figure(1)

x = eyes(:,1);
y = eyes(:,2);
hold on; plot(x, y, 'b+', 'MarkerSize', 8, 'LineWidth', 2);
hold off;
% figure(2)
% imshow(image);
% hold on;
% plot(x, y, 'r+', 'MarkerSize', 30, 'LineWidth', 2);
% ellipse(S.MajorAxisLength/2, S.MinorAxisLength/2, deg2rad(-S.Orientation), x, y, 'r')

