function result = transformFace(image, face_triangle)

    [mu, ~] = faceStats();
    
    eye_dist_to_width_ratio = 2;
    
    % Square aspect on average
    width = 512;
    height = width * mu;
    
    % Define a face triangle in the image that matches the 
    % average face proportions
    eye_dist = width / eye_dist_to_width_ratio;
    eyeline_to_mouth_dist = eye_dist * mu;
    
    l_eye_x = (width - eye_dist) / 2;
    r_eye_x = l_eye_x + eye_dist;
    mouth_x = 0.5 * width;
    
    eye_y = 0.25 * height;
    mouth_y = eye_y + eyeline_to_mouth_dist;
    
    % Points to fit face triangle points to
    B = ones(3);
    B(:,1:2) = [ l_eye_x, eye_y ;
                 r_eye_x, eye_y ;
                 mouth_x, mouth_y];
      
    % Face triangle points
    A = ones(3);
    A(:,1:2) = [ face_triangle.eyes.left ;
                 face_triangle.eyes.right ;
                 face_triangle.mouth ];
    
    % Find transformation that transforms A to B and apply to image
    result = imwarp(image, affine2d(A \ B), ...
             'OutputView', imref2d(round([height, width])), ...
             'SmoothEdges', true);
end

