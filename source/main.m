%clear

addpath(genpath('skin-models'));
addpath(genpath('color-correction'));
addpath(genpath('color-space'));
addpath(genpath('feature-detection'));
addpath(genpath('external'));

global colormaps; colormaps = load('..\data\colormaps.mat');

% fix image_0138, image_0244
%TODO: if ellipse orientation fails, don't use skin mask on eye map
% see image_0024
% image_0063
image = imread('..\..\faces\image_0205.jpg');
%image = imread('..\data\DB2\ex_16.jpg');
%image = imread('..\data\DB2\bl_05.jpg');
%image = imread('..\data\DB2\cl_16.jpg');
%image = imread('..\data\DB2\il_01.jpg');
%image = imread('..\data\DB1\db1_16.jpg');
%image = imread('..\data\DB0\db0_1.jpg');
image = im2double(image);



detectFaceTriangle(image);



