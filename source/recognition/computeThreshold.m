function threshold = computeThreshold()
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
    
    x = -20:0.001:70;
    pdf_not_in_db = normpdf(x, mean(not_in_db_distances), std(not_in_db_distances));
    pdf_in_db = normpdf(x, mean(in_db_distances), std(in_db_distances));
    
    % Find intersection between the normal distributions and set this as
    % threshold
    overlap = pdf_in_db - max(pdf_in_db - pdf_not_in_db, 0);
    [~, idx] = max(overlap);
    
    threshold = x(idx);
    
    % Resulting overlap % in which errors occur, 
    overlap_percentage = trapz(x, overlap) * 100;
    
    disp(['Overlap: ' num2str(overlap_percentage) '%']);
    
    area(x, pdf_in_db); hold on
    area(x, pdf_not_in_db); 
    area(x, overlap)
    hold off
end

