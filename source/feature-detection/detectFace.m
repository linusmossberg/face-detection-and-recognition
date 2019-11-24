function result = detectFace(image)
    [face_triangle, image] = detectFaceTriangle(image);
    
    if ~isempty(fieldnames(face_triangle))
        result = transformFace(image, face_triangle);
    else
        result = [];
    end
end

