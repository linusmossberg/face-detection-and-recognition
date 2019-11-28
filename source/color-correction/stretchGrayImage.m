function result = stretchGrayImage(image, percentage)
    result = imadjust(image, stretchlim(image, percentage/100));
end

