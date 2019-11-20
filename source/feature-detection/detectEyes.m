% Iterative otsu thresholding of eye map to find the eyes. 

function [eyes] = detectEyes(eye_map, eye_mask)
    
    flatten_process = false;
    
    for i = 1:10
        eye_map(~eye_mask) = 0;
        eye_map = rescale(eye_map);
        new_eye_mask = eye_map > graythresh(eye_map(eye_mask));
        new_eye_mask = bwareaopen(new_eye_mask, 4^2, 8);
        
        %if i == 1, imshow(new_eye_mask); end
        
        eye_CC = bwconncomp(new_eye_mask);
        eye_labels = labelmatrix(eye_CC);
        eye_S = regionprops('table',eye_CC, eye_map,'MeanIntensity', 'MaxIntensity', 'Area', 'WeightedCentroid', 'Circularity', 'Eccentricity');
        
        % Find possible eye pairs
        eye_pairs = findEyePairs(eye_S.WeightedCentroid);
        
        if(size(eye_S,1) >= 2 && ~isempty(eye_pairs))
            if(size(eye_S,1) > 2)
                
                % Factor that tries to weight different regions according
                % to how likely it is that a regions is an eye.
                eye_mass = ...
                    eye_S.MeanIntensity ...
                    .* eye_S.Area ...
                    .* (1-eye_S.Eccentricity) ...
                    .* (1 - abs(eye_S.Circularity - 1)) ...
                    .* eye_S.MaxIntensity;
                
                % Sum the mass of each eye pair
                pair_masses = zeros(1, size(eye_pairs, 1));
                for ep = 1:size(eye_pairs,1)
                    pair_masses(ep) = sum(eye_mass(eye_pairs(ep, :)));
                end
                
                % Pick the pair with the highest mass
                [~, eye_pair_idx] = max(pair_masses);
                eye_pair = eye_pairs(eye_pair_idx, :);
                eye_mask = ismember(eye_labels, eye_pair);
            else
                eye_mask = new_eye_mask;
            end
            
            flatten_process = false;
        
        % Only one eye availible after first otsu threshold. Start 
        % flattening the eye map to hopefully recover another eye that 
        % might be dimmer.
        elseif ((flatten_process || i == 1)) %&& size(eye_S,1) == 1)
            eye_map = eye_map .^ (1/2);
            flatten_process = true;
            if i == 1, disp('One eye'); end
        else
            break;
        end
    end
    
    disp(['Iterations: ' num2str(i)])
    
    eye_map(~eye_mask) = 0;
    eye_map = rescale(eye_map);
    eye_CC = bwconncomp(eye_mask);
    eye_S = regionprops('table',eye_CC, eye_map,'WeightedCentroid');
    
    eyes = eye_S.WeightedCentroid;
    end

% The orientation of the face mask ellipse could be used here to determine
% the orientation of the eye pairs relative to the face.
function eye_pairs = findEyePairs(eye_positions)
    max_angle = 45;
    min_distance = 20;
    
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

