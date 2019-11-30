function result = autoExposure(image)
    gray_image = rgb2gray(image);
    [counts, intensities] = imhist(gray_image, 2^16);
    cumulative_counts = cumsum(counts);
    index = find(cumulative_counts >= numel(gray_image) * 0.5, 1, 'first');
    intensity = intensities(index);
    %if(intensity < 0.5); intensity = 0.5; end
    result = immultiply(image, 0.5 / intensity);
end

