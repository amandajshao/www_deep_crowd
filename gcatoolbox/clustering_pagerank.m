clc;clear;close all; %clf

clusterNum = 4;

%% load X
% %% simulation
% X = [randn(500,2)-ones(500,1)*[5,-1];...
%      randn(1200,2)-ones(1200,2);...
%      randn(2000,2)-ones(2000,1)*[-1,5];...
%      randn(100,2)-ones(100,1)*[-5,10];...
%      randn(150,2)-ones(150,1)*[10,5]];
% save('X.mat', 'X');
% % groudtruth = [ones(1000,1);2*ones(1200,1); 3*ones(1500,1)];
% 
% X = [2*rand(500,2)+ones(500,1)*[2,2];...
%      2*rand(1000,2);...
%      2*rand(300,2)+ones(300,1)*[-2, -2];...
%      2*rand(300,2)+ones(300,1)*[2, -2];...
%      2*rand(500,2)+ones(500,1)*[-2, 2]];
% % groudtruth = [ones(500,1); 2*ones(1000,1); 3*ones(100,1); 4*ones(300,1); 5*ones(50,1)];
% 
% figure(1)
% plot(X(:,1), X(:,2), 'o', 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm', 'MarkerSize', 3);


%% real crowded data
file_n = 15;
time = 2;
load(['X_', num2str(file_n), '_', num2str(time), '.mat']);

% select one largest set to do following spatial clustering exp
len = max(unique(X(:,3)))
for i = 1 : len
    len_mat(i) = length(find(X(:,3)==i));
end
[~,idx] = max(len_mat);
X = X(X(:,3)==idx,1:2);

file_root = 'D:\Documents\sj_file\CT_result\';
file_path = [file_root, num2str(file_n), '\'];
% file_root = 'D:\Documents\sj_file\escalator\';
% file_path = [file_root, sprintf('%05d',file_n), '\'];

im = imread([file_path, sprintf('%06d',time+1), '.jpg']);
[im_M,im_N,~] = size(im);

figure(1)
imshow(im)
hold on
plot(X(:,1), X(:,2), 'o', 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm', 'MarkerSize', 3);
hold off
% saveas(gcf, [num2str(file_n),'_',num2str(time), '.jpg'], 'jpg');


%% pagerank
distance_matrix = distmat(X);

figure(2); 
imagesc(distance_matrix); 

d = 0.85;
errTh = 0.001;
K = floor(length(X(:,1))/10)+1

% NN indices
N = size(distance_matrix,1);
% find 2*K NNs in the sense of given distances
[sortedDist,NNIndex] = gacMink(distance_matrix,max(K+1,4),2);
NI = NNIndex(:, 2:K+1);
XI = repmat([1:N]', 1, K);
graphW = full(sparse(XI(:),NI(:),1, N, N));
% graphW(1:N+1:end) = 1;
graphW = graphW./K;
adjacency_matrix = graphW';

pr = rank2(adjacency_matrix, d, errTh);

prX = [X, pr];
figure(50)
scatter(prX(:,1), prX(:,2), 20, prX(:,3), 'filled'); 
grid on;
axis([0 im_N 0 im_M]);
set(gca,'YDir','Reverse')
title(['PageRank (K=', num2str(K), ')'])
hold off

[~, topidx] = sort(pr, 'descend');
percentage = 0.75;
chosen_idx = topidx(1:round(N*percentage));

distance_matrix_sub = distance_matrix(chosen_idx, chosen_idx);
X_sub = X(chosen_idx, :);


%% gdl
% K = 10;
a = 1;
[clusteredLabels, Q, W, cost, rk] = graphAgglomerativeClustering(distance_matrix_sub, clusterNum, 'gdl', K, 1, a, false, X_sub, true);
ctrs_gdl = zeros(clusterNum, 2);
for i = 1:clusterNum
    ctrs_gdl(i,:) = mean(X(clusteredLabels==i,:));
end

% figure(51)
% scatter(X_sub(:,1), X_sub(:,2), 20, rk, 'filled'); 
% grid on;

figure(3)
imshow(im);
hold on
for i = 1 : max(unique(clusteredLabels))
    cl = colorrand(i);
    plot(X_sub(clusteredLabels==i,1), X_sub(clusteredLabels==i,2), 'o', ...
        'MarkerFaceColor', cl, 'MarkerEdgeColor', cl, 'MarkerSize', 5);
    hold on
end
% plot(X_sub(clusteredLabels==1,1),X_sub(clusteredLabels==1,2),'r.','MarkerSize',12)
% hold on
% plot(X_sub(clusteredLabels==2,1),X_sub(clusteredLabels==2,2),'g.','MarkerSize',12)
% hold on
% plot(X_sub(clusteredLabels==3,1),X_sub(clusteredLabels==3,2),'b.','MarkerSize',12)
% grid on
% plot(X_sub(clusteredLabels==4,1),X_sub(clusteredLabels==4,2),'c.','MarkerSize',12)
% grid on
% plot(X_sub(clusteredLabels==5,1),X_sub(clusteredLabels==5,2),'m.','MarkerSize',12)
% grid on

% axis([-2, 4, -2, 4]);

% plot(ctrs(:,1),ctrs(:,2),'kx',...
%      'MarkerSize',12,'LineWidth',2)
% plot(ctrs(:,1),ctrs(:,2),'ko',...
%      'MarkerSize',12,'LineWidth',2)
% legend('Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5',...
%        'Location','NE')
hold off;

[temp1, clusterNumPred1] = min(abs(diff(cost)));
clusterNumber1 = length(cost) - (clusterNumPred1-1) + 1
figure(7), plot(diff(cost), '*-'); hold on; plot(clusterNumPred1, temp1,'r*'); 
grid on; title('2nd differential Q value');

figure(4), plot(cost, '*-'); 
% hold on; plot(clusterNumPred1-1, cost(clusterNumPred1-1), 'r*');
xlabel('iteration'); ylabel('maximum affinity evolution'); grid on; axis tight; title('Affinity evolution');
% figure(4), subplot(1,2,2); plot([length(cost)-14:length(cost)], cost(end-14:end),'*-'); xlabel('iteration'); ylabel('maximum affinity evolution'); grid on; axis tight; title('Affinity evolution'); 

[temp, clusterNumPred] = min(diff(diff(Q)));
clusterNumber = length(Q) - (clusterNumPred-1) + 1
figure(5), plot(Q, '*-'); 
% hold on; plot(clusterNumPred-1, Q(clusterNumPred-1), 'r*');
xlabel('iteration'); ylabel('Q function evolution'); grid on; title('Q function');

figure(6), plot(diff(diff(Q)), '*-'); hold on; plot(clusterNumPred, temp,'r*'); 
grid on; title('2nd differential Q value');




% %% calculate the error w.r.t. ground truth
% prec_kmeans = gt_comparison(groudtruth, idx, cluster_centrs_gt, ctrs);
% prec_gdl = gt_comparison(groudtruth, clusteredLabels, cluster_centrs_gt, ctrs_gdl);
% % error_gdl = sum(ground_truth - clusteredLabels ~= 0)/numel(ground_truth)*100;
% disp(['error percentage of kmeans is ', num2str(prec_kmeans) ' %. ']);
% disp(['error percentage of gdl is ', num2str(prec_gdl) ' %. ']);




%% k-means
% cluster_centrs_gt = [[3,3];[1,1];[-1,-1];[3,-1];[-1,3]];
% opts = statset('Display','final');
% 
% [idx,ctrs] = kmeans(X,clusterNum,'Distance','city','Replicates',5,'Options',opts);
% 
% figure(1);
% plot(X(idx==1,1),X(idx==1,2),'r.','MarkerSize',12)
% hold on
% plot(X(idx==2,1),X(idx==2,2),'g.','MarkerSize',12)
% hold on
% plot(X(idx==3,1),X(idx==3,2),'b.','MarkerSize',12)
% grid on
% % plot(X(idx==4,1),X(idx==4,2),'c.','MarkerSize',12)
% % grid on
% % plot(X(idx==5,1),X(idx==5,2),'m.','MarkerSize',12)
% % grid on
% plot(ctrs(:,1),ctrs(:,2),'kx',...
%      'MarkerSize',12,'LineWidth',2)
% plot(ctrs(:,1),ctrs(:,2),'ko',...
%      'MarkerSize',12,'LineWidth',2)
% % legend('Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5',...
% %        'Location','NE')
% hold off; 
% % xy = 10*rand(25,2);  % 25 points in 2D


%% meanshift
% [clustCent,point2cluster,clustMembsCell] = MeanShiftCluster(X',1);
% numClust = length(clustMembsCell);
% 
% figure(10),clf,hold on
% cVec = 'bgrcmykbgrcmykbgrcmykbgrcmyk';%, cVec = [cVec cVec];
% for k = 1:min(numClust,length(cVec))
%     myMembers = clustMembsCell{k};
%     myClustCen = clustCent(:,k);
%     plot(X(myMembers,1),X(myMembers,2),[cVec(k) '.'])
%     plot(myClustCen(1),myClustCen(2),'o','MarkerEdgeColor','k','MarkerFaceColor',cVec(k), 'MarkerSize',10)
% end
% % title(['no shifting, numClust:' int2str(numClust)])
% grid on;