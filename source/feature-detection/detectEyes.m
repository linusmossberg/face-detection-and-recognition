% Iterative otsu thresholding of eye map to find the eyes.

function eyes = detectEyes(eye_map, eye_mask)
    imwrite(eye_mask, '0.png')
    
    [eye_mask, initial_regions_found] = findInitialEyeRegions(eye_map, eye_map > 0.084);
    if initial_regions_found
        eye_mask = imclose(eye_mask, true(6));
    end
    
    imwrite(eye_mask, '1.png')
    
    flatten_process = false;
    
    % 10 is arbitrary, the loop usually breaks sooner.
    for i = 1:10
        
        eye_map(~eye_mask) = 0;
        eye_map = rescale(eye_map);
        
        new_eye_mask = eye_map > graythresh(eye_map(eye_mask));
        
        new_eye_mask = bwareaopen(new_eye_mask, 4^2, 4);
        
        imwrite(new_eye_mask, [num2str(i + 1)  '.png'])
        
        eye_CC = bwconncomp(new_eye_mask);
        eye_labels = labelmatrix(eye_CC);
        eye_S = regionprops('table',eye_CC, eye_map,'MeanIntensity', 'MaxIntensity', 'Area', 'WeightedCentroid', 'Circularity', 'Eccentricity');
        
        % Find possible eye pairs
        eye_pairs = findEyePairs(eye_S.WeightedCentroid);
        
        if(size(eye_S,1) >= 2 && ~isempty(eye_pairs))
            
            if(size(eye_S,1) > 2)
                
                % Eye property space vector defined such that
                % increasing values in each dimension means that the region
                % is more eye-like in that dimension. Typically each
                % dimension is defined in the range [0,1] but some more
                % important properties are weighted higher.
                eye_space_vecs = zeros(5, size(eye_S,1));
                eye_space_vecs(1,:) = normalizeProperty(eye_S.MeanIntensity);
                eye_space_vecs(2,:) = normalizeProperty(eye_S.Area);
                eye_space_vecs(3,:) = 1.2 * normalizeProperty(eye_S.MaxIntensity);
                eye_space_vecs(4,:) = normalizeProperty(1 - eye_S.Eccentricity);
                eye_space_vecs(5,:) = normalizeProperty(1 - abs(eye_S.Circularity - 1));
                
                % Length of the eye space vector defines the eye-ness-ness 
                % of an eye.
                eye_masses = sqrt(sum(eye_space_vecs.^2));
                
                pair_masses = zeros(1, size(eye_pairs, 1));
                eye_dim_dists = zeros(1, size(eye_pairs, 1));
                
                % Sum the mass of each eye pair and compute the 
                % unsimilarity between eyes in a pair by calculating the
                % distance between the eyes in eye property space.
                for ep = 1:size(eye_pairs,1)
                    pair_masses(ep) = sum(eye_masses(eye_pairs(ep, :)));
                    eye_dim_dists(ep) = pdist(eye_space_vecs(:, eye_pairs(ep, :))');
                end
                
                % Compute final pair masses by combining the sum of each
                % eye pair and the similarity of those pairs.
                pair_similarities = 1 - rescale(eye_dim_dists);
                pair_masses = normalizeProperty(pair_masses);
                pair_masses = pair_masses + 0.16 * pair_similarities;
                
                % *defining separate eye property and eye similarity spaces
                % might be worth it. Then properties like orientation could
                % be used to weight similarity.
                
                % Pick the pair with the highest mass
                [~, eye_pair_idx] = max(pair_masses);
                eye_pair = eye_pairs(eye_pair_idx, :);
                eye_mask = ismember(eye_labels, eye_pair);
            
            else % Two eyes found
                
                % Only one eye map intensity left and both eyes has it, no
                % more thresholding can be done.
                if(eye_mask == new_eye_mask), break; end
                
                % Continue thresholding to refine
                eye_mask = new_eye_mask;
                
                % Stop refining if eyes are small enough. Otherwise the
                % result tends to get skewed too much towards the 
                % brightest part, which might not be the center.
                disp(min(eye_S.Area))
                if(min(eye_S.Area) < 100)
                    break;
                end
            end
            
            flatten_process = false;
        
        % Only one eye availible after first threshold. Start 
        % flattening the eye map to hopefully recover another eye that 
        % might be dimmer.
        elseif ((flatten_process || i == 1))
            
            % If the eye mask contains a valid pair of eye regions after 
            % the initial detection on the unthresholded mask, then
            % finding the center of these regions tends to be better than
            % trying to find and refine a smaller eye region within them. 
            if(initial_regions_found), break; end
            
            eye_map = eye_map .^ (1/4);
            if ~flatten_process, disp('One eye'); end
            flatten_process = true;
        else
            break;
        end
    end
    
    disp(['Iterations: ' num2str(i)])
    
    eye_map(~eye_mask) = 0;
    eye_map = rescale(eye_map);
    eye_CC = bwconncomp(eye_mask);
    eye_S = regionprops('table',eye_CC, eye_map,'WeightedCentroid', 'Centroid');
    
    eyes = eye_S.WeightedCentroid;
end

% Currently more or less the same as one iterative step in detectEyes() 
% except that no thresholding is done, the eye map is just used to compute
% region properties. The eye regions in the mask is shaped more like the 
% entire 'eye-silhouette' and is more elongated and elliptical, so there
% might be reasons to redefine the eye property dimension here.
function [eye_mask, initial_regions_found] = findInitialEyeRegions(eye_map, eye_mask)
    eye_mask = bwareaopen(eye_mask, 4^2, 4);
    
    eye_CC = bwconncomp(eye_mask);
    eye_labels = labelmatrix(eye_CC);
    eye_S = regionprops('table',eye_CC, eye_map,'MeanIntensity', 'MaxIntensity', 'Area', 'WeightedCentroid', 'Circularity', 'Eccentricity');
    
    eye_pairs = findEyePairs(eye_S.WeightedCentroid);
    
    initial_regions_found = size(eye_S,1) >= 2 && ~isempty(eye_pairs);
    
    if(initial_regions_found)
        eye_space_vecs = zeros(5, size(eye_S,1));
        eye_space_vecs(1,:) = normalizeProperty(eye_S.MeanIntensity);
        eye_space_vecs(2,:) = normalizeProperty(eye_S.Area);
        eye_space_vecs(3,:) = 1.2 * normalizeProperty(eye_S.MaxIntensity);
        eye_space_vecs(4,:) = normalizeProperty(1 - eye_S.Eccentricity);
        eye_space_vecs(5,:) = normalizeProperty(1 - abs(eye_S.Circularity - 1));
        
        eye_space_vecs(2,:) = 0;
            
        eye_masses = sqrt(sum(eye_space_vecs.^2));

        pair_masses = zeros(1, size(eye_pairs, 1));
        eye_dim_dists = zeros(1, size(eye_pairs, 1));
        for ep = 1:size(eye_pairs,1)
            pair_masses(ep) = sum(eye_masses(eye_pairs(ep, :)));
            eye_dim_dists(ep) = pdist(eye_space_vecs(:, eye_pairs(ep, :))');
        end

        pair_similarities = 1 - rescale(eye_dim_dists);
        pair_masses = normalizeProperty(pair_masses);

        pair_masses = pair_masses + 0.16 * pair_similarities;

        [~, eye_pair_idx] = max(pair_masses);
        eye_pair = eye_pairs(eye_pair_idx, :);
        eye_mask = ismember(eye_labels, eye_pair);
    end
end

% The orientation of the face mask ellipse could be used here to determine
% the orientation of the eye pairs relative to the face.
function eye_pairs = findEyePairs(eye_positions)
    max_angle = 30;
    min_distance = 30;
    
    num_pairs = 0;
    eye_pairs = [];
    
    for i = 1:size(eye_positions, 1)
        for j = (i + 1):size(eye_positions, 1)
            
            p1 = eye_positions(i, :);
            p2 = eye_positions(j, :);
            
            orientation = abs(rad2deg(atan2(p2(2)-p1(2), (p2(1) - p1(1)))));
            distance = pdist([p1;p2]);
            
            valid_orient = orientation < max_angle || orientation > (180-max_angle);
            valid_dist = distance > min_distance;
            
            if(valid_orient && valid_dist)
                num_pairs = num_pairs + 1;
                eye_pairs(num_pairs, :) = [i, j];
            end
        end
    end
end

% Linearly normalizes a property vector to [>= 0 & <= 1.0 , 1.0]
function normalized_property = normalizeProperty(property)
    normalized_property = property / max(property);
    if min(normalized_property) < 0
        normalized_property = rescale(normalized_property);
    end
end

