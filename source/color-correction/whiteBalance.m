
function result = whiteBalance(image, omit_skin_model, type)
    
    switch type
        case 'GW'
            illuminant = illumgray(rgb2lin(image), 10, 'Mask', ~getClipped(image));
            illuminant = lin2rgb(illuminant);
        case 'GC'
            illuminant = grayContributionGW(image);
        otherwise
            illuminant = illumpca(rgb2lin(image));
            illuminant = lin2rgb(illuminant);
    end
    
    skin_illuminant = false;
    if(~omit_skin_model)
        skin_illuminant = evaluateSkinDensityModel2D(illuminant);
    end
    
    if(skin_illuminant)
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

function illuminant = grayContributionGW(image)

    clipped = getClipped(image);

    gray_image = rgb2gray(image);
    gray_vec = gray_image(~clipped); % remove overexposed pixels
    
    [counts, intensities] = imhist(gray_vec, 2^16);
    
    test = cumsum(counts .* intensities);
    idx = find(test < test(end) * 0.5, 1, 'last');
    intensity = intensities(idx);
    
    mask = (gray_image >= intensity) & ~clipped;
    illuminant = zeros(1,3);
    for c = 1:3
        channel = image(:,:,c);
        illuminant(c) = mean(channel(mask));
    end
end

function clipped = getClipped(image)
    clipped = image > (1e-4 + 254/255);
    clipped = clipped(:,:,1) | clipped(:,:,2) | clipped(:,:,3);
    clipped = imdilate(clipped, strel('disk', 11));
end

