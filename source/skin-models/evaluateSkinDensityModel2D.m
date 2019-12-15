% Returns 1 for skin and 0 otherwise. Input can be either an image or a
% single rgb vector, in which case the output is either a mask or a single
% logical value respectively.

function [skin, skin_unlim] = evaluateSkinDensityModel2D(rgb)

    SM = createSkinDensityModel2D();
    hsv = rgb2hsv(rgb);
    hsv = centerSkinHue(hsv);
    
    is_image = length(size(hsv)) == 3;
    
    if(is_image)
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        
        skin_probability_image = getDensity(h, s, SM);
        
        % Use otsu thresholding on the skin probability image. This only 
        % compares images against themselves, which works well for 
        % detecting underrepresented skin tones.
        skin_unlim = skin_probability_image > graythresh(skin_probability_image);
        
        % Compute brightness (value) threshold limit of the resulting 
        % pixels using otsu and set any pixels that falls under this 
        % threshold to false. This is very effective at removing hair, 
        % background clutter and such that fits the skin model in hue and 
        % saturation but are less bright than what skin pixels tend to be. 
        % This assumes that skin pixels generally are brighter, which most 
        % often is the case for the caltech dataset.
        skin = skin_unlim;
        value_vec = v(skin);
        value_threshold = min(graythresh(value_vec), SM.v_low);
        value_mask = v < value_threshold;
        skin(value_mask) = 0;
        
%         skin_probability_image(value_mask) = 0;
%         vis = ind2rgb(im2uint8(skin_probability_image), colormaps.RdYlBu);
        
    else
        h = hsv(1);
        s = hsv(2);
        v = hsv(3);
        
        skin_density = getDensity(h, s, SM);
        
        skin_unlim = skin_density > SM.single_color_threshold;
        
        skin = skin_unlim & v > SM.v_low;
    end
end

% Fast vectorized method to get density from the skin model.
function density = getDensity(h, s, SM)

    % Find position normalized to [0,1[ in limit range for each dim.
    % Position < 0 or >= 1 means that coordinates are not in grid.
    h_pos = (h - SM.h_lim(1)) / (SM.h_lim(2) - SM.h_lim(1));
    s_pos = (s - SM.s_lim(1)) / (SM.s_lim(2) - SM.s_lim(1));
    
    % In Bounds, coordinates contained in grid.
    IB = ~(h_pos < 0 | h_pos >= 1 | s_pos < 0 | s_pos >= 1);
    
    % Find first corner index of cell containing this coordinate
    h_idx = 1 + floor(h_pos * (SM.grid_size - 1));
    s_idx = 1 + floor(s_pos * (SM.grid_size - 1));
    
    %--- BILINEAR INTERPOLATION ---%
    
    % Interpolation factor [0,1] for each dimension
    h_lerp = (1 + h_pos * (SM.grid_size - 1)) - h_idx;
    s_lerp = (1 + s_pos * (SM.grid_size - 1)) - s_idx;
    
    % 2x2 densities of the corners of the cell 
    % that contains this hue/sat coordinate.
    d = cell(2,2);
    d(1:2, 1:2) = { zeros(size(h)) };
    
    % Access density grid with (col-1)*row_width+row to vectorize lookup
    d{1,1}(IB) = SM.density((s_idx(IB) - 1) * SM.grid_size + h_idx(IB));
    d{2,1}(IB) = SM.density( s_idx(IB)      * SM.grid_size + h_idx(IB));
    d{1,2}(IB) = SM.density((s_idx(IB) - 1) * SM.grid_size + h_idx(IB) + 1);
    d{2,2}(IB) = SM.density( s_idx(IB)      * SM.grid_size + h_idx(IB) + 1);
    
    % Interpolate along hue
    d11_d21 = d{1,1} + h_lerp .* (d{2,1} - d{1,1});
    d12_d22 = d{1,2} + h_lerp .* (d{2,2} - d{1,2});
    
    % Interpolate result along saturation
    density = d11_d21 + s_lerp .* (d12_d22 - d11_d21);
end

% Slow but more readable method to get density of one hue+sat scalar pair.
function density = getSingleDensity(h, s, SM)
    
    % Find position normalized to [0,1[ in limit range for each dim.
    % Position < 0 or >= 1 means that coordinate is not contained in grid.
    h_pos = (h - SM.h_lim(1)) / (SM.h_lim(2) - SM.h_lim(1));
    s_pos = (s - SM.s_lim(1)) / (SM.s_lim(2) - SM.s_lim(1));

    % Out Of Bounds, coordinate not contained in grid.
    OOB = h_pos < 0 || h_pos >= 1 || s_pos < 0 || s_pos >= 1;

    if(OOB)
        density = 0;
    else
        %--- Bilinear interpolation ---%
        
        % Find first corner index of cell containing this coordinate
        h_idx = 1 + floor(h_pos * (SM.grid_size - 1));
        s_idx = 1 + floor(s_pos * (SM.grid_size - 1));

        % Interpolation factor [0,1] for each dimension
        h_lerp = (1 + h_pos * (SM.grid_size - 1)) - h_idx;
        s_lerp = (1 + s_pos * (SM.grid_size - 1)) - s_idx;
        
        % 2x2 densities of the corners of the cell 
        % that contains this hue/sat coordinate.
        d(1,1) = SM.density(h_idx    , s_idx);
        d(2,1) = SM.density(h_idx + 1, s_idx);
        d(1,2) = SM.density(h_idx    , s_idx + 1);
        d(2,2) = SM.density(h_idx + 1, s_idx + 1);

        % Interpolate along hue
        d11_d21 = d(1,1) + h_lerp * (d(2,1) - d(1,1));
        d12_d22 = d(1,2) + h_lerp * (d(2,2) - d(1,2));

        % Interpolate result along saturation
        density = d11_d21 + s_lerp * (d12_d22 - d11_d21); 
    end
end

