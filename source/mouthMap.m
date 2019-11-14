function result = mouthMap(rgb_image, face_mask)
    [~, Cb, Cr] = componentYCbCr(rgb_image);
    Cr2 = rescale(Cr.^2);
    Cr_Cb = rescale(Cr ./ Cb); 
    eta = 0.95 * (mean(Cr2(face_mask)) / mean(Cr_Cb(face_mask)));
    result = Cr2 .* (Cr2 - eta * Cr_Cb).^2;
    
    kernel = strel('disk', 8);
    result = imdilate(result, kernel);
    result = result .* face_mask;
    result = rescale(result);
end

