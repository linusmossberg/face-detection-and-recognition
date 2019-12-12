% Currently not really a function, just some experimentation with a
% 3-dimensional skin model that uses a convex hull to enclose skin regions 
% in the color space.

function hullSkinModel3D()
    % Takes a really long time to create, better to save the tile image to
    % disk and load it when experimenting.
    rep_faces = createRepresentativeFaceTiles();
    rep_faces_mask = imread('../data/skin-model/representative_faces_samples_fill.png');
    rep_faces_mask = rep_faces_mask == 255;
    
    skin_vector = reshape(rep_faces(rep_faces_mask), [], 3);
    skin_vector_ycbcr = rgb2ycbcr(skin_vector);
    %skin_vector_ycbcr = rgb2ycgcr(skin_vector);
    
    skin_vector_ycbcr = filterYCbCr(skin_vector_ycbcr);
    
    %k = boundary(skin_vector_ycbcr, 0.1);
    k = convhull(skin_vector_ycbcr, 'simplify', true);
    
    figure(1)
    subplot(1,3,2)
    plotColorSpace(skin_vector_ycbcr, ycbcr2rgb(skin_vector_ycbcr)); hold on;
    trisurf(k,skin_vector_ycbcr(:,1),skin_vector_ycbcr(:,2),skin_vector_ycbcr(:,3), 'FaceAlpha', 0);
    
    image = imread('..\data\faces\image_0259.jpg');
    image = im2double(image);
    image = whiteBalance(image, false, 'PCA');
    image = rgb2ycbcr(image);
    
    image_vec = reshape(image, [], 3);
    
    result = inhull(image_vec, skin_vector_ycbcr, k);
    
    mask = reshape(result, size(image,1), size(image,2));
    
    mask = bwareaopen(mask, 400, 4);
    mask = bwareaopen(~mask, 100, 4);
    mask = ~mask;
    CC = bwconncomp(mask);
    S = regionprops(CC, 'EulerNumber');
    L = labelmatrix(CC);
    mask = ismember(L, find([S.EulerNumber] < 0));
    stats = regionprops(mask, 'Area');
	mask = bwareaopen(mask, max([stats.Area]));
    mask = imfill(mask,'holes');
    
    figure(1)
    subplot(1,3,1)
    imshow(ycbcr2rgb(image))
    
    subplot(1,3,3)
    imshow(mask)
end

function result = filterYCbCr(YCbCr)
    Y = YCbCr(:,1);
    Cb = YCbCr(:,2);
    Cr = YCbCr(:,3);
    
    P = 0.1;
    
    keep = true(size(Y));
    for c = 1:3
        channel = YCbCr(:,c);
        
        [counts, values] = imhist(channel, 2^16);
        cumulative_counts = cumsum(counts);
        index = find(cumulative_counts >= numel(channel) * (P/100), 1, 'first');
        low = values(index);

        cumulative_counts = cumsum(counts, 'reverse');
        index = find(cumulative_counts >= numel(channel) * (P/100), 1, 'last');
        high = values(index);
        
        keep = keep & ((low <= channel) & (channel <= high));
    end
    
    Y(~keep) = [];
    Cb(~keep) = [];
    Cr(~keep) = [];
    
    result = [Y,Cb,Cr];
end

