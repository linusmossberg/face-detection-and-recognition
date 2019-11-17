function plotColorSpace(cs_image, rgb_image)
    coord = reshape(cs_image, [], 3);
    color = reshape(rgb_image, [], 3);

    x = coord(:,1);
    y = coord(:,2);
    z = coord(:,3);
    
    scatter3(x(:), y(:), z(:), ones(size(x(:))), color);
    xlabel('Y'), ylabel('Cb'), zlabel('Cr');
    axis square
    set(gca, 'Projection','perspective')
end

