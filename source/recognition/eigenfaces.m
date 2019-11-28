
function eigenfaces = eigenfaces(rebuild)
    
    persistent eigenfaces_;
    
    if ~rebuild && ~isempty(eigenfaces_)
        eigenfaces = eigenfaces_;
        return;
    end

    eigenfaces_path = '../data/recognition/eigenfaces.mat';

    if rebuild || ~isfile(eigenfaces_path)
        folder_path = '../data/DB1/';
        image_files = dir([folder_path, '*.jpg']);
        for image_file = image_files'
            id = str2num(extractBefore(extractAfter(image_file.name, '_'), '.'));
            image = imread([folder_path, image_file.name]);
            faces(:,:,id) = detectFace(image);
        end
        
        face_vecs = reshape(faces, [], size(faces,3));
        mean_face_vec = mean(face_vecs, 2);
        face_vecs = bsxfun(@minus, face_vecs, mean_face_vec);
        
        [eigen_vectors, ~, ~] = svd(face_vecs, 'econ');
        eigen_vectors = transpose(eigen_vectors);
        
        % Remove the 3 most significant eigenvectors/-faces as these
        % typically mostly encode information about illumination
        eigen_vectors(1:3,:) = [];
        
        weights = eigen_vectors * face_vecs;
        
        save(eigenfaces_path, 'eigen_vectors', 'weights', 'mean_face_vec');
    end
    eigenfaces = load(eigenfaces_path);
    eigenfaces_ = eigenfaces;
end