function [id, distance] = detectAndRecognize(image, type)
    initiate();
    id = 0;
    distance = -1;
    [face_triangle, image_wb] = detectFace(image);
    if(~isempty(fieldnames(face_triangle)))
        face = normalizeFace(image_wb, face_triangle, type);
        [id, distance] = recognizeFace(face, type);
    end
end

