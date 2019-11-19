%clear

addpath(genpath('skin-models'));
addpath(genpath('color-correction'));
addpath(genpath('color-space'));
addpath(genpath('feature-detection'));
addpath(genpath('external'));

global colormaps; colormaps = load('..\data\colormaps.mat');

%image = imread('..\..\faces\image_0052.jpg');
image = imread('..\data\DB2\bl_04.jpg');
%image = imread('..\data\DB2\cl_01.jpg');
%image = imread('..\data\DB2\il_16.jpg');
%image = imread('..\data\DB1\db1_07.jpg');
image = im2double(image);
image = whiteBalance(image);
%imshow(image)
%image = autoExposure(image);

figure(1)
subplot(2,2,1)
imshow(image)
subplot(2,2,2)
face_mask = faceMask(image, true);

[lower_face, upper_face] = ellipseFaceRegions(face_mask);

eye_map = eyeMap(image, upper_face);
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
eye_mask = eye_map > 0.7;
%contourf(eye_map)
CC = bwconncomp(eye_mask);
S = regionprops('table', CC, eye_map, 'Centroid', 'MajorAxisLength','MinorAxisLength','Orientation', 'WeightedCentroid');
x = S.WeightedCentroid(:,1);
y = S.WeightedCentroid(:,2);
ellipse(S.MajorAxisLength/2, S.MinorAxisLength/2, deg2rad(-S.Orientation), x, y, 'r');

% figure(2)
% imshow(image);
% hold on;
% plot(x, y, 'r+', 'MarkerSize', 30, 'LineWidth', 2);
% ellipse(S.MajorAxisLength/2, S.MinorAxisLength/2, deg2rad(-S.Orientation), x, y, 'r')

