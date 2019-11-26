%clear

addpath(genpath('skin-models'));
addpath(genpath('color-correction'));
addpath(genpath('color-space'));
addpath(genpath('feature-detection'));
addpath(genpath('external'));

%global colormaps; colormaps = load('..\data\colormaps.mat');

% fix image_0138, image_0244
%TODO: if ellipse orientation fails, don't use skin mask on eye map
% see image_0024
% image_0063
%image = imread('..\..\faces\image_0244.jpg');
%image = imread('..\..\faces\image_0032.jpg');
%image = imread('..\data\DB2\ex_12.jpg');
%image = imread('..\data\DB2\bl_16.jpg');
%image = imread('..\data\DB2\cl_05.jpg');
%image = imread('..\data\DB2\il_07.jpg');
%image = imread('..\data\DB1\db1_16.jpg');
%image = imread('..\data\DB0\db0_1.jpg');

%349

while true
    image_num = 1 + round(rand()*449)
    image = imread(['..\..\faces\image_' num2str(image_num,'%04d') '.jpg']);
    image = im2double(image);
    figure(1)
    imshow(image)
    text(25,25,['Image: ' num2str(image_num)], 'FontSize',18, 'Color', 'w');
    detectFaceTriangle2(image);
end
    
%     tic
%     skin = face_masks{idx};
%     %face_mask = imfill(imclose(skin, strel('disk', 32)), 'holes');
%     face_mask = imfill(skin, 'holes');
%     [nx,ny] = size(face_mask) ;
%     [y,x] = find(face_mask(:,:)==true) ;
%     I1 = false(nx,ny) ;
%     [X,Y] = meshgrid(1:ny,1:nx);
%     idx = boundary(x,y,0);
%     idx = inpolygon(X(:),Y(:),x(idx),y(idx)) ;
%     I1(idx) = true;
%     toc
%     
%     t2 = I1 & ~skin;
    
    %t2 = imopen(t2, strel('disk', 16));
    
    %imshow(t2)



