initiate();

image_files = dir('../data/faces/*.jpg');
for image_file = image_files'
    image = im2double(imread([image_file.folder '\' image_file.name]));
    figure(1)
    subplot(1,2,1)
    imshow(image)
    face = detectFace(image);
    if(~isempty(face))
        subplot(1,2,2)
        imshow(face);
        hold on; 

        x = [ 48.0000, 208.0000, 128.0000 ];
        y = [ 59.5362, 59.5362, 236.7273 ];

        s = 0.5;

        plot(x, y, 'k.', 'MarkerSize', 64*s);
        plot(x, y, 'w.', 'MarkerSize', 48*s);
        plot(x, y, 'k.', 'MarkerSize', 32*s);
        plot(x, y, 'w.', 'MarkerSize', 10*s);
        hold off;
    end
end



