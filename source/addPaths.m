function addPaths()
    persistent paths_added;
    if(isempty(paths_added))
        addpath(genpath('skin-models'));
        addpath(genpath('color-correction'));
        addpath(genpath('color-space'));
        addpath(genpath('feature-detection'));
        addpath(genpath('recognition'));
        addpath(genpath('external'));
    end
    paths_added = true;
end

