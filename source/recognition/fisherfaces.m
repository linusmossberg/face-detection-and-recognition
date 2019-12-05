
function fisherfaces = fisherfaces(rebuild)
    
    if nargin == 0
        rebuild = false;
    end

    persistent fisherfaces_;
    
    if ~rebuild && ~isempty(fisherfaces_)
        fisherfaces = fisherfaces_;
        return;
    end

    fisherfaces_path = '../data/recognition/fisherfaces.mat';

    if rebuild || ~isfile(fisherfaces_path)
        [faces, ids] = getTrainingFaces('fisher');
        width = size(faces,2);
        num_ids = max(ids); % c
        num_samples = size(faces, 3); % N
        
        face_vecs = reshape(faces, [], size(faces,3));

        [eigen_vectors_pca, mean_face_vec] = PCA(face_vecs, 1:(num_samples-num_ids));
        projected_faces = transpose(eigen_vectors_pca) * bsxfun(@minus, face_vecs, mean_face_vec);
        eigen_vectors_lda = LDA(projected_faces, ids, 1:(num_ids-1));
        
        eigen_vectors = eigen_vectors_pca * eigen_vectors_lda;
        eigen_vectors = transpose(eigen_vectors);
        weights = eigen_vectors * face_vecs;

        save(fisherfaces_path, 'eigen_vectors', 'weights', 'ids', 'width');
    end
    
    fisherfaces = load(fisherfaces_path);
    fisherfaces_ = fisherfaces;
end

function eigen_vectors = LDA(face_vecs, ids, keep)
    mean_face_vec = mean(face_vecs, 2);

    dimensions = length(mean_face_vec);

    scatter_between = zeros(dimensions);
    scatter_within = zeros(dimensions);

    num_ids = max(ids);
    for id = 1:num_ids
        id_face_vecs = face_vecs(:, ids == id);
        id_samples = size(id_face_vecs, 2);
        
        mean_id_face_vec = mean(id_face_vecs, 2);
        id_face_vecs = bsxfun(@minus, id_face_vecs, mean_id_face_vec);
        
        mean_diff = mean_id_face_vec - mean_face_vec;
        scatter_between = scatter_between + id_samples * mean_diff * transpose(mean_diff);
        scatter_within = scatter_within + id_face_vecs * transpose(id_face_vecs);
    end

    [eigen_vectors, eigen_values] = eig(scatter_between, scatter_within);

    [~,idx] = sort(diag(eigen_values), 1, 'descend');
    eigen_vectors = eigen_vectors(:,idx);

    eigen_vectors = eigen_vectors(:, keep);
end

