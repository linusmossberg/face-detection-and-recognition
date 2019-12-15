function [face_mask, quality] = faceMask(skin, image)
        
    orig_skin = skin;
    
    skin = bwareaopen(skin, 400, 4);
    skin = bwareaopen(~skin, 100, 4);
    skin = ~skin;
    
    CC = bwconncomp(skin);
    L = labelmatrix(CC);
    S = regionprops('table', CC, 'EulerNumber', 'Area', ...
                    'MajorAxisLength', 'MinorAxisLength', ...
                    'Orientation', 'Circularity', 'Eccentricity', ...
                    'Extent', 'FilledArea', 'BoundingBox', ...
                    'Centroid');
                
    if(isempty(S))
        quality = 0;
        face_mask = skin;
        return;
    end
                
    axis_ratio = S.MajorAxisLength ./ S.MinorAxisLength;
    
    % Find possible face candidates based on region properties
    candidates = find(S.EulerNumber < 1);
    candidates = intersect(candidates, find(abs(abs(S.Orientation) - 90) < 45 | abs(axis_ratio - 1) < 0.25));
    candidates = intersect(candidates, find(S.FilledArea > 15000));
    candidates = intersect(candidates, find(S.Eccentricity > 0.4 & S.Eccentricity < 0.92));
    candidates = intersect(candidates, find(S.Extent > 0.3 & S.Extent < 0.88)); % 0.3
    candidates = intersect(candidates, find(S.BoundingBox(:, 4) ./ S.BoundingBox(:, 3) < 2.25));
    candidates = intersect(candidates, find(S.FilledArea ./ S.Area > 1.01));
    
    if(isempty(candidates))
        quality = 0;
        face_mask = skin;
        return;
    end
    
    candidates = candidates';

    pairs = cell(1, max(candidates));
    BB = S.BoundingBox;
    
    % Pair certain non-candidate regions with candidates
    for c = candidates
        for region = 1:size(S,1)
            if(c == region)
                continue;
            end
            
            overlap_area = rectint(BB(c, :), BB(region, :));
            BB_area = BB(region, 3) * BB(region, 4);
            
            % Keep regions within the candidates bounding box if they
            % overlap by at least 45%. (ears, chin separate from face due
            % to beard etc.). Don't keep large regions.
            overlap_ratio = overlap_area / BB_area;
            
            if(overlap_ratio > 0.45 && S.Area(region) < 0.25 * S.Area(c))
                pairs{c} = [pairs{c} region];
            end
        end
    end
    
    % Find the circularity and perimeter ratio of resulting candidate
    % regions with paired regions. The perimeter ratio is the ratio between
    % the perimeter of the ellipse encompassing the region and the
    % perimeter of the actual region. The idea is that these probably
    % should match eachother closely if the region is a face.
    perimeter_ratios = cell(1, max(candidates));
    circularities = cell(1, max(candidates));
    remove = zeros(length(candidates),1); num = 0;
    for c = candidates
        perimeter_mask = ismember(L, [c pairs{c}]);
        perimeter_mask = imcrop(perimeter_mask, S.BoundingBox(c,:) + [0 0 50 50]);
        
        perimeter_mask = imfill(imclose(perimeter_mask, strel('disk', 32)), 'holes');
        perimeter_mask = bwareafilt(perimeter_mask, 1);

        C_CC = bwconncomp(perimeter_mask);
        C_S = regionprops('table', C_CC, 'Perimeter', ...
                          'MajorAxisLength', 'MinorAxisLength', 'Circularity');
                      
        a = C_S.MajorAxisLength / 2;
        b = C_S.MinorAxisLength / 2;
        ellipse_perimeter = pi * (3 * (a + b) - sqrt((3*a + b)*(a + 3*b)));
        
        perimeter_ratio = ellipse_perimeter / C_S.Perimeter;
        
        if(perimeter_ratio < 0.617)
            num = num + 1;
            remove(num) = c;
        end
        perimeter_ratios{c} = perimeter_ratio;
        circularities{c} = C_S.Circularity;
    end
    
    candidates = setdiff(candidates, remove);
    
    if(isempty(candidates))
        quality = 0;
        face_mask = skin;
        return;
    end
    
    % Add back in any clipped pixels to fill in overexposed areas. These 
    % will be masked by the boundary of the remaining candidate regions 
    % as the new candidates.
    clipped = rgb2gray(image) > 254/255;
    new_skin = clipped | orig_skin;
    new_skin = bwareaopen(new_skin, 400, 4);
    new_skin = bwareaopen(~new_skin, 100, 4);
    new_skin = ~new_skin;
    
    % Create a quality measure for the remaining face candidates based on 
    % several region properties
    candidates_quality = cell(1, max(candidates));
    for c = candidates
        
        q = 0;
        center = [size(skin,2), size(skin,1)] / 2;
        q = q + 5*5*(1 - pdist([ S.Centroid(c,:) ; center ]) / (max(size(skin)) / 2));
        q = q + (5*(2 * (perimeter_ratios{c} - 0.5))^2) ^ 2;
        q = q + (5 * circularities{c}) ^ 2;
        
        boundary_mask_crop = ismember(L, [c pairs{c}]);
        boundary_mask_crop = imcrop(boundary_mask_crop, S.BoundingBox(c,:));
        boundary_mask_crop = imfill(imclose(boundary_mask_crop, strel('disk', 32)), 'holes');
        
        crop_mask = boundary_mask_crop & imcrop(new_skin, S.BoundingBox(c,:));
        
        % New extent, including clipped pixels
        extent = sum(crop_mask(:)) / numel(crop_mask);
        q = q + (3.1 * (1/0.3) * extent) ^ 2;
        
        crop_mask = imclose(crop_mask, strel('disk', 6));
        hole_mask = imfill(crop_mask, 'holes') & ~crop_mask;
        
        % Ratio between the area of the holes in the region and the area of
        % the region. This ratio should be small for a good face mask since
        % the holes only should constitute eyes and mouth.
        hole_area_ratio = sum(hole_mask(:)) / sum(crop_mask(:));
        q = q - (10 * hole_area_ratio) ^ 2;
        
        hole_mask = bwareafilt(hole_mask, 3);
        hole_stats = regionprops('table', hole_mask, 'Centroid');

        % A good face mask should have the 3 largest holes be eyes and
        % mouth. This is verified by checking the minimum angle against the
        % expected minimum angle, which is the angle located at the mouth
        % in the face triangle.
        if(size(hole_stats,1) == 3)
            T = hole_stats.Centroid;
            Tt = T';
            
            [~, mouth_idx] = max(Tt(2,:));
            eye1_idx = 1 + mod(mouth_idx, 3);
            eye2_idx = 1 + mod(eye1_idx, 3);
            
            v1 = T(eye1_idx,:) - T(mouth_idx,:);
            v2 = T(eye2_idx,:) - T(mouth_idx,:);
            
            T_pos = [mean(Tt(1,:)), mean(Tt(2,:))];
            center = [size(hole_mask,2), size(hole_mask,1)] / 2;
            
            triangle_area_ratio = polyarea(Tt(1,:), Tt(2,:)) / numel(hole_mask);
            center_ratio = 1 - pdist([ T_pos ; center ]) / (max(size(hole_mask)) / 2);
            
            % Ratio between distance from the mouth to both of the eyes. 
            % These distances should be close to equal.
            eye_dist_ratio = sqrt(sum(v1.^2)) / sqrt(sum(v2.^2));
            if eye_dist_ratio > 1, eye_dist_ratio = 1/eye_dist_ratio; end
            
            % using |v1||v2|cos(a) = dot(v1,v2)
            min_angle = acos((sum(v1 .* v2)) / (sqrt(sum(v1.^2)) * sqrt(sum(v2.^2))));
            
            % mu is expected distance ratio between mouth to eyeline 
            % distance and eye to eye distance
            [mu, ~] = faceStats();
            expected_minimum_angle = 2*atan(0.5/mu);
            
            min_angle_ratio = 1 - abs(expected_minimum_angle - min_angle) / expected_minimum_angle;
            
            min_angle_limit = min_angle_ratio > 0.8;
            center_limit = center_ratio > 0.7;
            triangle_area_limit = 0.01 < triangle_area_ratio && triangle_area_ratio < 0.2;
            hole_area_limit = hole_area_ratio < 0.25;
            eye_dist_limit = eye_dist_ratio > 0.9;
            
            if triangle_area_limit && center_limit && min_angle_limit && hole_area_limit && eye_dist_limit
                q = q + 30 * (min_angle_ratio + center_ratio);
            end
        end
        
        if q > 0
            candidates_quality{c} = sqrt(q);
        else
            candidates_quality{c} = -sqrt(abs(q));
        end
    end
    
    % Pick the face region with the highest quality. This could easily be 
    % extended to detect multiple faces by keeping faces over a certain 
    % quality threshold.
    [quality, c_idx] = max([candidates_quality{candidates}]);
    winner = candidates(c_idx);
    winner_regions = [winner pairs{winner}];
    face_mask = ismember(L, winner_regions);
    
    boundary_mask = imfill(imclose(face_mask, strel('disk', 32)), 'holes');
    face_mask = boundary_mask & new_skin;
    
    debug_ = false;

    if debug_
        figure
        debugPlot(candidates, pairs, winner_regions, skin, face_mask, S);
    end
end

function debugPlot(candidates, pairs, winner_regions, skin, face_mask, S)

    runner_up_regions = setdiff(unique([candidates unique([ pairs{candidates} ])]), winner_regions);
    remaining_regions = setdiff(1:size(S,1), unique([candidates unique([ pairs{candidates} ])]));
    
    imshow(face_mask * 0.75 + skin * 0.25); hold on;
    
    for region = winner_regions
        rectangle('Position', S.BoundingBox(region, :), 'LineWidth', 3, 'EdgeColor', 'g')
    end
    
    for region = runner_up_regions
        rectangle('Position', S.BoundingBox(region, :), 'LineWidth', 3, 'EdgeColor', 'b')
    end
    
    for region = remaining_regions
        rectangle('Position', S.BoundingBox(region, :), 'LineWidth', 3, 'EdgeColor', 'r')
    end

    hold off;
end

