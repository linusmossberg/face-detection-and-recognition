function computeThreshold()
    image_files = dir(['../../indb/', '*.jpg']);
    in_db_distances = [];
    i = 1;
    for image_file = image_files'
        face = detectFace(imread([image_file.folder, '\', image_file.name]));
        if ~isempty(face)
            [~, in_db_distances(i)] = recognizeFace(face, 'fisher');
            i = i + 1;
        end
    end
    plot(0:1:100, normpdf(0:1:100, mean(in_db_distances), std(in_db_distances)));
    hold on;
    
    image_files = dir(['../../notindb/', '*.jpg']);
    not_in_db_distances = [];
    i = 1;
    for image_file = image_files'
        face = detectFace(imread([image_file.folder, '\', image_file.name]));
        if ~isempty(face)
            [~, not_in_db_distances(i)] = recognizeFace(face, 'fisher');
            i = i + 1;
        end
    end
    plot(0:1:100, normpdf(0:1:100, mean(not_in_db_distances), std(not_in_db_distances)));
    hold off;
end

