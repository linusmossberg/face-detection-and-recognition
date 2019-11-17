function result = faceMask(rgb_image, use_v_lim)
    result = evaluateSkinDensityModel2D(rgb_image, use_v_lim);
    
    result = bwareaopen(~result, 100, 4);
    result = ~result;
    
    result = bwareaopen(result, 400, 4);

    % Ruins a lot but required when for example  
    % beard cuts off mouth region from rest of face.
    result = imclose(result, strel('disk',6));
    
    CC = bwconncomp(result);
    S = regionprops(CC, 'EulerNumber');
    L = labelmatrix(CC);
    result = ismember(L, find([S.EulerNumber] < 1));
    
    result = imfill(result,'holes');
    
%     result = imclose(result, strel('disk',8));
%     result = imfill(result,'holes');
    
%     stats = regionprops(result, 'Area');
%     largest_area = max([stats.Area]);
%     result = bwareaopen(result, largest_area);

    result = imclose(result, strel('disk',20));
    result = imfill(result,'holes');
    
    result = imerode(result, strel('disk',10));
    
    imshow(result)
    
    % initial_contour_mask = bwconvhull(mask, 'Union');
    % mask = activecontour(rescale(skin_density), initial_contour_mask, 100, 'edge');
end

