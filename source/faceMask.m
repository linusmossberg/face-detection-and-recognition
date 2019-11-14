function result = faceMask(rgb_image)
    result = skinModel(rgb_image);
    
    result = imfill(result,'holes');
    stats = regionprops(result, 'Area');
    largest_area = max([stats.Area]);
    result = bwareaopen(result, largest_area);
    
    result = imclose(result, strel('disk', 20));
    
    result = imfill(result,'holes');
end

