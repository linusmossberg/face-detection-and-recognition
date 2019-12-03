function [faces, ids] = getTrainingFaces(type)
    
    DB1 = [ 9 26 55 105 137 142 183 204 217 252 276 337 375 377 408 420 ];
    
    DB2 = [ 2 3 8 17 31 40 58 66 94 95 111 133 134 153 156 ...
            179 181 182 190 201 211 223 231 238 259 261 272 ... 
            285 344 349 353 361 370 387 388 407 417 424 ];
                 
    additional = [ 32 34 50 155 206 240 256 262 274 ...
                   373 371 21 158 406 192 219 136 187 ];
    
    i = 1;
    for image_num = [DB1 DB2 additional]
        id = getId(image_num);
        image = imread(['../../faces/image_' num2str(image_num, '%04d') '.jpg']);
        [face_triangle, image] = detectFace(image);
        if(~isempty(fieldnames(face_triangle)))
            faces(:,:,i) = normalizeFace(image, face_triangle, type);
            ids(i) = id;
            i = i + 1;
        end
    end
end

