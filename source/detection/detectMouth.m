function mouth = detectMouth(eyes, image)
    % Used to find a rough starting point for where the mouth might be 
    % relative to the eyes.
    [mu, sigma] = faceStats();
    
    % Left to right eye vector
    L2R = eyes.right - eyes.left;
    
    % Vector pointing down orthogonal to the eye vector. It originally has
    % the same length as the eye vector but is then scaled by the mean 
    % ratio mu to find where the mouth should be on average given the eyes.
    E2M = [-L2R(2) L2R(1)] * mu;
    
    % Find the mouth position by going half the distance between the
    % eyes and then continue down along the orthogonal eye to mouth vector.
    mouth = eyes.left + L2R/2 + E2M;
    
    if mouth(1) > size(image,2) || mouth(1) < 1 || mouth(2) > size(image,1) || mouth(2) < 1
        mouth = [];
        return;
    end
    
    % Create an ellipse mask at the initial mouth position
    width = size(image,2);
    height = size(image,1);

    [X, Y] = meshgrid(1:width, 1:height);
    
    eye_dist = sqrt(sum(L2R.^2));
    L2R_unit = L2R / eye_dist;
    
    cos_a = L2R_unit(1);
    sin_a = L2R_unit(2);

    x =  cos_a * (X - mouth(1)) + sin_a * (Y - mouth(2));
    y = -sin_a * (X - mouth(1)) + cos_a * (Y - mouth(2));
    
    a = 1.2 * (eye_dist / 2);
    
    % This gives a range of 3 sigma in ellipse height, which spans across 
    % 99.9% of mouth positions in the sampled data. (i.e. at least the 
    % center of 99.9% of mouths should be contained in the ellipse with 
    % this value of b)
    b = (1.5 * sigma * eye_dist); 
    
    % Expand half of width to include the whole mouths.
    b = b + a / 2;

    mouth_ellipse = (x).^2 / (a^2) + (y).^2 / (b^2) <= 1;
    
    mouth_map = mouthMap(image, mouth_ellipse);
    mouth_map(~mouth_ellipse) = 0;
    
    % Flatten mouth map to reduce variation
    mouth_map = rescale(mouth_map).^(1/3);
    
    mouth_mask = mouth_ellipse;
    
    prev_mouth_mask = [];
    
    face_angle = -rad2deg(atan2(sin_a,cos_a));
    SE = strel('line', 16, face_angle);
    
    for i = 1:10
        mouth_mask = mouth_map > graythresh(mouth_map(mouth_mask));
        
        % Close regions along the approximate mouth diagonal
        mouth_mask = imclose(mouth_mask, SE);

        % Close holes and keep only largest region
        mouth_mask = imfill(mouth_mask,'holes');
        mouth_mask = bwareafilt(mouth_mask, 1, 4);

        mouth_mask = imclose(mouth_mask, strel('disk', 4));
        mouth_mask = imfill(mouth_mask,'holes');

        mouth_map(~mouth_mask) = 0;
        mouth_map = rescale(mouth_map);

        % Find properties of the resulting region
        mouth_CC = bwconncomp(mouth_mask);
        mouth_S = regionprops('table', mouth_CC, mouth_map, 'WeightedCentroid', ...
                              'Orientation', 'Eccentricity', 'Area');
        
        if(isempty(mouth_S)), break; end
        
        % Break if mouth is aligned with face and if it is ellipse shaped 
        % enough. Almost always happens the first iteration.
        if(abs(mouth_S.Orientation - face_angle) < 15 && mouth_S.Eccentricity > 0.4)
            mouth = mouth_S.WeightedCentroid(1,:);
            break;
        else
            if (mouth_S.Area < 250) || (i ~= 1 && all(mouth_mask == prev_mouth_mask, 'all'))
                break;
            end
            prev_mouth_mask = mouth_mask;
        end
    end
    
    if mouth(1) > size(image,2) || mouth(1) < 1 || mouth(2) > size(image,1) || mouth(2) < 1
        mouth = [];
        return;
    end
    
    debug_ = false;
    
    if(debug_)
        %figure(1)
        debugPlot(mouth, eyes, image, mouth_ellipse, mouth_map);
    end
end

function debugPlot(mouth, eyes, image, mouth_ellipse, mouth_map)
    debug_img = applyMask(image, ~mouth_ellipse);
    rgb_mm = cat(3, mouth_map, mouth_map, mouth_map);
    debug_img = debug_img + applyMask(rgb_mm, mouth_ellipse);
    imshow(debug_img)

    x = [eyes.left(1) eyes.right(1) mouth(1)];
    y = [eyes.left(2) eyes.right(2) mouth(2)];
    
    s = 0.5;

    hold on; 
    line([x x(1)], [y y(1)], 'LineWidth', 2, 'Color', 'red')
    plot(x, y, 'k.', 'MarkerSize', 64*s);
    plot(x, y, 'w.', 'MarkerSize', 48*s);
    plot(x, y, 'k.', 'MarkerSize', 32*s);
    plot(x, y, 'w.', 'MarkerSize', 10*s);
    hold off;
end

