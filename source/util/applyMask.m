function result = applyMask(image, mask)
    result = bsxfun(@times, image, cast(mask, 'like', image));
end

