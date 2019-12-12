% Returns 1 for skin and 0 otherwise. Input can be either an image or a
% single rgb vector, in which case the output is either a mask or a single
% logical value respectively.
function skin = transformedCbCrSkinModel(rgb)
    [Y, Cb, Cr] = componentYCbCr(rgb, 255);
    
    W_Cb = 46.97; WL_Cb = 23;
    WH_Cb = 14; W_Cr = 38.76;
    WL_Cr = 20; WH_Cr = 10;
    K_l = 125; K_h = 188;
    Y_min = 16; Y_max = 235;
    
    Y_less_Kl = Y < K_l;
    Kh_less_Y = K_h < Y;
    both = Y_less_Kl | Kh_less_Y;
    
    Cb_ = zeros(size(Cb));
    Cb_(Y_less_Kl) = 108 + ((K_l - Y(Y_less_Kl)) * (118-108)) / (K_l - Y_min);
    Cb_(Kh_less_Y) = 108 + ((Y(Kh_less_Y) - K_h) * (118-108)) / (Y_max - K_h);
    
    Cr_ = zeros(size(Cr));
    Cr_(Y_less_Kl) = 154 - ((K_l - Y(Y_less_Kl)) * (154-144)) / (K_l - Y_min);
    Cr_(Kh_less_Y) = 154 + ((Y(Kh_less_Y) - K_h) * (154-132)) / (Y_max - K_h);
    
    W_Cb_Y = zeros(size(Y));
    W_Cb_Y(Y_less_Kl) = WL_Cb + ((Y(Y_less_Kl) - Y_min) * (W_Cb - WL_Cb)) / (K_l - Y_min);
    W_Cb_Y(Kh_less_Y) = WH_Cb + ((Y_max - Y(Kh_less_Y)) * (W_Cb - WH_Cb)) / (Y_max - K_h);
    
    W_Cr_Y = zeros(size(Y));
    W_Cr_Y(Y_less_Kl) = WL_Cr + ((Y(Y_less_Kl) - Y_min) * (W_Cr - WL_Cr)) / (K_l - Y_min);
    W_Cr_Y(Kh_less_Y) = WH_Cr + ((Y_max - Y(Kh_less_Y)) * (W_Cr - WH_Cr)) / (Y_max - K_h);

    Cb_new = Cb; Cr_new = Cr;
    Cb_new(both) = (Cb(both) - Cb_(both)) .* (W_Cb ./ W_Cb_Y(both)) + Cb_(both);
    Cr_new(both) = (Cr(both) - Cr_(both)) .* (W_Cr ./ W_Cr_Y(both)) + Cr_(both);
    
    Cx = 109.36;
    Cy = 152.02;
    theta = 2.53;
    ECx = 1.6;
    ECy = 2.31;
    a = 25.39;
    b = 14.03;
    
    x =  cos(theta) * (Cb_new - Cx) + sin(theta) * (Cr_new - Cy);
    y = -sin(theta) * (Cb_new - Cx) + cos(theta) * (Cr_new - Cy);
    
    skin = (x - ECx).^2 / (a^2) + (y - ECy).^2 / (b^2) <= 1;
end

