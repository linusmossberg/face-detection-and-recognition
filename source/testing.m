
faces_path = '../../faces/';

image_files = dir([faces_path, '*.jpg']);
matched = 0;
for image_file = image_files'
    i = str2num(extractBefore(extractAfter(image_file.name, '_'), '.'));
    id = getId(i);
    matched_id = tnm034(imread([image_file.folder '\' image_file.name]));
    if id == matched_id
        matched = matched + 1;
        disp([image_file.name ', correctly matched id: ' num2str(matched_id)])
    else
        disp([image_file.name ', matched id: ' num2str(matched_id)])
    end
end

accuracy = (matched/length(image_files)) * 100;
disp(['Accuracy: ' num2str(accuracy) '%']);