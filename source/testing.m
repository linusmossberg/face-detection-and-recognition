folder_path = '../data/DB0/';
%folder_path = '../../indb/';
image_files = dir([folder_path, '*.jpg']);
matched = 0;
for image_file = image_files'
    %id = str2num(extractBefore(extractAfter(image_file.name, '_'), '.'));
    id = 0;
    matched_id = tnm034(imread([folder_path, image_file.name]));
    imshow(imread([folder_path, image_file.name]))
    disp(matched_id)
    if id == matched_id
        matched = matched + 1;
    else
        disp([image_file.name ', matched id: ' num2str(matched_id)])
    end
end

accuracy = (matched/length(image_files)) * 100;
disp(['Accuracy: ' num2str(accuracy) '%']);
% if ~isempty(valid_distances)
%     max_valid_distance = max(valid_distances);
%     disp(['Max valid distance: ' num2str(max_valid_distance)]);
% end