function fun_conf(path_img_sub, path_save, file_name, trks, param, t_start, t_end, lenTime)

fprintf('Conflict begin ...\n');
% ======== init
bg = imread([path_img_sub,'000000.jpg']);
[M, N, ~] = size(bg);
conflict_map = zeros(M,N); % conflict map
conflict_map_count = zeros(M,N); % count the frequency of each pixel
M_mask = floor(M/param.maskSize);
N_mask = floor(N/param.maskSize);

num = 0;
while t_start+t_end-1 < lenTime
    [XVset] = trk2XV(trks, 1, 2, t_end); % transform trajectories into point set
    conflict_mask = []; conflict_mask_map = [];
    num = num + 1;
    disp(['Frame ',num2str(num)])
    
    if isempty(XVset)
        % there is no track
        conflict_mask_map = zeros(M, N);
        save([path_save, file_name, '_', sprintf('%03d',num), '_conf.mat'], 'conflict_mask_map');
        t_start = t_start + 1;
        continue;
    end
    
    for i = t_start : t_start+t_end-1
        curIndex = find(XVset(:, 5) == i); % index
        curX = XVset(curIndex,1:2);        % point [x,y]
        curV = XVset(curIndex,3:4);        % velocity [v_x,v_y]
        curTrkInd = XVset(curIndex,6);     % trk index
        cur_conf = zeros(size(curIndex));  % conflict
        if size(curX,1) > 10
            % ========= find K-NNs of each trk current point
            distMat = distmat(curX); % distance matrix
            [~,NNIndex] = gacMink(distMat, param.K+1, 2);
            % ========= compute conflict of each trk point via velocity correlation
            for k = 1 : size(curX,1)
                knn_ind = NNIndex(k,2:end)';
                knn_x = curX(knn_ind,:);
                knn_v = curV(knn_ind,:);
                trk_x = curX(k,:);
                trk_v = curV(k,:);
                v_corr = (trk_v*knn_v')'./(norm(trk_v)*sqrt(sum(knn_v.^2,2))+eps);
                v_corr(v_corr>param.conf_th) = 0;
                cur_conf(k) = -sum(v_corr);
                % cur_conf(k) = -sum(v_corr)/param.K; % normalize or not
            end
            % ======= conflict map
            conflict_map_id = sub2ind([M,N],curX(:,2),curX(:,1));
            conflict_map_cur = zeros(M,N);
            conflict_map_cur(conflict_map_id) = cur_conf;
            conflict_map = conflict_map + conflict_map_cur;
        end
    end
    
    % ========== conflict map -- mask-based
    for i = 1 : param.maskSize : M-param.maskSize+1
        for j = 1 : param.maskSize : N-param.maskSize+1
            conflict_mask = [conflict_mask; sum(sum(conflict_map(i:i+param.maskSize-1,j:j+param.maskSize-1,:)))];
        end
    end
    conflict_mask = conflict_mask./(t_end-t_start+1);
    conflict_mask = reshape(conflict_mask, [N_mask, M_mask])';
    conflict_mask_map = imresize(conflict_mask, [M N]);
    save([path_save, file_name, '_', sprintf('%03d',num), '_conf.mat'], 'conflict_mask_map');
    
    t_start = t_start + 1;
end






