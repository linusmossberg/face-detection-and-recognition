function [id, distance] = tnm034(image, type)
    initiate();
    if nargin < 2, type = 'fisher'; end
    [face_triangle, image_wb] = detectFace(image);
    if(~isempty(fieldnames(face_triangle)))
        face = normalizeFace(face_triangle, image_wb, type);
        [id, distance] = recognizeFace(face, type);
    else
        id = 0;
        distance = realmax('double');
    end
end