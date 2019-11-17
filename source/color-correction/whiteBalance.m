% Performs automatic white balance correction on input image. Computes 
% white balance illuminant by taking the average RGB value of the brightest 
% pixels that contributes 50% of the total image brightness. The chromatic 
% part is then corrected using chromadapt.

% This should technically be linearized in order to find the pixels that
% truly contribute 50% of the brightness, otherwise each pixel channel is
% pushed above its true value by the gamma curve. However, 50% is just an
% arbitrary number that works well on images with gamma correction applied.

function result = whiteBalance(image, omit_skin_model)

    if(~exist('omit_skin_model','var') || isempty(omit_skin_model))
        omit_skin_model = false;
    end

    clipped = image > (1e-4 + 254/255);
    clipped = clipped(:,:,1) | clipped(:,:,2) | clipped(:,:,3);
    clipped = imdilate(clipped, strel('disk', 11));

    gray_image = rgb2gray(image);
    gray_vec = gray_image(~clipped); % remove overexposed pixels
    
    intensity_50p = sum(gray_vec(:)) * 0.5;
    [counts, intensities] = imhist(gray_vec, 2^16);
    
    intensity = 0;
    cumulative_intensity = 0;
    for i = length(intensities):-1:1
        cumulative_intensity = cumulative_intensity + intensities(i) * counts(i);
        if(cumulative_intensity >= intensity_50p)
            intensity = intensities(i);
            break;
        end
    end
    
    mask = (gray_image >= intensity) & ~clipped;
    num_pixels = sum(mask(:));
    illuminant = zeros(1,3);
    for c = 1:3
        channel = image(:,:,c);
        illuminant(c) = sum(channel(mask)) / num_pixels;
    end
    
%     illuminant = illumwhite(image, 11, 'Mask', ~clipped);
%     illuminant = illumgray(image, 11, 'Mask', ~clipped);
    
    if(~omit_skin_model && evaluateSkinDensityModel2D(illuminant))
        disp('Skin illuminant');
        result = image;
    else
        result = chromadapt(image, illuminant);
    end
end

