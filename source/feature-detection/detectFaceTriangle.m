
% Image should not be whitebalanced. The return image is the correctly
% whitebalanced image.
function [face_triangle, image] = detectFaceTriangle(image)
    orig_image = image;
    
    face_triangle = struct;
    
    % PCA whitebalance and brightness limitation in skin model
    image = whiteBalance(image, true, 'PCA');
    skin = evaluateSkinDensityModel2D(image, true);
    
    [face_mask, found] = faceMask(skin);
    
    disp(['found: ' num2str(found)])
    
    % Invalid but large face mask tends to mean that the whitebalance and
    % brightness limitation is correct but that there are skin colored
    % background regions that have blended with the face. In these cases
    % it's best to just continue and use the face mask, but without the 
    % upper face ellipse masking later.
    if ~found
        face_mask_percentage = 100 * sum(face_mask(:)) / numel(face_mask);
    end
    min_face_mask_percentage = 10;
    
    if ~found && face_mask_percentage < min_face_mask_percentage
        initial.image = image;
        initial.skin = skin;
        
        % Gray World and brightness limitation in skin model
        image = whiteBalance(orig_image, true, 'GW');
        skin = evaluateSkinDensityModel2D(image, true);
        [face_mask, found] = faceMask(skin);
        
        disp(['found: ' num2str(found)])

        if ~found
            
            % Gray World but no brightness limitation in skin model
            skin = evaluateSkinDensityModel2D(image, false);
            [face_mask, found] = faceMask(skin);
            
            disp(['found: ' num2str(found)])
            
            if ~found
                % If all fails, stick with original method and ignore face
                % mask.
                image = initial.image;
                skin = initial.skin;
            end
        end
        
        % Face masks tends to be worse if it took this much to find one, so
        % some additional dilation is done.
        face_mask = imdilate(face_mask, strel('disk',16));
    end
    
    % This is done to clean up non-skin regions before using it as an
    % initial eye mask together with the face mask.
    skin = bwareaopen(skin, 400, 4);
    skin = imdilate(skin, strel('disk', 3));
    
    if found
        
        % If a good face mask is found, then we can limit the eye mask
        % further by only including the upper part of the ellipse that
        % encloses the face mask.
        upper_face = ellipseUpperFaceRegion(face_mask);
        eye_mask = upper_face & ~skin;
        
    else
        
        if(face_mask_percentage > min_face_mask_percentage)
            % Face mask returned early and therefore needs additional
            % processing
            face_mask = imclose(face_mask, strel('disk', 32));
            face_mask = imfill(face_mask,'holes');
            
            eye_mask = face_mask & ~skin;
        else
            eye_mask = ~skin;
        end
    end
    
    eyes = detectEyes(image, eye_mask);
    
    % No valid eyes found in the resulting eye mask, try again with another
    % approach as last resort.
    if(isempty(fieldnames(eyes)))
        eye_map = eyeMap(image);
        skin = eye_map < graythresh(eye_map);
        skin = bwareafilt(skin, 1, 4);
        skin = imdilate(skin, strel('disk', 3));
        face_mask = imfill(skin,'holes');
        
        eye_mask = face_mask & ~skin;
        eyes = detectEyes(image, eye_mask);
    end
    
    % Success
    if(~isempty(fieldnames(eyes)))
        face_triangle.eyes = eyes;
        
        % A mouth will always be detected. If it completely fails, then an
        % approximation of the mouth position relative to the eyes is used.
        face_triangle.mouth = detectMouth(eyes, image);
    end
end

