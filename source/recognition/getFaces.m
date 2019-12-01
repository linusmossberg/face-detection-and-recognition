function [faces, ids] = getFaces()

    persistent faces_;
    persistent ids_;
    
    if ~isempty(faces_) && ~isempty(ids_)
        faces = faces_;
        ids = ids_;
        return;
    end

    image_files = [ dir(['../data/DB1/', '*.jpg']) ; ...
                    dir(['../data/DB2/', '*.jpg']) ];
                
    i = 1;
    for image_file = image_files'
        id = str2num(extractBefore(extractAfter(image_file.name, '_'), '.'));
        image = imread([image_file.folder, '\', image_file.name]);
        face = detectFace(image);
        if(~isempty(face))
            faces(:,:,i) = detectFace(image);
            ids(i) = id;
            i = i + 1;
        end
    end
    
%     additional_faces = [65 140 155 240 274 362 406];
%     
%     for image_num = additional_faces
%         id = getId(image_num);
%         image = imread(['../../faces/image_' num2str(image_num, '%04d') '.jpg']);
%         face = detectFace(image);
%         if(~isempty(face))
%             faces(:,:,i) = detectFace(image);
%             ids(i) = id;
%             i = i + 1;
%         end
%     end
    
    faces_ = faces;
    ids_ = ids;
end

