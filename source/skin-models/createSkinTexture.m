function createSkinTexture()
    rep_faces = imread('../data/skin-model/representative_faces.png');
    rep_faces_mask = imread('../data/skin-model/representative_faces_samples_fill.png');
    rep_faces_mask = rep_faces_mask == 255;
    
    skin_vector = reshape(rep_faces(rep_faces_mask), [], 3);
    
    skin_vector = skin_vector(randperm(length(skin_vector)), :);
    
    num_pixels = length(skin_vector);
    ideal_dim = ceil(sqrt(num_pixels));
    
    height = -1;
    for h = 1:ideal_dim
        if (mod(num_pixels, h) == 0)
            height = h;
        end
    end
    
    if height > 0
        image = reshape(skin_vector, height, num_pixels / height, 3);
        imwrite(image, '../data/skin-model/skin_texture.png');
    end
end

