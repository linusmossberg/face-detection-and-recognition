% Performs automatic white balance correction on input image. Computes 
% white balance illuminant by taking the average RGB value of the brightest 
% pixels that contributes 5% of the total image brightness. The chromatic 
% part is then corrected using chromadapt.

function result = whiteBalance(image)
    gray_image = rgb2gray(image);
    intensity_5p = sum(gray_image(:)) * 0.05;
    [counts, intensities] = imhist(gray_image, 2^10);
    
    intensity = 0;
    cumulative_intensity = 0;
    for i = length(intensities):-1:1
        cumulative_intensity = cumulative_intensity + intensities(i) * counts(i);
        if(cumulative_intensity >= intensity_5p)
            intensity = intensities(i);
            break;
        end
    end
    
    mask = gray_image >= intensity;
    num_pixels = sum(mask(:));
    illuminant = zeros(1,3);
    for c = 1:3
        channel = image(:,:,c);
        illuminant(c) = sum(channel(mask)) / num_pixels;
    end
    
    if(skinModel(illuminant) || num_pixels < 100)
        result = image;
    else
        result = chromadapt(image, illuminant);
    end
end

