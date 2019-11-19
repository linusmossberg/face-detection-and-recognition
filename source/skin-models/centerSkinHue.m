% Shifts hue 180 degrees to place skin tones (red hues) at the 
% center along the hue dimension.

function result = centerSkinHue(hsv)
    result = reshape(hsv, [], 3);
    result(:,1) = mod(result(:,1) + 0.5, 1.0);
    result = reshape(result, size(hsv));
end

