function result = detectFace(image)
    image = im2double(image);
    [face_triangle, image] = detectFaceTriangle(image);
    
    if ~isempty(fieldnames(face_triangle))
        result = transformFace(image, face_triangle);
        result = rgb2gray(result);
        result = stretchGrayImage(result, 0.5);
    else
        result = [];
    end
end

