% Creates a 2D histogram in hue+saturation space with the 
% skin point frequencies. High values within a bin in the grid
% means that a lot of skin points are located at the bin location.
% This can therefore be used to evaluate the probability of a color
% being a skin color in the HSV color space. I use the word density 
% instead of probability because probability implies that the sum of the 
% grid values is 1, which is not the case here.

function SkinModel = createSkinDensityModel2D(rebuild)

    global colormaps;
    
    if (rebuild || ~isfile('../data/skin-model/skin-model.mat'))
        
        % Load the tiled image of faces and the mask that locates the skin
        % patches on them.
        rep_faces = imread('../data/skin-model/representative_faces.png');
        rep_faces_mask = imread('../data/skin-model/representative_faces_samples_fill.png');
        rep_faces_mask = rep_faces_mask == 255;
        
        % Create a Nx3 vector with shifted and filtered HSV values of skin 
        % pixels from the tiled face image using the mask.
        skin_vector = reshape(rep_faces(rep_faces_mask), [], 3);
        skin_vector = im2double(skin_vector);
        skin_vector_hsv = rgb2hsv(skin_vector);
        skin_vector_hsv = centerSkinHue(skin_vector_hsv);
        skin_vector_hsv = filterHS(skin_vector_hsv);
    
        % Find the lower limit brightness value by finding the value 
        % above 1% of the outliers along Value dimension.
        %v_low = computeLowV(skin_vector_hsv, 0.005);
        %v_low = computeLowV(skin_vector_hsv, 0.003); %otsu
        v_low = computeLowV(skin_vector_hsv, 0.01);
        
        % Create the density grid
        grid_size = 512; % 64 almost 100%, 512 same
        [N,C] = hist3(skin_vector_hsv(:,1:2), [grid_size,grid_size]);
        
        % Normalize to [0,1] and flatten density to make variation less extreme.
        %density = rescale(N).^(1/2.5);
        density = rescale(N).^(1/3); % otsu
        
        h_values = cell2mat(C(1));
        s_values = cell2mat(C(2));
        
        h_lim = [min(h_values()), max(h_values)];
        s_lim = [min(s_values()), max(s_values)];
        
        skin_model_vis = im2uint8(imrotate(imresize(density, [512,512]), 90));
        imwrite(ind2rgb(skin_model_vis, colormaps.RdYlBu), '../data/skin-model/skin-model-vis.png');
        
        % Find a suitable density threshold value to use when a single
        % color value is being evaluated.
        [counts, values] = imhist(density, grid_size.^2);
        mass = rescale(cumsum(counts.*values));
        index = find(mass >= 0.66, 1, 'first');
        single_color_threshold = values(index);
        %single_color_threshold = graythresh(density);
        
        disp(graythresh(density))

        save('../data/skin-model/skin-model.mat', ...
            'density', ...
            'grid_size', ...
            'single_color_threshold', ...
            'v_low', ...
            'h_lim', ...
            's_lim');
    end
    
    SkinModel = load('../data/skin-model/skin-model.mat');
end

% Finds the percentage% low cutoff of Value dimension in HSV space.
function result = computeLowV(hsv, percentage)
    v = hsv(:,3);
    [counts, values] = imhist(v, 2^16);
    cumulative_counts = cumsum(counts);
    index = find(cumulative_counts >= numel(v) * percentage, 1, 'first');
    result = values(index);
end

% Filters out 0.01% of outliers on both ends of Hue and Saturation.
% The model is not affected directly by outliers since these are
% implicitly weighted less due to having lower density, but removing 
% them leaves more room on the density grid for more important values, 
% which increases their resolution.
function result = filterHS(hsv)
    h = hsv(:,1); 
    s = hsv(:,2);
    v = hsv(:,3);
    
    P = 0.01;
    
    keep = true(size(h));
    for c = 1:2
        channel = hsv(:,c);
        
        [counts, values] = imhist(channel, 2^16);
        cumulative_counts = cumsum(counts);
        index = find(cumulative_counts >= numel(channel) * (P/100), 1, 'first');
        low = values(index);

        cumulative_counts = cumsum(counts, 'reverse');
        index = find(cumulative_counts >= numel(channel) * (P/100), 1, 'last');
        high = values(index);
        
        keep = keep & ((low <= channel) & (channel <= high));
    end
    
    h(~keep) = [];
    s(~keep) = [];
    v(~keep) = [];
    
    result = [h,s,v];
end

