addpath(genpath('skin-models'));
addpath(genpath('color-correction'));
addpath(genpath('color-space'));
addpath(genpath('feature-detection'));
addpath(genpath('external'));

% fix image_0244
%image = imread('..\..\faces\image_0244.jpg');
%image = imread('..\data\DB2\ex_16.jpg');
image = imread('..\data\DB2\bl_04.jpg');
%image = imread('..\data\DB2\cl_01.jpg');
%image = imread('..\data\DB2\il_01.jpg');
%image = imread('..\data\DB1\db1_16.jpg');
%image = imread('..\data\DB0\db0_4.jpg');

%349

image = im2double(image);
figure(1)
subplot(1,2,1)
imshow(image)
face_triangle = detectFaceTriangle(image);
if(~isempty(fieldnames(face_triangle)))
    subplot(1,2,2)
    imshow(transformFace(image, face_triangle));
end



