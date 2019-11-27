addpath(genpath('skin-models'));
addpath(genpath('color-correction'));
addpath(genpath('color-space'));
addpath(genpath('feature-detection'));
addpath(genpath('external'));

% fix image_0244
%image = imread('..\..\faces\image_0202.jpg');
image = imread('..\data\DB2\ex_12.jpg');
%image = imread('..\data\DB2\bl_04.jpg');
%image = imread('..\data\DB2\cl_12.jpg');
%image = imread('..\data\DB2\il_12.jpg');
%image = imread('..\data\DB1\db1_03.jpg');
%image = imread('..\data\DB0\db0_4.jpg');

image = im2double(image);

figure(1)
subplot(1,2,1)
imshow(image)
face = detectFace(image);
if(~isempty(face))
    subplot(1,2,2)
    imshow(face);
    hold on; 
    
    x = [ 153.6000 358.4000 256.0000 ];
    y = [ 212.6293 212.6293 439.4339 ];
    
    s = 0.5;
    
    plot(x, y, 'k.', 'MarkerSize', 64*s);
    plot(x, y, 'w.', 'MarkerSize', 48*s);
    plot(x, y, 'k.', 'MarkerSize', 32*s);
    plot(x, y, 'w.', 'MarkerSize', 10*s);
    hold off;
end



