function database = createDatabase(rebuild)
    if ~rebuild && isfile('database.mat')
        database = load('database.mat').images;
    else
        folder_path = '../data/DB1/';
        image_files = dir([folder_path, '*.jpg']);
        for image_file = image_files'
            id = str2num(extractBefore(extractAfter(image_file.name, '_'), '.'));
            image = imread([folder_path, image_file.name]);
            
            image = im2double(image);
            image = whiteBalance(image);
            image = autoExposure(image); % Really helps the skin model
            
            images{id, 1} = image;
        end
        save('database.mat', 'images');
        database = images;
    end
end