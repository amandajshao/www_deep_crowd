function fun_channel_rgb(path_img_sub, path_save, file_name, t_start, t_end)

fprintf('Appearance channel generation!\n=======================\n');
file_n = 0;
channel_img_batch = []; 
label_batch_www = [];

for j = t_start : t_end    
    file_n = file_n + 1;
    disp(['Frame ', num2str(file_n)]);
    % save file name: file_name_list
    file_name_list_batch{file_n,1} = [file_name,'_',sprintf('%03d',file_n)];
    
    % save rgb 3 channels: img_channel
    img = imread([path_img_sub,sprintf('%06d',j),'.jpg']);
    img_norm = im2double(img); % change to [0,1]
    channel_img_batch(:,:,:,file_n) = img_norm;
    
    % save label: label
    label = zeros(1,94);
    label_batch(file_n,:) = label;
end
channel_img_batch = single(channel_img_batch);
save([path_save,'data_rgb_',file_name,'.mat'],'file_name_list_batch','channel_img_batch','label_batch');










