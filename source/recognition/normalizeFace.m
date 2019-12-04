function result = normalizeFace(face_triangle, image, type)

    [mu, ~] = faceStats();
    
    eye_dist_to_width_ratio = 1.625;
    eye_y_offset = 0.22;
    
    % Square aspect on average
    width = 256;
    height = width * mu;
    
    % Define a face triangle in the image that matches the 
    % average face proportions
    eye_dist = width / eye_dist_to_width_ratio;
    eyeline_to_mouth_dist = eye_dist * mu;
    
    l_eye_x = (width - eye_dist) / 2;
    r_eye_x = l_eye_x + eye_dist;
    mouth_x = 0.5 * width;
    
    eye_y = eye_y_offset * height;
    mouth_y = eye_y + eyeline_to_mouth_dist;
    
    % Points to fit face triangle points to
    B = ones(3);
    B(:,1:2) = [ l_eye_x, eye_y ;
                 r_eye_x, eye_y ;
                 mouth_x, mouth_y];
      
    % Face triangle points
    A = ones(3);
    A(1:2,1:2) = [ face_triangle.eyes.left ;
                   face_triangle.eyes.right ];
               
    if ~strcmp(type, 'eigen')
        % Results in just uniform scaling and rotation. This works better 
        % for fisherfaces, even though it means that mouths are not aligned.
        A(3,1:2) = avgMouth(face_triangle.eyes, mu);
    else
        A(3,1:2) = face_triangle.mouth;
    end
    
    % Find transformation that transforms A to B and apply to image
    result = imwarp(image, affine2d(A \ B), ...
             'OutputView', imref2d(round([height, width])), ...
             'SmoothEdges', true);
         
    result = rgb2gray(result);
    result = stretchGrayImage(result, 0.5);
end

function mouth = avgMouth(eyes, mu)
    L2R = eyes.right - eyes.left;
    E2M = [-L2R(2) L2R(1)] * mu;
    mouth = eyes.left + L2R/2 + E2M;
end

