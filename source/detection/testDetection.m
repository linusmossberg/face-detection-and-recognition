
image_files = dir('../data/faces/*.jpg');
for image_file = image_files'
    image = imread([image_file.folder '\' image_file.name]);
    figure(1)
    subplot(1,2,1)
    imshow(image)
    [face_triangle, image] = detectFace(image);
    face = normalizeFace(face_triangle, image, 'eigen');
    if(~isempty(face))
        subplot(1,2,2)
        imshow(face);
        hold on; 

        x = [ 49.2308 206.7692 128.0000 ];
        y = [ 62.3713 62.3713 236.8363 ];

        s = 0.5;

        plot(x, y, 'k.', 'MarkerSize', 64*s);
        plot(x, y, 'w.', 'MarkerSize', 48*s);
        plot(x, y, 'k.', 'MarkerSize', 32*s);
        plot(x, y, 'w.', 'MarkerSize', 10*s);
        hold off;
    end
end



