function id = recognizeFace(face)
    EF = eigenfaces(false);    
    face_vec = reshape(face, [], 1) - EF.mean_face_vec;
    face_weights = EF.eigen_vectors * face_vec;
    distances = pdist2(face_weights', EF.weights');
    [distance, id] = min(distances);
    
    % Threshold based on the largest distance of a valid recognition in DB2
    if(distance > 22.368)
       id = 0;
    end
end
