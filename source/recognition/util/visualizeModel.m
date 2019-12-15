% Visualizes the num_principal first eigen vectors / faces of a model

function visualizeModel(model, num_principal)
    num_principal = min(size(model.eigen_vectors, 1), num_principal);
    
    ideal_w = round(sqrt(num_principal));
    w = 1;
    for i = 1:ideal_w
        if mod(num_principal, i) == 0
            w = i;
        end
    end
    
    h = num_principal / w;
    
    for i = 1:num_principal
        subplot(w, h, i)
        image = reshape(model.eigen_vectors(i,:), [], model.width);
        image = ind2rgb(im2uint8(rescale(image)), gray);
        imshow(image, 'Interpolation', 'bilinear');
        
        %t_image{i} = image;
    end
    %imwrite(imtile(t_image, 'Frames', 1:8, 'GridSize', [2 4], 'BorderSize', 4, 'BackgroundColor', 'w'), 'eigenfaces.png');
end

