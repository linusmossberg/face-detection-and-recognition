addpath(genpath('skin-models'));
addpath(genpath('color-correction'));
addpath(genpath('color-space'));
addpath(genpath('feature-detection'));
addpath(genpath('external'));

% fix image_0244
%image = imread('..\..\faces\image_0205.jpg');
%image = imread('..\data\DB2\ex_12.jpg');
image = imread('..\data\DB2\bl_07.jpg');
%image = imread('..\data\DB2\cl_12.jpg');
%image = imread('..\data\DB2\il_07.jpg');
%image = imread('..\data\DB1\db1_12.jpg');
%image = imread('..\data\DB0\db0_3.jpg');

image = im2double(image);

figure(1)
subplot(1,2,1)
imshow(image)
face = detectFace(image);
if(~isempty(face))
    subplot(1,2,2)
    imshow(face);
    hold on; 
    
    x = [ 54.8571 201.1429 128.0000 ];
    y = [ 70.8764 70.8764 232.8797 ];
    
    s = 0.5;
    
    plot(x, y, 'k.', 'MarkerSize', 64*s);
    plot(x, y, 'w.', 'MarkerSize', 48*s);
    plot(x, y, 'k.', 'MarkerSize', 32*s);
    plot(x, y, 'w.', 'MarkerSize', 10*s);
    hold off;
end



