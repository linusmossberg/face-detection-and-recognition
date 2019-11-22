
% Image should not be whitebalanced
function detectFaceTriangle(image)
    orig_image = image;
    image = whiteBalance(image);

    skin = evaluateSkinDensityModel2D(image, true);
    [face_mask, found] = faceMask(skin);
    
    disp(['found: ' num2str(found)])
    
    if ~found
        face_mask_percentage = 100 * sum(face_mask(:)) / numel(face_mask);
    end
    min_face_mask_percentage = 10;
    
    % Invalid but large face mask tends to mean that the whitebalance and
    % brightness limitation is correct but that there are skin colored
    % background regions that have blended with the face. In these cases
    % it's best to just continue and use the face mask, but without the 
    % upper face ellipse masking later.
    if ~found && face_mask_percentage < min_face_mask_percentage
        initial.image = image;
        initial.skin = skin;
        initial.face_mask = face_mask;

        image = whiteBalance(orig_image, true, 'GW');
        skin = evaluateSkinDensityModel2D(image, true);
        [face_mask, found] = faceMask(skin);
        
        disp(['found: ' num2str(found)])

        if ~found
            image = whiteBalance(orig_image, true, 'GW');
            skin = evaluateSkinDensityModel2D(image, false);
            [face_mask, found] = faceMask(skin);
            
            disp(['found: ' num2str(found)])
            
            if ~found
                image = initial.image;
                skin = initial.skin;
                face_mask = initial.face_mask;
            end
        end
        face_mask = imdilate(face_mask, strel('disk',16));
    end
    
    skin = bwareaopen(skin, 400, 4);
    skin = imdilate(skin, strel('disk', 3));
    
    if found
        upper_face = ellipseUpperFaceRegion(face_mask);
        eye_mask = upper_face & ~skin;
    else
        if(face_mask_percentage > min_face_mask_percentage)
            face_mask = imfill(face_mask,'holes');
            eye_mask = face_mask & ~skin;
        else
            eye_mask = ~skin;
        end
    end
    
    eyes = detectEyes(image, eye_mask);
    
    figure(1)
    if(size(eyes,1) == 2)
        x = eyes(:,1);
        y = eyes(:,2);

        x_width = max(x) - min(x);

        width = round(x_width * 2);
        xmin = min(x) - x_width * 0.5;
        ymin = min(y) - x_width * 0.5;
        height = width;

        crop_image = imcrop(image, [xmin ymin width height]);

        x = x - xmin;
        y = y - ymin;

        imshow(crop_image)
        hold on; plot(x, y, 'b.', 'MarkerSize', 16);
        plot(x, y, 'wx', 'MarkerSize', 5, 'LineWidth', 0.5);
        hold off;
    else
        image = whiteBalance(orig_image);
        skin = evaluateSkinDensityModel2D(image, false);
        [face_mask, found] = faceMask(skin);
        
        skin = bwareaopen(skin, 400, 4);
        skin = imdilate(skin, strel('disk', 3));
        
        if found
            upper_face = ellipseUpperFaceRegion(face_mask);
            eye_mask = upper_face & ~skin;
        else
            eye_mask = face_mask & ~skin;
        end

        eyes = detectEyes(image, eye_mask);
        
        if(size(eyes,1) == 2)
            x = eyes(:,1);
            y = eyes(:,2);

            x_width = max(x) - min(x);

            width = round(x_width * 2);
            xmin = min(x) - x_width * 0.5;
            ymin = min(y) - x_width * 0.5;
            height = width;

            crop_image = imcrop(image, [xmin ymin width height]);

            x = x - xmin;
            y = y - ymin;

            imshow(crop_image)
            hold on; plot(x, y, 'b.', 'MarkerSize', 16);
            plot(x, y, 'wx', 'MarkerSize', 5, 'LineWidth', 0.5);
            hold off;
        else
            imshow(image);
        end
    end
end

