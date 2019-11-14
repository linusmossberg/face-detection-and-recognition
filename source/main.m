clear

%image = imread('..\data\DB2\cl_10.jpg');
image = imread('..\data\DB1\db1_09.jpg');
image = im2double(image);
image = whiteBalance(image);
image = autoExposure(image);

face_mask = faceMask(image);
eye_map = eyeMap(image, face_mask);
mouth_map = mouthMap(image, face_mask);
imshow(mouth_map + eye_map);

