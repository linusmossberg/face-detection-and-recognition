% Requires the 1999 faces caltech dataset from:
% http://www.vision.caltech.edu/html-files/archive.html
% The folder_path variable below should point to this.

function face_tiles = createRepresentativeFaceTiles()
    representative = [1,2,10,12,23,31,37,38,42,45,49,51,58,59,70,73,75,80, ...
    90,94,99,105, 114,120,123,127,136,137,142,143,144,152,159,161,163,165, ...
    166,167,171,174,175,183,188,189,190,201,204,209,210,217,218,222,225,243, ...
    250,252,262,270,272,274,276,307,310,314,319,324,337,338,344,353,357,359, ...
    360,364,377,381,387,391,401,406,407,408,413,417,419,420,431,436,440,445];
    
    folder_path = '../data/faces/';
    face_coords = load([folder_path 'ImageData.mat']).SubDir_Data;
    images = {};
    i = 1;
    for image_num = representative
        image_path = [folder_path, 'image_' num2str(image_num,'%04d') '.jpg'];
        
        min_c = face_coords(3:4, image_num)';
        max_c = face_coords(7:8, image_num)';

        image = im2double(imread(image_path));
        
        % Chicken and egg issue where white balance depends on skin model
        % which depends on white balance. I've tried to select images that 
        % either look well balanced or has a blue bias (skin tends to be
        % more red). I've also tried to select images with large bright
        % areas that are brighter than the face, and where those bright
        % areas looks to be white reflecting materials. By then performing
        % the white balance on the enire image and not just the cropped
        % face, the skin model evaluation can hopefully be removed from the
        % white balance step.
        
        % Ideally the skin model should probably be created with 
        % unprocessed raw images taken under perfect white light, and would 
        % therefore not need white balance compensation. The only source of 
        % bias would then be the physical camera transfer function which 
        % probably could be baked into the skin model to detect skin in 
        % images taken with similar cameras (digital/film separation).
        omit_skin_model = true;
        image = whiteBalance(image, omit_skin_model, 'PCA');
        image = imcrop(image, [min_c (max_c - min_c)]);
        
        %images{1, i} = im2uint16(image);
        images{1, i} = image;
        i = i + 1;
    end
    %imshow(imtile(images));
    %imwrite(imtile(images), '../data/skin-model/representative_faces.png');
    face_tiles = imtile(images);
end

% Old method that automatically picks 'good' images. Works pretty well but
% it tends to pick images of some people more than others, probably because
% they were taken under better conditions.
function createRepresentativeFaceTilesOld()
    folder_path = '../data/faces/';
    face_coords = load([folder_path 'ImageData.mat']).SubDir_Data;
    image_files = dir([folder_path, '*.jpg']);
    images = {};
    i = 1;
    for image_file = image_files'
        image_path = [folder_path, image_file.name];

        num = str2num(extractBefore(extractAfter(image_file.name, '_'), '.'));
        min_c = face_coords(3:4, num)';
        max_c = face_coords(7:8, num)';

        image = im2double(imread(image_path));

        image = imcrop(image, [min_c (max_c - min_c)]);

        [illuminant, num_pixels] = computeIlluminant(image);
        eps_wb = 0.06;
        whitebalanced = (abs(illuminant(1) - illuminant(2)) < eps_wb);
        whitebalanced = (abs(illuminant(2) - illuminant(3)) < eps_wb) && whitebalanced;
        whitebalanced = (abs(illuminant(3) - illuminant(1)) < eps_wb) && whitebalanced;
        whitebalanced = (num_pixels > 100) && whitebalanced;

        eps_exp = 0.1;
        exposure_factor = exposureFactor(image);
        well_exposed = (exposure_factor - 1.0) < eps_exp;

        eps_mid = 0.1;
        mid_weighted = (mean(image(:)) - 0.5) < eps_mid;

        if(whitebalanced && well_exposed && mid_weighted)
            image = chromadapt(image, illuminant);
            image = immultiply(image, exposure_factor);
            images{1, i} = im2uint8(image);
            i = i + 1;
        end
    end
    imshow(imtile(images));
    %imwrite(imtile(images), '../data/representative_faces.png');
end

function exposure_factor = exposureFactor(image)
    gray_image = rgb2gray(image);
    [counts, intensities] = imhist(gray_image, 2^10);
    cumulative_counts = cumsum(counts);
    index = find(cumulative_counts >= numel(gray_image) * 0.5, 1, 'first');
    intensity = intensities(index);
    exposure_factor = 0.5 / intensity;
end

function [illuminant, num_pixels] = computeIlluminant(image)
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
end

