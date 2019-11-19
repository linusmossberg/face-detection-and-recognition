% Simple iterative otsu thresholding of eye map to find the eyes. The only
% metric used atm to select potential eyes over others is 'eye mass', which 
% is the area of the mask region of the potential eye multiplied with the
% average eye map intensity of that region.

function [eyes] = detectEyes(eye_map, eye_mask)
    flatten_process = false;
    
    for i = 1:10
        eye_map(~eye_mask) = 0;
        eye_map = rescale(eye_map);
        new_eye_mask = eye_map > graythresh(eye_map(eye_mask));
        
        eye_CC = bwconncomp(new_eye_mask);
        eye_labels = labelmatrix(eye_CC);
        eye_S = regionprops('table',eye_CC, eye_map,'MeanIntensity', 'Area');
        
        if(size(eye_S,1) >= 2)
            eye_mass = eye_S.Area .* eye_S.MeanIntensity;
            eye_mass_sorted = sort(eye_mass);
            mass_thresh = eye_mass_sorted(length(eye_mass_sorted) - 1);
            eye_mask = ismember(eye_labels, find(eye_mass >= mass_thresh, 2, 'first'));
            flatten_process = false;
        
        % Only one eye availible after first otsu threshold. Start 
        % flattening the eye map to hopefully recover another eye that 
        % might be dimmer.
        elseif ((flatten_process || i == 1) && size(eye_S,1) == 1)
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

