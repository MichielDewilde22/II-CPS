function [isMarked] = PixelCompare(im, h_pixel, v_pixel)
%PIXELCOMPARE Check if a pixel is marked
%   This function checks a BW image to see if the pixel is marked. It
%   returns 1 if the pixel is marked, 0 if the pixel is unmarked.
isMarked = im(h_pixel,v_pixel);
end

