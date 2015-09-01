function [collectivenessSet, crowdCollectiveness, Z] = measureCollectiveness( curX, curV, para)
%Objective: to measure the collectiveness of moving points.
%   curX:                   spatial location of points.
%   curV:                   velocity of points.
%   collectivenessSet:      individual collectiveness.
%   crowdCollectiveness:    crowd collectiveness

%% step 1: compute the weighted adjacency matrix using KNN
weightedAdjacencyMatrix = computeAdj(curX, curV, para.K);

%% step 2: integrating all the paths with regularization
I_matrix = eye(size(weightedAdjacencyMatrix,1));
Z = inv(I_matrix-para.z*weightedAdjacencyMatrix) - I_matrix;
collectivenessSet = sum(Z,2);
crowdCollectiveness = mean(collectivenessSet);
end

function weightedAdjacencyMatrix = computeAdj(curX, curV, K)
distanceMatrix = slmetric_pw(curX',curX','eucdist');
correlationMatrix = slmetric_pw(curV',curV','nrmcorr');
%% K-nearest neighbor adjacency matrix
neighborMatrix = zeros(size(distanceMatrix,1));
for i=1:size(distanceMatrix,1)
    [~,neighborIndex] = sort(distanceMatrix(i,:),'ascend');
    neighborMatrix(i,neighborIndex(2:K+1)) = 1;
end
weightedAdjacencyMatrix = (correlationMatrix.*neighborMatrix);%weigted adjacency matrix
end