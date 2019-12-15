
type = 'eigen';

image_files = dir('../data/faces/*.jpg');
correctly_matched = 0;
false_positives = 0;
false_negatives = 0;
for image_file = image_files'
    i = str2num(extractBefore(extractAfter(image_file.name, '_'), '.'));
    id = getId(i);
    [matched_id, distance] = tnm034(imread([image_file.folder '\' image_file.name]), type);
    if id == matched_id
        correctly_matched = correctly_matched + 1;
        disp([image_file.name ', correctly matched id: ' num2str(matched_id)])
    else
        if id ~= 0 && matched_id == 0
            false_negatives = false_negatives + 1;
        else
            false_positives = false_positives + 1;
        end
        disp([image_file.name ', incorrectly matched id: ' num2str(matched_id)])
    end
end

num_training_images = 72;
num_test_images = length(image_files) - num_training_images;

correctly_matched = correctly_matched - num_training_images;

accuracy  = 100 * correctly_matched / num_test_images;
fn_errors = 100 * false_negatives   / num_test_images;
fp_errors = 100 * false_positives   / num_test_images;

disp(['Accuracy: ' num2str(accuracy) '%']);
disp(['False negatives: ' num2str(fn_errors) '%']);
disp(['False positives: ' num2str(fp_errors) '%']);
