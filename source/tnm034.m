function id = tnm034(im)
    
    addpath(genpath('skin-models'));
    addpath(genpath('color-correction'));
    addpath(genpath('color-space'));
    addpath(genpath('feature-detection'));
    addpath(genpath('recognition'));
    addpath(genpath('external'));

    face = detectFace(im);
    if ~isempty(face)
        id = recognizeFace(face);
    else
        id = 0;
    end
end