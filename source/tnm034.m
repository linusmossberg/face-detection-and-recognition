function id = tnm034(im)
    
    initiate();
    
    id = 0;
    
    face = detectFace(im);
    if ~isempty(face)
        id = recognizeFace(face, 'fisher');
    end
end