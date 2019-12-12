% Can be called as id = tnm034(image) like the skeleton function header
function [id, distance] = tnm034(image, type)
    initiate();
    if nargin < 2, type = 'fisher'; end
    if(numel(image) == 1)
        image = imread(['../data/faces/image_' num2str(image, '%04d') '.jpg']);
    end
    [face_triangle, image_wb] = detectFace(image);
    if(~isempty(fieldnames(face_triangle)))
        face = normalizeFace(face_triangle, image_wb, type);
        [id, distance] = recognizeFace(face, type);
    else
        id = 0;
        distance = realmax('double');
    end
end