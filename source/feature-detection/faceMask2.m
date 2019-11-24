function [face_mask, quality] = faceMask2(skin, image)
    
    skin = bwareaopen(skin, 400, 4);
    
    skin = bwareaopen(~skin, 100, 4);
    skin = ~skin;
    
    CC = bwconncomp(skin);
    L = labelmatrix(CC);
    S = regionprops('table', CC, 'EulerNumber', 'Area', ...
                    'MajorAxisLength', 'MinorAxisLength', ...
                    'Orientation', 'Circularity', 'Eccentricity', ...
                    'Extent', 'FilledArea', 'BoundingBox', ...
                    'Centroid');
    
    candidates = find(S.EulerNumber < 0);
    candidates = intersect(candidates, find(abs(abs(S.Orientation) - 90) < 45));
    candidates = intersect(candidates, find(S.FilledArea > 10000));
    candidates = intersect(candidates, find(S.Eccentricity > 0.4 & S.Eccentricity < 0.9));
    candidates = intersect(candidates, find(S.Extent > 0.3)); % 0.3
    candidates = intersect(candidates, find(S.BoundingBox(:, 4) ./ S.BoundingBox(:, 3) < 2.5));
    candidates = intersect(candidates, find(S.FilledArea ./ S.Area > 1.006));
    
    candidates = candidates';
    
    perimeter_ratios = {};
    remove = []; num = 0;
    for c = candidates
        perimeter_mask = ismember(L, c);
        perimeter_mask = imfill(imclose(perimeter_mask, strel('disk', 16)), 'holes');

        C_CC = bwconncomp(perimeter_mask);
        C_S = regionprops('table', C_CC, 'Perimeter', ...
                          'MajorAxisLength', 'MinorAxisLength');
                      
        a = C_S.MajorAxisLength / 2;
        b = C_S.MinorAxisLength / 2;
        ellipse_perimeter = pi * (3 * (a + b) - sqrt((3*a + b)*(a + 3*b)));
        
        perimeter_ratio = ellipse_perimeter / C_S.Perimeter;
        
        if(perimeter_ratio < 0.617)
            num = num + 1;
            remove(num) = c;
        end
        
        perimeter_ratios{c} = perimeter_ratio;
    end
    
    candidates = setdiff(candidates, remove);
    
    if(isempty(candidates))
        %disp(S)
        %disp('no candidates!')
        %imshow(skin)
        quality = 0;
        face_mask = skin;
        return;
    end

    pairs = cell(1, max(candidates));
    BB = S.BoundingBox;
    
    for c = candidates
        for region = 1:size(S,1)
            if(c == region)
                continue;
            end
            
            in_area = rectint(BB(c, :), BB(region, :));
            BB_area = BB(region, 3) * BB(region, 4);
            
            % Keep regions within the candidates bounding box if they
            % overlap by at least 50%. (ears, chin separate from face due
            % to beard etc.)
            overlap_ratio = in_area / BB_area;
            if(overlap_ratio > 0.5)
                pairs{c} = [pairs{c} region];
            end
        end
    end
    
    % Contains all candidate regions and the regions paired with them.
%     candidates_mask = ismember(L, unique([candidates unique([ pairs{candidates} ])]));
%         
%     closed_candidates_mask = imfill(imclose(candidates_mask, true(32)), 'holes');
%     filt_candidates_mask = bwareaopen(candidates_mask, 400, 4);
%     filt_candidates_mask = imdilate(filt_candidates_mask, strel('disk', 3));
%     eye_mask = ~filt_candidates_mask & closed_candidates_mask;
%     eye_mask = bwareaopen(eye_mask, 100, 4);
% 
%     eyes = detectEyes(image, eye_mask);
    
    candidates_quality = {};
    
    for c = candidates
        q = 0;
%         if(~isempty(fieldnames(eyes)))
%             xq = [eyes.left(1), eyes.right(1)];
%             yq = [eyes.left(2), eyes.right(2)];
% 
%             BB = S.BoundingBox(c,:);
%             xv = [BB(1), BB(1) + BB(3), BB(1) + BB(3), BB(1), BB(1) ];
%             yv = [BB(2), BB(2), BB(2) + BB(4), BB(2) + BB(4), BB(2) ];
% 
%             % inpolygon returns [0 0] if bounding box contains no eyes, 
%             % [1 0] if it contains left eye and so on. This can therefore
%             % contribute 0, 1 or 2 to the quality measure before sqrt scale
%             q = sum(inpolygon(xq,yq,xv,yv));
%         end
        q = q + ((1/0.3) * S.Extent(c)) ^ 2;
        q = q + ((1/0.8) * perimeter_ratios{c}) ^ 2;
        q = q + (6 * S.Area(c) / numel(skin)) ^ 2;
        %q = q + sqrt(abs(S.EulerNumber(c)));

        candidates_quality{c} = sqrt(q);
    end
    
    [quality, c_idx] = max([candidates_quality{candidates}]);
    winner = candidates(c_idx);
    winner_regions = [winner pairs{winner}];
    face_mask = ismember(L, winner_regions);
    
%     disp({'quality' quality})
%     
%     runner_up_regions = setdiff(unique([candidates unique([ pairs{candidates} ])]), winner_regions);
%     remaining_regions = setdiff(1:size(S,1), unique([candidates unique([ pairs{candidates} ])]));
%     
%     imshow(skin); hold on;
%     
%     for region = winner_regions
%         rectangle('Position', S.BoundingBox(region, :), 'LineWidth', 2, 'EdgeColor', 'b')
%     end
%     
%     for region = runner_up_regions
%         rectangle('Position', S.BoundingBox(region, :), 'LineWidth', 2, 'EdgeColor', 'g')
%     end
%     
%     for region = remaining_regions
%         rectangle('Position', S.BoundingBox(region, :), 'LineWidth', 2, 'EdgeColor', 'r')
%     end
%         
%     if(exist('eyes', 'var') && ~isempty(fieldnames(eyes)))
%         x = [eyes.left(1) eyes.right(1)];
%         y = [eyes.left(2) eyes.right(2)];
%         s = 0.5;
%         plot(x, y, 'k.', 'MarkerSize', 64*s);
%         plot(x, y, 'w.', 'MarkerSize', 48*s);
%         plot(x, y, 'k.', 'MarkerSize', 32*s);
%         plot(x, y, 'w.', 'MarkerSize', 10*s);
%     end
%     hold off;
end

