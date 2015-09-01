function fun_coll(path_img_sub, path_save, file_name, trks, param, t_start, t_end, lenTime)

fprintf('Collectiveness begin ...\n');
% =============== init collective map
bg = imread([path_img_sub,'000000.jpg']);
[M, N, ~] = size(bg);
collective_map = zeros(M,N);
collective_map_count = zeros(M,N);
M_mask = floor(M/param.maskSize);
N_mask = floor(N/param.maskSize);

num = 0;
while t_start+t_end-1 < lenTime
    [XVset] = trk2XV(trks, 1, 2, t_start+t_end-1); % transform trajectories into point set
    collective_mask = []; collective_mask_map = [];
    num = num + 1;
    disp(['Frame ',num2str(num)])
    
    if isempty(XVset)
        % there is no track
        collective_mask_map = zeros(M, N);
        save([path_save, file_name, '_', sprintf('%03d',num), '_coll.mat'], 'collective_mask_map');
        t_start = t_start + 1;
        continue;
    end
    
    for i = t_start : t_start+t_end-1
        curIndex = find(XVset(:, 5) == i); % index
        curX = XVset(curIndex,1:2);        % point [x,y]
        curV = XVset(curIndex,3:4);        % velocity [v_x,v_y]
        curTrkInd = XVset(curIndex,6);     % trk index
        curOrder = SDP_order(curV); % average velocity measurement
        if size(curX,1) > 10
            [collectivenessSet, ~, ~] = measureCollectiveness(curX, curV, param);%crowd collectiveness
            % ========== collective map accumulation -- pixel-based
            collective_map_id = sub2ind([M,N],curX(:,2),curX(:,1));
            collective_map_cur = zeros(M,N);
            collective_map_cur(collective_map_id) = collectivenessSet;
            collective_map = collective_map + collective_map_cur;
            collective_map_cur_count = zeros(M,N);
            collective_map_cur_count(collective_map_id) = 1;
            collective_map_count = collective_map_count + collective_map_cur_count;
        end
    end
    
    % ========== collecitve map -- mask-based
    for i = 1 : param.maskSize : M-param.maskSize+1
        for j = 1 : param.maskSize : N-param.maskSize+1
            collective_mask = [collective_mask; sum(sum(collective_map(i:i+param.maskSize-1,j:j+param.maskSize-1,:)))];
        end
    end
    collective_mask = collective_mask./(t_end-t_start+1);
    collective_mask = reshape(collective_mask, [N_mask, M_mask])';
    collective_mask_map = imresize(collective_mask, [M N]);
    save([path_save, file_name, '_', sprintf('%03d',num), '_coll.mat'], 'collective_mask_map');
    
    t_start = t_start + 1;
end










