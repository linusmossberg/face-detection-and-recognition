function plotColorSpace(cs_image, rgb_image)
    x = cs_image(:,:,1);
    y = cs_image(:,:,2);
    z = cs_image(:,:,3);
    color = reshape(rgb_image, [], 3);
    scatter3(x(:), y(:), z(:), ones(size(x(:))), color);
    xlabel('X'), ylabel('Y'), zlabel('Z');
    axis square
    set(gca, 'Projection','perspective')
end

