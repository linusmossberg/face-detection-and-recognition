
function result = whiteBalance(image, omit_skin_model, type)

    if(~exist('omit_skin_model','var') || isempty(omit_skin_model))
        omit_skin_model = false;
    end
    
    if(~exist('type','var') || isempty(type))
        type = 'PCA';
    end
    
    clipped = image > (1e-4 + 254/255);
    clipped = clipped(:,:,1) | clipped(:,:,2) | clipped(:,:,3);
    clipped = imdilate(clipped, strel('disk', 11));
    
    switch type
        case 'PCA'
            illuminant = illumpca(rgb2lin(image));
            illuminant = lin2rgb(illuminant);
        case 'GW'
            illuminant = illumgray(rgb2lin(image), 10, 'Mask', ~clipped);
            illuminant = lin2rgb(illuminant);
        case 'gray-contrib'
            illuminant = grayContribGW(image, clipped);
        otherwise
            illuminant = illumpca(rgb2lin(image));
            illuminant = lin2rgb(illuminant);
    end
    
    skin_illuminant = false;
    if(~omit_skin_model)
        skin_illuminant = evaluateSkinDensityModel2D(illuminant);  
    end
    
    if(skin_illuminant)
        disp('Skin illuminant');
        result = image;
    else
        result = chromadapt(image, illuminant);
    end
    
end

% Computes white balance illuminant by taking the average RGB value of the 
% brightest pixels that contributes 50% of the total image brightness.

% This should technically be linearized in order to find the pixels that
% truly contribute 50% of the brightness, otherwise each pixel channel is
% pushed above its true value by the gamma curve. However, 50% is just an
% arbitrary number that works well on images with gamma correction applied.

function illuminant = grayContribGW(image, clipped)

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
    illuminant = zeros(1,3);
    for c = 1:3
        channel = image(:,:,c);
        illuminant(c) = mean(channel(mask));
    end
end

