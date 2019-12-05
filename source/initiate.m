function initiate()
    persistent initiated;
    if(isempty(initiated))
        warning('off','images:bwfilt:tie');
        addpath(genpath('skin-models'));
        addpath(genpath('color-correction'));
        addpath(genpath('color-space'));
        addpath(genpath('detection'));
        addpath(genpath('recognition'));
        addpath(genpath('external'));
        addpath(genpath('util'));
        initiated = true;
    end
end

