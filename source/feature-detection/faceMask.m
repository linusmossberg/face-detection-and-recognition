function [result, found] = faceMask(skin)

    found = true;
    
    skin = bwareaopen(skin, 400, 4);
    
    % Ruins a lot but required when for example  
    % beard cuts off mouth region from rest of face.
    result = imclose(skin, strel('disk', 6));
    %result = imclose(result, true(16));
    
    CC = bwconncomp(result);
    S = regionprops(CC, 'EulerNumber');
    L = labelmatrix(CC);
    idx = find([S.EulerNumber] < 1);
    if ~isempty(idx)
        result = ismember(L, idx);
    end
    
    result = imfill(result,'holes');

    result = bwareaopen(result, 10000, 4);
    
    CCs = bwconncomp(result);
    Ss = regionprops('table', CCs, 'MajorAxisLength','MinorAxisLength', 'Orientation', 'Eccentricity');
    Ls = labelmatrix(CCs);
    ratio = Ss.MajorAxisLength ./ Ss.MinorAxisLength;
    orientation_lim = abs(abs(Ss.Orientation) - 90) < 45;
    ratio(~orientation_lim) = max(ratio) + 1;
    idx = find(ratio <= min(ratio));
    if isempty(idx)
        found = false;
        return;
    end
    result = ismember(Ls, idx);
    
    result = imclose(result, strel('disk',64));
    result = imfill(result,'holes');
    
    result = imerode(result, strel('disk',16));
    
    result = bwareaopen(result, 10000, 4);
    
    CCs = bwconncomp(result);
    Ss = regionprops('table', CCs, 'MajorAxisLength','MinorAxisLength', ...
                     'Orientation', 'Circularity', 'Eccentricity');
    Ls = labelmatrix(CCs);
    ratio = Ss.MajorAxisLength ./ Ss.MinorAxisLength;
    orientation_lim = abs(abs(Ss.Orientation) - 90) < 45;
    circularity_lim = Ss.Circularity > 0.28;
    eccentricity_lim = Ss.Eccentricity < 0.96;
    ratio_lim = ratio < 3.8; % 3.5 ratio orig
    max_ratio = max(ratio);
    ratio(~orientation_lim) = max_ratio + 1;
    ratio(~circularity_lim) = max_ratio + 1;
    ratio(~eccentricity_lim) = max_ratio + 1;
    ratio(~ratio_lim) = max_ratio + 1;
    idx = find(ratio <= min(ratio));
    
    if isempty(idx) || ~ratio_lim(idx) || ~orientation_lim(idx) || ~circularity_lim(idx) || ~eccentricity_lim(idx)
        found = false;
        return;
    end
    
    result = ismember(Ls, idx);
    
    
    
%     test = (result .* skin);
%     imshow((test + result + skin)/3);
%     
%     CC = bwconncomp(result);
%     S = regionprops('table', CC, 'MajorAxisLength','MinorAxisLength','Orientation', 'Centroid');
%     if size(S, 1) > 0
%         x = S.Centroid(:,1);
%         y = S.Centroid(:,2);
% 
%         angle = -S.Orientation;
% 
%         ellipse(S.MajorAxisLength/2, S.MinorAxisLength/2, deg2rad(angle), x, y, 'r');
%         hold on;
%         plot(x, y, 'r.', 'MarkerSize', 32)
% 
%         xl = [x - S.MajorAxisLength/2 .* cos(deg2rad(angle)), x + S.MajorAxisLength/2 .* cos(deg2rad(angle))];
%         yl = [y - S.MajorAxisLength/2 .* sin(deg2rad(angle)), y + S.MajorAxisLength/2 .* sin(deg2rad(angle))];
%         line(xl,yl, 'Color','red', 'LineWidth',3)
% 
%         xl = [x - S.MinorAxisLength/2 .* cos(deg2rad(90 + angle)), x + S.MinorAxisLength/2 .* cos(deg2rad(90 + angle))];
%         yl = [y - S.MinorAxisLength/2 .* sin(deg2rad(90 + angle)), y + S.MinorAxisLength/2 .* sin(deg2rad(90 + angle))];
%         line(xl,yl, 'Color','red', 'LineWidth',3)
% 
%         hold off;
%     end
    
    
    % initial_contour_mask = bwconvhull(mask, 'Union');
    % mask = activecontour(rescale(skin_density), initial_contour_mask, 100, 'edge');
end

