% OMPv1 implements the Orthogonal Matching Pursuit (OMP) algorithm for 
% sparse signal recovery. Given a measurement vector y and a sensing 
% matrix A, the function estimates the sparse coefficient vector theta.
%
% The relationship can be described as:
%   y = Phi * x  
%   x = Psi * theta  
%   y = Phi * Psi * theta  
%   Let A = Phi * Psi, then y = A * theta  
%   Given y and A, the goal is to solve for theta.
%
% @params:
%   y: matrix - the measurement vector (Mx1)
%   A: matrix - the sensing matrix (MxN)
%   t: int - the number of non-zero coefficients to be estimated
%
% @return:
%   theta: matrix - the estimated sparse coefficient vector (Nx1)  

function theta = OMPv1(y, A, t)  
    [y_rows, y_columns] = size(y);  
    if y_rows < y_columns  
        y = y';  % Ensure y is a column vector  
    end  
    
    [M, N] = size(A);  % A is the sensing matrix of size MxN  
    theta = zeros(N, 1);  % Initialize theta (the sparse coefficient vector) as a column vector  
    At = zeros(M, t);  % Matrix to store selected columns of A during iterations  
    Pos_theta = zeros(1, t);  % Array to store the indices of selected columns  
    r_n = y;  % Initialize the residual (r_n) as y  

    for ii = 1:t  % Iterate t times, where t is the number of non-zero coefficients to estimate  
        product = A' * r_n;  % Compute the inner product of A's columns with the residual  
        [~, pos] = max(abs(product));  % Find the index of the column with the maximum absolute inner product  
        
        At(:, ii) = A(:, pos);  % Store the selected column in At  
        Pos_theta(ii) = pos;  % Store the index of the selected column  
        
        A(:, pos) = zeros(M, 1);  % Optionally clear the selected column in A (not necessary for orthogonality)  
        
        % Compute the least squares solution for the current selected columns  
        theta_ls = (At(:, 1:ii)' * At(:, 1:ii))^(-1) * At(:, 1:ii)' * y;  
        
        % Update the residual  
        r_n = y - At(:, 1:ii) * theta_ls;  
    end
    
    theta(Pos_theta) = theta_ls;  % Assign the estimated coefficients to the corresponding positions in theta  
end