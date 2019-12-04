% Gets the ID of a person from the 1999 faces caltech dataset from:
% http://www.vision.caltech.edu/html-files/archive.html
% 16 people from the dataset are assigned ID's and the model is trained to
% recognize these people. The rest has no ID and the program should
% recognize this and return ID 0.

function id = getId(image_num)
    id_ranges = [ 1 21 ; 22 41 ; 47 68 ; 90 112 ; 133 137 ; 138 158 ; ...
                  176 195 ; 196 216 ; 217 241 ; 242 263 ; 269 287 ; ...
                  337 356 ; 357 376 ; 377 398 ; 404 408 ; 409 428 ];
              
    for id = 1:size(id_ranges, 1)
        id_range = id_ranges(id,:);
        if id_range(1) <= image_num && image_num <= id_range(2)
            return;
        end
    end
    id = 0;
end

