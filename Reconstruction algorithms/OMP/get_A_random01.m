%   This function generates random matrix size m x n with entries of 0 or
%   1. No row/column is entirely zero. 
%   @params:
%       n: int - number of columns of matrix A
%       m: int - number of rows of matrix A
%   @return:
%       A: matrix

function A = get_A_random01(n, m)
% Initialize the matrix
A = zeros(m, n);

% Fill the matrix ensuring no full zero rows and columns
while true
    % Generate a random matrix with values between 0 and 1
    A = randi([0, 1], m, n); % Random integers (0 or 1)
    
    % Check if there are any full zero rows or columns
    if all(any(A, 1)) && all(any(A, 2))
        break; % Exit the loop if no full zero rows or columns
    end
end
end