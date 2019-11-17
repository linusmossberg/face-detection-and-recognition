function skin = evaluateSkinDensityModel2D(rgb, use_v_lim)

    if(~exist('use_v_lim','var') || isempty(use_v_lim))
        use_v_lim = true;
    end
    
    SM = createSkinDensityModel2D(false);
    hsv = rgb2hsv(rgb);
    hsv = centerSkinHue(hsv);
    is_image = length(size(hsv)) == 3;
    
    if(is_image)
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        skin_density_image = vectorizedGetDensity(h, s, v, SM, use_v_lim);
        
        % Use the average density of the skin density image as threshold
        % value to mask out the most probable skin pixels. This only
        % compares images against themselves, which works well for 
        % detecting underrepresented skin hues in the skin model.
        skin = skin_density_image > mean(skin_density_image(:));
        
    else
        h = hsv(1);
        s = hsv(2);
        v = hsv(3);
        
        skin_density = getDensity(h, s, v, SM, use_v_lim);
        
        skin = skin_density > SM.single_color_threshold;
    end
end

function density = getDensity(h, s, v, SM, use_v_lim)
    
    % Find position normalized to [0,1[ in limit range for each dim.
    % Position < 0 or >= 1 means that coordinate is not contained in grid.
    h_pos = (h - SM.h_lim(1)) / (SM.h_lim(2) - SM.h_lim(1));
    s_pos = (s - SM.s_lim(1)) / (SM.s_lim(2) - SM.s_lim(1));

    % Out Of Bounds, coordinate not contained in grid.
    OOB = h_pos < 0 || h_pos >= 1 || s_pos < 0 || s_pos >= 1;
    
    % Use Value dimension lower limit threshold
    if(use_v_lim)
        OOB = OOB || v < SM.v_low;
    end

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

function density = vectorizedGetDensity(h, s, v, SM, use_v_lim)
    
    h_pos = (h - SM.h_lim(1)) / (SM.h_lim(2) - SM.h_lim(1));
    s_pos = (s - SM.s_lim(1)) / (SM.s_lim(2) - SM.s_lim(1));
    
    dscr = ~(h_pos < 0 | h_pos >= 1 | s_pos < 0 | s_pos >= 1);
    
    if(use_v_lim)
        dscr = dscr & (v >= SM.v_low);
    end
    
    h_idx = 1 + floor(h_pos * (SM.grid_size - 1));
    s_idx = 1 + floor(s_pos * (SM.grid_size - 1));
    
    h_lerp = (1 + h_pos * (SM.grid_size - 1)) - h_idx;
    s_lerp = (1 + s_pos * (SM.grid_size - 1)) - s_idx;
    
    d11 = zeros(size(h)); d21 = zeros(size(h));
    d12 = zeros(size(h)); d22 = zeros(size(h));
    
    d11(dscr) = SM.density((s_idx(dscr) - 1) * SM.grid_size + h_idx(dscr));
    d21(dscr) = SM.density( s_idx(dscr)      * SM.grid_size + h_idx(dscr));
    d12(dscr) = SM.density((s_idx(dscr) - 1) * SM.grid_size + h_idx(dscr) + 1);
    d22(dscr) = SM.density( s_idx(dscr)      * SM.grid_size + h_idx(dscr) + 1);

    d11_d21 = d11 + h_lerp .* (d21 - d11);
    d12_d22 = d12 + h_lerp .* (d22 - d12);
    
    density = d11_d21 + s_lerp .* (d12_d22 - d11_d21);
end

