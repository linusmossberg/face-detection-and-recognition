% Variance threshold is the fraction of the total variance that the model
% should represent. Can be used to reduce number of principal components.
function [eigen_vectors, mean_face_vec] = PCA(face_vecs, keep, variance_threshold)
    mean_face_vec = mean(face_vecs, 2);
    [eigen_vectors, S, ~] = svd(bsxfun(@minus, face_vecs, mean_face_vec), 'econ');
    
    if nargin == 3
        eigen_values = diag(S).^2;
        total_variance = sum(eigen_values);
        cumulative_variance = cumsum(eigen_values);
        idx = find(cumulative_variance >= (total_variance * variance_threshold), 1, 'first');
        keep = keep(keep <= idx);
    end
    
    eigen_vectors = eigen_vectors(:, keep);
end

