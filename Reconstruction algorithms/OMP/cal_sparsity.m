%   This function calculates the sparsity ratio and number of non-zeros
%   pixels of the given input image
%   @params:
%       img: double - matrix represents the input image
%   @return:
%       sparsity: double - sparsity ratio of the image
%       non_zeros: double - number of non-zeros pixels of the image

function [sparsity, non_zeros] = cal_sparsity(img)
    num_zeros = sum(sum(img == 0));
    img_pixels = size(img, 1)*size(img, 2);
    non_zeros =  img_pixels - num_zeros;
    sparsity = non_zeros/img_pixels;
end