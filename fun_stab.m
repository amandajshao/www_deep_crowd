function fun_stab(path_img_sub, path_save, file_name, trks, param, t_start, t_end, lenTime)

fprintf('Stability begin ...\n');
num_temp = 0;
num = 0;

% ======== init
bg = imread([path_img_sub, '000000.jpg']);
[M, N, ~] = size(bg);
stability_map = zeros(M,N); % stability map 1
stability_map_count = zeros(M,N); % count the frequency of each pixel
M_mask = floor(M/param.maskSize);
N_mask = floor(N/param.maskSize);

while t_start+t_end-1 < lenTime
    [XVset] = trk2XV(trks, 1, 2, t_end); % transform trajectories into point set
    stability_mask = []; stability_mask_map = [];
    num = num + 1;
    disp(['Frame ', num2str(num)])
    
    if isempty(XVset)
        % there is no track
        stability_mask_map = zeros(M, N);
        save([path_save, file_name, '_', sprintf('%03d',num), '_stab.mat'], 'stability_mask_map');
        t_start = t_start + 1;
        continue;
    end
    
    for t = t_start : t_start+t_end-1
        NNTrkInd = []; NNTrkX = [];
        stab_inv_num = [];
        
        for i = t : min(t+param.t_interval-1,t_end)
            curIndex = find(XVset(:, 5) == i); % index
            curX = XVset(curIndex,1:2);        % point [x,y]
            curV = XVset(curIndex,3:4);        % velocity [v_x,v_y]
            curTrkInd = XVset(curIndex,6);     % trk index
            if size(curX,1) > 10
                % ========= find K-NNs of each trk current point
                distMat = distmat(curX); % distance matrix
                [~,NNIndex] = gacMink(distMat, param.K+1, 2);
                curNNTrkInd = curTrkInd(NNIndex);
                %----------------------------------------------------------------------------------%
                % NNTrkInd -- [1st_col:Time; 2nd_col:Trk_index; 3rd~17th_col:NN_Trk_index] (rank by "Time")
                % NNTrkIndSort -- [1st_col:Time; 2nd_col:Trk_index; 3rd~17th_col:NN_Trk_index] (rank by "Trk_index")
                % In the following, compute each point's stability
                %----------------------------------------------------------------------------------%
                NNTrkInd = [NNTrkInd; [ones(size(curTrkInd))*i, curNNTrkInd]];
                NNTrkX = [NNTrkX; [ones(size(curTrkInd))*i, curX]];
            end
        end
        
        if ~isempty(NNTrkInd )
            [NNTrkIndSort, sort_ind] = sortrows(NNTrkInd, 2);
            NNTrkXSort = NNTrkX(sort_ind,:);
            [TrkInd, ind, ~] = unique(NNTrkIndSort(:,2));
            TrkX = NNTrkXSort(ind,2:3);
            
            for k = 1 : length(TrkInd)
                knn_ind = NNTrkIndSort(NNTrkIndSort(:,2)==TrkInd(k), 3:end); % all K-NNs index of k-th trk
                knn_ind_unique = unique(knn_ind);
                % ======== compute stability cue 1: invariant K-NN index variation
                stab_nn_num = zeros(1,length(knn_ind_unique));
                for j = 1 : length(knn_ind_unique)
                    [n,~] = find(knn_ind==knn_ind_unique(j));
                    stab_nn_num(1,j) = length(n);
                end
                stab_nn_inv_seq = (stab_nn_num >= size(knn_ind,1)*param.invar_th);
                stab_inv_num(k) = length(find(stab_nn_inv_seq~=0));
            end
            
            % ======== stability map cue 1
            num_temp = num_temp + 1;
            stability_map_id = sub2ind([M,N],TrkX(:,2),TrkX(:,1));
            stability_map_cur = zeros(M,N);
            stability_map_cur(stability_map_id) = stab_inv_num;
            stability_map = stability_map + stability_map_cur;
        end
    end
    
    % ========== stability map1 -- mask-based
    stability_mask = [];
    for i = 1 : param.maskSize : M-param.maskSize+1
        for j = 1 : param.maskSize : N-param.maskSize+1
            stability_mask = [stability_mask; sum(sum(stability_map(i:i+param.maskSize-1,j:j+param.maskSize-1,:)))];
        end
    end
    stability_mask = stability_mask./num_temp;
    stability_mask = reshape(stability_mask, [N_mask, M_mask])';
    stability_mask_map = imresize(stability_mask, [M N]);
    save([path_save, file_name, '_', sprintf('%03d',num), '_stab.mat'], 'stability_mask_map');
    
    t_start = t_start + 1;
end






