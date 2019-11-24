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
%image = imread('..\..\faces\image_0080.jpg');
%image = imread('..\data\DB2\ex_16.jpg');
%image = imread('..\data\DB2\bl_16.jpg');
%image = imread('..\data\DB2\cl_16.jpg');
image = imread('..\data\DB2\il_07.jpg');
%image = imread('..\data\DB1\db1_04.jpg');
%image = imread('..\data\DB0\db0_1.jpg');
image = im2double(image);

% [face_mask, quality] = faceMask2(skin, image)

tic

pca_image = whiteBalance(image, false, 'PCA');
gw_image = whiteBalance(image, false, 'GW');
gc_image = whiteBalance(image, false, 'GC');

face_masks = cell(1,8);
clear quality;

[skin, skin_nolim] = evaluateSkinDensityModel2D(image);
[skin_pca, skin_nolim_pca] = evaluateSkinDensityModel2D(pca_image);
[skin_gw, skin_nolim_gw] = evaluateSkinDensityModel2D(gw_image);
[skin_gc, skin_nolim_gc] = evaluateSkinDensityModel2D(gc_image);

[face_masks{1}, quality(1)] = faceMask2(skin, image);
[face_masks{2}, quality(2)] = faceMask2(skin_pca, pca_image);
[face_masks{3}, quality(3)] = faceMask2(skin_gw, gw_image);
[face_masks{4}, quality(4)] = faceMask2(skin_gc, gc_image);

[q, idx] = max(quality);
if q < 1.9
    disp({'q' q 'idx' idx})
    [face_masks{5}, quality(5)] = faceMask2(skin_nolim, image);
    [face_masks{6}, quality(6)] = faceMask2(skin_nolim_pca, pca_image);
    [face_masks{7}, quality(7)] = faceMask2(skin_nolim_gw, gw_image);
    [face_masks{8}, quality(8)] = faceMask2(skin_nolim_gc, gc_image);
    
    [q, idx] = max(quality);
end

% if(sum(quality) >= 1)
%     face_mask = face_masks{idx};
%     face_mask_closed = imfill(imclose(face_mask, strel('disk',32)), 'holes');
%     eye_mask = ~face_mask & face_mask_closed;
%     eye_mask = bwareaopen(eye_mask, 400, 4);
%     
%     imshow(applyMask(image,eye_mask));
% else
%     imshow(skin)
% end

toc

disp({'q' q 'idx' idx})

% face = detectFace(image);
% if(~isempty(face))
%     %figure
%     %imshow(face);
% end



