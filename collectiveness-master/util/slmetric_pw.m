function M = slmetric_pw(X1, X2, mtype, varargin)
%SLMETRIC_PW Compute the metric between column vectors pairwisely
%
% $ Syntax $
%   - M = slmetric_pw(X1, X2, mtype);
%   - M = slmetric_pw(X1, X2, mtype, ...);
%
% $ Description $
%    - M = slmetric_pw(X1, X2, mtype) Computes the metrics between
%    column vectors of X1 and X2 pairwisely, using the metric
%    specified by mtype. If X1 has n1 columns, X2 has n2 columns, then
%    the resultant M would be of size n1 x n2. The entry at i-th row
%    and j-th column of M represents the metric between X1(:, i) and
%    X2(:, j).
%
%    - M = slmetric_pw(X1, X2, mtype, ...) Some metric types requires
%    extra parameters, which should be specified in params.
%
%    - The supported metrics of this function are listed as follows:
%      \*
%      \t  Table 1. The supported metrics                             \\
%      \h     name     &       description                            \\
%          'eucdist'   &  Euclidean distance: ||x - y||               \\         
%          'sqdist'    &  Square of Euclidean distance: ||x - y||^2   \\
%          'dotprod'   &  Canonical dot product: <x,y> = x^T * y      \\
%          'nrmcorr'   &  Normalized correlation (cosine angle):
%                         (x^T * y ) / (||x|| * ||y||)                \\
%          'angle'     &  Angle between two vectors (in radian)       \\
%          'quadfrm'   &  Quadratic form:  x^T * Q * y                
%                         Q is specified in the 1st extra parameter   \\
%          'quaddiff'  &  Quadratic form of difference:
%                         (x - y)^T * Q * (x - y),                
%                         Q is specified in the 1st extra parameter   \\
%          'cityblk'   &  City block distance (abssum of difference)  \\
%          'maxdiff'   &  Maximum absolute difference                 \\
%          'mindiff'   &  Minimum absolute difference                 \\
%          'wsqdist'   &  Weighted square of Euclidean distance       \\
%                         \sum_i w_i (x_i - y_i)^2,  w = (w_1, ..., w_d)                     
%                         the weights w is specified in 1st extra parameter 
%                         as a length-d column vector                  \\
%      \*
%
% $ Remarks $
%   - X1 and X2 are both matrices with n1 column vectors and n2 column 
%     vectors respectively. Then the resultant matrix M will be a n1 * n2
%     matrix. The entry at i-th row and j-th column of M is the metric between
%     the i-th column vector in X1 and the j-th column vector in X2.
%
% $ History $
%   - Created by Dahua Lin on Dec 06th, 2005
%   - Modified by Dahua Lin on Apr 21st, 2005
%       - regularize the error reporting
%   - Modified by Dahua Lin on Sep 11st, 2005
%       - completely rewrite the core codes based on new mex computation 
%         cores, and the runtime efficiency in both time and space is 
%         significantly increased.
%


%% parse and verify input arguments
if nargin < 3
    raise_lackinput('slmetric_pw', 3);
end
mtype = lower(mtype);

%% compute
switch mtype        
    case {'eucdist', 'sqdist'}
        checkdim(X1, X2);
        sqs1 = sum(X1 .* X1, 1)';
        sqs2 = sum(X2 .* X2, 1);
        M = (-2) * X1' * X2;
        M = sladdrowcols(M, sqs2, sqs1);
        M(M < 0) = 0;                        
        if strcmp(mtype, 'eucdist')
            M = sqrt(M);
        end 
        
    case 'dotprod'
        checkdim(X1, X2);
        M = X1' * X2;
                
    case {'nrmcorr', 'angle'}
        checkdim(X1, X2);
        M = X1' * X2;
        f1 = sqrt(sum(X1 .* X1, 1))';
        f2 = sqrt(sum(X2 .* X2, 1));
        f1(f1 < eps) = eps;  % prevent from being zeros
        f2(f2 < eps) = eps;
        f1 = 1 ./ f1;
        f2 = 1 ./ f2;
        M = slmulrowcols(M, f2, f1);        
        if strcmp(mtype, 'angle0')
            M = real(acos(M));
        end 
        
    case 'quadfrm'
        % parse parameters
        Q = varargin{1};
        [d1, d2] = size(Q);
        if size(X1, 1) ~= d1 || size(X2, 1) ~= d2
            error('sltoolbox:sizmismatch', ...
                'The dimensions of X1 and X2 are not consistent with Q');
        end
        
        % compute
        M = X1' * Q * X2;
        
    case 'quaddiff'
        % parse parameters
        d = checkdim(X1, X2);
        Q = varargin{1};
        if ~isequal(size(Q), [d, d])
            error('sltoolbox:dimmismatch', ...
                'The dimensions of X1 and X2 are not consistent with Q');
        end
        
        % compute
        qs1 = sum(X1 .* (Q * X1), 1)';
        qs2 = sum(X2 .* (Q * X2), 1);
        M = X1' * (-(Q + Q')) * X2;        
        M = sladdrowcols(M, qs2, qs1);
                
    case 'cityblk'
        M = sldiff_pw(X1, X2, 'abssum');
        
    case 'maxdiff'
        M = sldiff_pw(X1, X2, 'maxdiff');
        
    case 'mindiff'
        M = sldiff_pw(X1, X2, 'mindiff');
                
    case 'wsqdist'
        % parse parameters
        d = checkdim(X1, X2);
        w = varargin{1};
        if ~isequal(size(w), [d, 1])
            error('sltoolbox:sizmismatch', ...
                'w is not a proper size column vector');
        end

        % compute
       wX1 = slmulvec(X1, w, 1);
       qs1 = sum(wX1 .* X1, 1)';
       clear wX1;
       wX2 = slmulvec(X2, w, 1);
       qs2 = sum(wX2 .* X2, 1);
       M = (-2) * X1' * wX2;
       clear wX2;
       M = sladdrowcols(M, qs2, qs1);
        
    otherwise
        error('sltoolbox:invalid_type', 'Unknown metric type %s', mtype);
        
end
        
%% Auxiliary function

function d = checkdim(X1, X2)

d = size(X1, 1);
if d ~= size(X2, 1)
    error('sltoolbox:sizmismatch', ...
        'X1 and X2 have different sample dimensions');
end





