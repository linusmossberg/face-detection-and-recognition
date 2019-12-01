function [id, distance] = recognizeFace(face, type)
    
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
    
    % Based on the largest correctly matched distance in DB2. Results in a
    % lot of false positives.
    eigen_threshold = 22.368;
    
    % Can be calculated with computeThreshold(). It's set to optimally
    % minimize the sum of false positives and negatives.
    fisher_threshold = 31.8280;
    
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
