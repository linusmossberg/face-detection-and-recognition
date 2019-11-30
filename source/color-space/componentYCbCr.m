function [Y, Cb, Cr] = componentYCbCr(rgb, scale)

    if(nargin < 2)
        scale = 1;
    end

    YCbCr = rgb2ycbcr(rgb) * scale;
    
    if(numel(YCbCr) == 3)
        Y = YCbCr(1);
        Cb = YCbCr(2);
        Cr = YCbCr(3);
    else
        Y = YCbCr(:,:,1);
        Cb = YCbCr(:,:,2);
        Cr = YCbCr(:,:,3);
    end
end

