function [face_triangle, image] = detectFaceTriangle2(image)
    
    face_triangle = struct;

    pca_image = whiteBalance(image, false, 'PCA');
    gw_image = whiteBalance(image, false, 'GW');
    gc_image = whiteBalance(image, false, 'GC');

    face_masks = cell(1,8);

    [skin, skin_nolim] = evaluateSkinDensityModel2D(image);
    [skin_pca, skin_nolim_pca] = evaluateSkinDensityModel2D(pca_image);
    [skin_gw, skin_nolim_gw] = evaluateSkinDensityModel2D(gw_image);
    [skin_gc, skin_nolim_gc] = evaluateSkinDensityModel2D(gc_image);

    [face_masks{1}, quality(1)] = faceMask2(skin, image);
    [face_masks{2}, quality(2)] = faceMask2(skin_pca, pca_image);
    [face_masks{3}, quality(3)] = faceMask2(skin_gw, gw_image);
    [face_masks{4}, quality(4)] = faceMask2(skin_gc, gc_image);

    [q, idx] = max(quality);
    if q < 7
        disp({'q' q 'idx' idx})
        [face_masks{5}, quality(5)] = faceMask2(skin_nolim, image);
        [face_masks{6}, quality(6)] = faceMask2(skin_nolim_pca, pca_image);
        [face_masks{7}, quality(7)] = faceMask2(skin_nolim_gw, gw_image);
        [face_masks{8}, quality(8)] = faceMask2(skin_nolim_gc, gc_image);
            
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
            case 2, case 6
                image = pca_image;
            case 3, case 7
                image = gw_image;
            case 4, case 8
                image = gc_image;
        end
        
        filled_face_mask = imfill(imclose(face_mask, strel('disk', 32)), 'holes');
        filled_face_mask = imerode(filled_face_mask, strel('disk',16));
        filled_face_mask = bwareafilt(filled_face_mask, 1);
        filled_upper_face = ellipseUpperFaceRegion(filled_face_mask);
        eye_mask = filled_upper_face & ~face_mask;
        
    else
        eye_mask = ~face_mask;
    end
    
    eye_mask = bwareaopen(eye_mask, 100, 4);
    eye_mask = bwareaopen(~eye_mask, 100, 4);
    eye_mask = ~eye_mask;
    eye_mask = imclose(eye_mask, strel('disk', 4));
    eye_mask = imerode(eye_mask, strel('disk', 4));
    
    eyes = detectEyes(image, eye_mask);
    if(~isempty(fieldnames(eyes)))
        face_triangle.mouth = detectMouth(eyes, image);
        face_triangle.eyes = eyes;
    end
end

