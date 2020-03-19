function [vector] = mat2vec(matrix)
    %MAT2VEC Enables slicing and converting a matrix to vector in a single line.
    %   Unlike Python, MATLAB does not allow for repeated idexing of an array, e.g. A(:, 1:3)(1, :).
    %   This function serves as an intermediary step to enable slicing a matrix and converting it to a vector in a single line.
    %   
    %   Example
    %       % It is not possible to write these actions as a single statement
    %       B = A(:, 1:3);
    %       C = functionRequiringVectorInput(B(:));
    %
    %       % Unless using an intermediate function call
    %       C = functionRequiringVectorInput(mat2vec(A(:, 1:3)));
    
    vector = matrix(:);
end

