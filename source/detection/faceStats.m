% Returns the expected value (mu) and standard deviation (sigma) of the
% ratio between the distance from mouth to eye line and the distance from 
% eye to eye for a few samples.

% eye_____eye
%      |
%      |
%    mouth

function [mu, sigma] = faceStats()
    persistent mu_;
    persistent sigma_;
    
    % Don't recompute if mu and sigma already has been computed. Clear
    % function to recompute.
    if ~isempty(mu_) && ~isempty(sigma_) 
        mu = mu_;
        sigma = sigma_;
        return;
    end

    mouth_to_eyeline_dist = [133.5 112.3 126.8 114.1 ...
                             144.1 120.3 153.3 115.0 ...
                             144.5 114.7 133.8 135.8 ...
                             130.1 151.5 132.8 138.8];
                         
    eye_to_eye_dist = [117.6 116.5 135.5  99.6 ...
                       129.8 108.6 135.1 112.5 ...
                       128.3  98.5 110.3 134.3 ...
                       118.9 121.3 110.7 125.5];
    
    ratio = mouth_to_eyeline_dist ./ eye_to_eye_dist;
    
    sigma = sqrt(var(ratio));
    mu = mean(ratio);
    
    sigma_ = sigma;
    mu_ = mu;
end

