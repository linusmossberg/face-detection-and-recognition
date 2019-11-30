function [eigen_vectors, mean_face_vec] = PCA(face_vecs, keep)
    mean_face_vec = mean(face_vecs, 2);
    [eigen_vectors,~,~] = svd(bsxfun(@minus, face_vecs, mean_face_vec), 'econ');
    eigen_vectors = eigen_vectors(:, keep);
end

