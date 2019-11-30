function id = tnm034(im)
    
    addPaths();

    face = detectFace(im);
    if ~isempty(face)
        id = recognizeFace(face, 'fisher');
    else
        id = 0;
    end
end