function precision = gt_comparison(groundtruth, estimation, cluster_centrs_gt, cluster_centrs_est)

    est_label = unique(estimation);
    gt_label = size(cluster_centrs_gt,1);
    
    if numel(est_label) ~= (gt_label)
        error('numbers of estimated clusterings and ground truth clustering are not matched');
    end
    
    est_change = zeros(size(estimation));
    % find correct label corresponding
    for i = 1:numel(est_label)
        dist = sum((ones(gt_label,1)*cluster_centrs_gt(i,:) - cluster_centrs_est).^2,2);
        [~, idx] = min(dist);
        est_change(estimation == idx) = i;
    end
    
    precision = sum(groundtruth - est_change ~= 0)/sum(estimation)*100;

end