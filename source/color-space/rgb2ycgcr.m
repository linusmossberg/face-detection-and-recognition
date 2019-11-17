function ycgcr = rgb2ycgcr(rgb)
    rgb_v = reshape(rgb, [], 3);
    
    R = rgb_v(:,1);
    G = rgb_v(:,2);
    B = rgb_v(:,3);
    
    Y  = ( 16 + 65.481 * R + 128.553 * G + 24.966 * B) / 255.0;
    Cg = (128 - 81.085 * R + 112     * G - 30.915 * B) / 255.0;
    Cr = (128 + 112    * R - 93.768  * G - 18.214 * B) / 255.0;
    
    ycgcr = reshape([Y, Cg, Cr], size(rgb));
end

