function result = eyeMap(rgb_image, face_mask)

    [Y, Cb, Cr] = componentYCbCr(rgb_image);

    Cb_2 = rescale(Cb.^2);
    Cr_inv_2 = rescale((1.0 - Cr).^2);
    Cb_Cr = rescale(Cb ./ Cr);
    
    eye_map_chroma = (Cb_2 + Cr_inv_2 + Cb_Cr) / 3;
    eye_map_chroma = histeq(eye_map_chroma, 2^10);
    
    kernel = strel('disk', 4);
    %kernel = strel('sphere', 2);
    eye_map_luma = imdilate(Y, kernel) ./ (imerode(Y, kernel) + (1 / 255));
    
    result = eye_map_chroma .* eye_map_luma;

    result = imdilate(result, kernel);
    result = result .* face_mask;
    result = rescale(result);
end

