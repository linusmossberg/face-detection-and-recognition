function result = radialHSV(hsv)
    hsv_v = reshape(hsv, [], 3);
    
    x = hsv_v(:,2) .* cos(hsv_v(:,1) * 2 * pi);
    y = hsv_v(:,2) .* sin(hsv_v(:,1) * 2 * pi);
    z = hsv_v(:,3);
    
    result = reshape([x, y, z], size(hsv));
end

