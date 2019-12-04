function upper_face = ellipseUpperFaceRegion(face_mask)
    CC = bwconncomp(face_mask);
    S = regionprops('table', CC, 'MajorAxisLength','MinorAxisLength', ...
                    'Orientation', 'Centroid');
                
    invalid_angle = abs(abs(S.Orientation) - 90) > 45;
    if isempty(invalid_angle)
        invalid_angle = true;
    end
    
    if(invalid_angle || size(S,1) <= 0)
        upper_face = face_mask;
    else
        Cx = S.Centroid(:,1);
        Cy = S.Centroid(:,2);
        a = S.MajorAxisLength/2;
        b = S.MinorAxisLength/2;
        angle = deg2rad(-S.Orientation);

        width = size(face_mask,2);
        height = size(face_mask,1);

        [X, Y] = meshgrid(1:width, 1:height);

        x =  cos(angle) * (X - Cx) + sin(angle) * (Y - Cy);
        y = -sin(angle) * (X - Cx) + cos(angle) * (Y - Cy);

        face_ellipse = (x).^2 / (a^2) + (y).^2 / (b^2) <= 1;

        line_x = [Cx - b * cos(angle + pi/2), Cx + b * cos(angle + pi/2)];
        line_y = [Cy - b * sin(angle + pi/2), Cy + b * sin(angle + pi/2)];
        
        offset = 25;
        angle = abs(angle);
        line_x_offset = [offset * cos(angle), offset * cos(angle)];
        line_y_offset = [offset * sin(angle), offset * sin(angle)];
        
        line_x = line_x + line_x_offset;
        line_y = line_y + line_y_offset;

        above_face_line = (Y - line_y(1)) <= (((line_y(2) - line_y(1))/(line_x(2) - line_x(1)))*(X - line_x(1)));
        
        upper_face = face_ellipse &  above_face_line & face_mask;
    end
end

