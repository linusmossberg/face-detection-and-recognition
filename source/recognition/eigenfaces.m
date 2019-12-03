
function eigenfaces = eigenfaces(rebuild)
    
    persistent eigenfaces_;
    
    if ~rebuild && ~isempty(eigenfaces_)
        eigenfaces = eigenfaces_;
        return;
    end

    eigenfaces_path = '../data/recognition/eigenfaces.mat';

    if rebuild || ~isfile(eigenfaces_path)
        [faces, ids] = getTrainingFaces('eigen');
        width = size(faces,2);
        
        face_vecs = reshape(faces, [], size(faces,3));
        
        % Remove the 3 most significant eigenvectors/-faces as these
        % typically mostly encode information about illumination
        [eigen_vectors, mean_face_vec] = PCA(face_vecs, 4:(size(faces,3)-1));
        
        eigen_vectors = transpose(eigen_vectors);
        
        weights = eigen_vectors * bsxfun(@minus, face_vecs, mean_face_vec);
        
        save(eigenfaces_path, 'eigen_vectors', 'weights', 'mean_face_vec', 'ids', 'width');
    end
    eigenfaces = load(eigenfaces_path);
    eigenfaces_ = eigenfaces;
end