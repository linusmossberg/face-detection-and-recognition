%clear

addpath(genpath('skin-models'));
addpath(genpath('color-correction'));
addpath(genpath('color-space'));
addpath(genpath('feature-detection'));
addpath(genpath('external'));

%image = imread('..\data\DB2\bl_02.jpg');
image = imread('..\data\DB2\cl_15.jpg');
%image = imread('..\data\DB2\il_16.jpg');
%image = imread('..\data\DB1\db1_10.jpg');
image = im2double(image);
image = whiteBalance(image);
%imshow(image)
%image = autoExposure(image);

figure(1)
subplot(2,2,1)
imshow(image)
subplot(2,2,2)
face_mask = faceMask(image, true);
eye_map = eyeMap(image, face_mask);
mouth_map = mouthMap(image, face_mask);
subplot(2,2,3)
imshow(mouth_map);
subplot(2,2,4)
imshow(eye_map);

