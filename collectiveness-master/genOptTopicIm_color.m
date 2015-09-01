function im = genOptTopicIm_color(A, bgim, maskSize, n)

imSize = size(bgim);

% CV = [1 0 0; 1 0 1; 0 1 1; 0 0 1;];
% CV = [1 0 0; 0 1 1; 1 0 1; 0 0 1;];
% CV = [0 0 1; 1 0 1; 1 0 0; 0 1 1;];
% CV = [1 0 0; 0 0 1; 1 0 1; 0 1 1;];
% CV = [1 0 1; 0 1 1; 1 0 0; 0 0 1;];
CV = [0 1 0; 1 0 0; 0 0 1; 0 1 1;]; % gas; fluid; solid


C1 = repmat(reshape(CV(1,:), [1 1 3]), [maskSize(1) maskSize(2) 1]);

C2 = repmat(reshape(CV(2,:), [1 1 3]), [maskSize(1) maskSize(2) 1]);

C3 = repmat(reshape(CV(3,:), [1 1 3]), [maskSize(1) maskSize(2) 1]);

C4 = repmat(reshape(CV(4,:), [1 1 3]), [maskSize(1) maskSize(2) 1]);



bgim = rgb2gray(bgim);

bgim = im2double(bgim);

bgim = repmat(bgim, [1 1 3]);

B = reshape(A, [maskSize(1) maskSize(2) n]);
% B = reshape(A, [maskSize(2) maskSize(1) n]);


S = sum(B, 3);


b = max(S(:));

 B = B/b;

I = C1.* repmat(B(:,:,1), [1 1 3]) + C2.* repmat(B(:,:,2), [1 1 3]) + C3.* repmat(B(:,:,3), [1 1 3]) + C4.* repmat(B(:,:,4), [1 1 3]);


I = imresize(I, [imSize(1) imSize(2)]);

% im = (1 - 0.5)*bgim + I ;
% im = 1.5*bgim + I ;
im = bgim + I ;