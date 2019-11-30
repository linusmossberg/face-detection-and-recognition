function [id, distance] = recognizeFace(face, type)

    persistent min_dist;
    persistent max_dist;
    
    if(isempty(min_dist))
        min_dist = 1e6;
    end
    if(isempty(max_dist))
        max_dist = 0;
    end
    
    id = 0;
    fisher = ~strcmp(type, 'eigen');
    face_vec = reshape(face, [], 1);
    
    if fisher
        M = fisherfaces(false);
    else
        M = eigenfaces(false);
        face_vec = face_vec - M.mean_face_vec;
    end
    
    face_weights = M.eigen_vectors * face_vec;
    distances = pdist2(face_weights', M.weights');
    [distance, i] = min(distances);
    
    min_dist = min(min_dist, distance);
    disp({'min_dist' min_dist});
    max_dist = max(max_dist, distance);
    disp({'max_dist' max_dist});
    disp({'dist' distance})
    disp('')
    
    % Based on the largest correctly matched distance in DB2. Results in a
    % lot of false positives.
    eigen_threshold = 22.368;
    
    % Based on the smallest distance for a few faces that are not in DB. 
    % Could probably be a lot smaller, faces in DB tends to have a very 
    % small distance of like 1e-14.
    fisher_threshold = 41.3158;
    
    if fisher
        if(distance < fisher_threshold)
            id = M.ids(i);
        end
    else
        if(distance < eigen_threshold)
            id = M.ids(i);
        end
    end
end
