% Different graphs and calculations that can help with finding good
% distance threshold values. The minimum of the 'errors' vector is probably
% the best as this optimally reduces the sum of false positives and
% negatives on the caltech dataset. Thresholding has to be disabled in
% recognizeFace() for this to work.

type = 'fisher';

if ~exist('faces', 'var')
    faces = [];
end

image_files = dir('../data/faces/*.jpg');

if isempty(faces)
    num = 1;
    for image_file = image_files'
        [face_triangle, image] = detectFace(imread([image_file.folder, '\', image_file.name]));
        if(~isempty(fieldnames(face_triangle)))
            faces(:,:,num) = normalizeFace(face_triangle, image, type);
            image_num = str2num(extractBefore(extractAfter(image_file.name, '_'), '.'));
            ids(num) = getId(image_num);
            num = num + 1;
        end
    end
end

in_db_distances = [];
not_in_db_distances = [];
in = 1;
not_in = 1;
num_errors1 = 0;
id_distances = cell(1,16);
for i = 1:size(faces, 3)
    id = ids(i);
    [matched_id, distance] = recognizeFace(faces(:,:,i), type);
    if matched_id == id
        in_db_distances(in) = distance;
        in = in + 1;
        id_distances{id} = [id_distances{id} distance];
    elseif id == 0
        not_in_db_distances(not_in) = distance;
        not_in = not_in + 1;
    else
        num_errors1 = num_errors1 + 1;
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

figure
area(x, pdf_in_db); hold on
area(x, pdf_not_in_db); 
area(x, overlap)
xlabel('Distance Threshold')
legend('Known Acceptance', 'Unknown Acceptance', 'Overlap')
hold off

t = 0:0.001:100;
errors = zeros(size(t));
for i = 1:length(t)
    errors(i) = sum(in_db_distances > t(i)) + sum(not_in_db_distances < t(i));
end

[num_errors, idx] = min(errors);
num_errors = num_errors + num_errors1;
threshold2 = t(idx);
figure
plot(t, errors + num_errors1)
xlabel('Distance Threshold')
ylabel('Total Number of Errors')

max_dist_per_id = zeros(16);
mean_dist_per_id = zeros(16);
for i = 1:16
    max_dist_per_id(i) = max(id_distances{i});
    mean_dist_per_id(i) = mean(id_distances{i});
end

figure
bar(max_dist_per_id)
figure
bar(mean_dist_per_id)

