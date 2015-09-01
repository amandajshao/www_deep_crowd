function fun_channel_motion(path_motion, path_save, file_name, t_start, t_end, motion_norm)

fprintf('Motion channel generation!\n=======================\n');
file_n = 0;
channel_img_batch = []; label_batch = []; file_name_list_batch = [];
motion_norm_min = fun_cell2num(motion_norm(3,:));
motion_norm_max = fun_cell2num(motion_norm(2,:));

for j = t_start : t_end    
    file_n = file_n + 1;
    disp(['Frame ', num2str(file_n)]);
    % save file name: file_name_list
    file_name_list_batch{file_n,1} = [file_name,'_',sprintf('%03d',file_n)];
    
    % save motion 3 channels: motion_channel
    motion_type = {'coll', 'conf', 'stab'};
    motion = [];
    for motion_n = 1 : 3
        path_motion_sub = motion_type{motion_n};
        motion_cur = importdata([path_motion, path_motion_sub, '\', file_name, '_', sprintf('%03d',j), '_', path_motion_sub, '.mat']);
        % if motion has NaN value
        motion_cur(isnan(motion_cur)) = 0;
        motion(:,:,motion_n) = (motion_cur-motion_norm_min(motion_n))./...
            (motion_norm_max(motion_n)-motion_norm_min(motion_n));
    end
    channel_img_batch(:,:,:,file_n) = motion;
    
    % save label: label
    label = zeros(1,94);
    label_batch(file_n,:) = label;
end
channel_img_batch(channel_img_batch<0) = 0; 
channel_img_batch = single(channel_img_batch);
save([path_save,'data_motion_',file_name,'.mat'],'file_name_list_batch','channel_img_batch','label_batch');











