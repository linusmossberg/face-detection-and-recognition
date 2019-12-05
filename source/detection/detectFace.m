% The returned image is whitebalanced based on the method that produced the
% best face mask.

function [face_triangle, image] = detectFace(image)

    image = im2double(image);
    
    face_triangle = struct;
    
    pca_image = whiteBalance(image, false, 'PCA');
    gw_image  = whiteBalance(image, false, 'GW');
    gc_image  = whiteBalance(image, false, 'GC');

    face_masks = cell(1,8);
    
    [skin, skin_nolim]         = evaluateSkinDensityModel2D(image);
    [skin_pca, skin_nolim_pca] = evaluateSkinDensityModel2D(pca_image);
    [skin_gw, skin_nolim_gw]   = evaluateSkinDensityModel2D(gw_image);
    [skin_gc, skin_nolim_gc]   = evaluateSkinDensityModel2D(gc_image);
    
    [face_masks{1}, quality(1)] = faceMask(skin, image);
    [face_masks{2}, quality(2)] = faceMask(skin_pca, pca_image);
    [face_masks{3}, quality(3)] = faceMask(skin_gw, gw_image);
    [face_masks{4}, quality(4)] = faceMask(skin_gc, gc_image);

    [q, idx] = max(quality);
    if q < 7
        [face_masks{5}, quality(5)] = faceMask(skin_nolim, image);
        [face_masks{6}, quality(6)] = faceMask(skin_nolim_pca, pca_image);
        [face_masks{7}, quality(7)] = faceMask(skin_nolim_gw, gw_image);
        [face_masks{8}, quality(8)] = faceMask(skin_nolim_gc, gc_image);
            
        q_before = q;
        idx_before = idx;
        [q, idx] = max(quality);
        
        if (q - q_before < 0.3)
            q = q_before;
            idx = idx_before;
        end
    end
    
    face_mask = face_masks{idx};
    if(q > 6.639)
        switch idx
            case {2, 6}
                image = pca_image;
            case {3, 7}
                image = gw_image;
            case {4, 8}
                image = gc_image;
        end
        
        filled_face_mask = imfill(imclose(face_mask, strel('disk', 32)), 'holes');
        filled_face_mask = imerode(filled_face_mask, strel('disk', 7));
        filled_face_mask = bwareafilt(filled_face_mask, 1);
        if ~all(idx ~= 1:4)
            filled_upper_face = ellipseUpperFaceRegion(filled_face_mask);
            eye_mask = filled_upper_face & ~face_mask;
        else
            eye_mask = filled_face_mask & ~face_mask;
        end
    else
        eye_mask = ~face_mask;
    end
    
    eyes = detectEyes(image, eye_mask);
    if(~isempty(fieldnames(eyes)))
        
        mouth = detectMouth(eyes, image);
        if ~isempty(mouth)
            face_triangle.mouth = mouth;
            face_triangle.eyes = eyes;
        else
            % Completely different method as last resort
            eye_map = eyeMap(image);
            skin = eye_map < graythresh(eye_map);
            skin = bwareafilt(skin, 1, 4);
            skin = imdilate(skin, strel('disk', 3));
            face_mask = imfill(skin,'holes');

            eye_mask = face_mask & ~skin;
            eyes = detectEyes(image, eye_mask);
            
            if(~isempty(fieldnames(eyes)))
                mouth = detectMouth(eyes, image);
                if ~isempty(mouth)
                    face_triangle.eyes = eyes;
                    face_triangle.mouth = mouth;
                end
            end
        end
    else
        % Face mask likely only covers part of face and eyes are not closed
        % holes, use the convex hull of the face mask as the new face mask.
        convex_face_mask = bwconvhull(face_mask);
        convex_face_mask = imerode(convex_face_mask, strel('disk', 24));
        eye_mask = convex_face_mask & ~face_mask;
        eyes = detectEyes(image, eye_mask);
        if(~isempty(fieldnames(eyes)))
            mouth = detectMouth(eyes, image);
            if ~isempty(mouth)
                face_triangle.eyes = eyes;
                face_triangle.mouth = mouth;
            end
        end
    end
end

