function [id, distance] = recognizeFace(face, type)
    face_vec = reshape(face, [], 1);
    
    if ~strcmp(type, 'eigen')
        threshold = 24;
        M = fisherfaces();
    else
        threshold = 16.9;
        M = eigenfaces();
        face_vec = face_vec - M.mean_face_vec;
    end
    
    face_weights = M.eigen_vectors * face_vec;
    
    distances = pdist2(face_weights', M.weights');
    [distance, i] = min(distances);
    
    if(distance < threshold)
        id = M.ids(i);
    else
        id = 0;
    end
end
