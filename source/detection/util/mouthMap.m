function result = mouthMap(image, face_mask)
    [~, Cb, Cr] = componentYCbCr(image);
    Cr2 = rescale(Cr.^2);
    Cr_Cb = rescale(Cr ./ Cb); 
    eta = 0.95 * (mean(Cr2(face_mask)) / mean(Cr_Cb(face_mask)));
    result = Cr2 .* (Cr2 - eta * Cr_Cb).^2;
    
    result = imdilate(result, strel('disk', 8));
end

