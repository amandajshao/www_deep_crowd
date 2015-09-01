%% main function

clc;clear;

addpath(genpath('collectiveness-master'))
addpath(genpath('gcatoolbox'))
addpath(genpath('util'))

path = '.\';
path_video = [path, 'exp_video\'];
path_img = [path, 'exp_img\'];
path_motion = [path, 'exp_motion\'];
path_channel = [path, 'exp_channel\'];mkdir(path_channel);
path_dir = dir([path_video,'*.avi']);


for file_n = 1 : length(path_dir)
    file_name_ori = path_dir(file_n).name;
    file_name = file_name_ori(1:end-4);
    disp([num2str(file_n), ',', file_name]);
    path_img_sub = [path_img,file_name,'\'];
    
    %% video2img
    img_size = [360,640]; % image size used in CVPR15
    resize_flag = 1;      % 1 if resize, 0 otherwise
    img_len_limit = 600;  % length of selected frames
    fun_video2img(path_video, path_img, img_size, resize_flag, img_len_limit, file_name_ori);
    
    %% KLT
    scale = 10;
    path_klt = '.\GKLT-master\klt_tracker.exe ';
    fun_klt(path_img_sub, path_klt, scale);
    
    delete_th1 = 10;   % the length of a trk
    delete_th2 = 30;   % the distance between original location and terminate
    delete_th3 = 5;    % time of sb staying at the same location
    smooth_th = 10;
    
    trks = fun_readTraks([path_img,file_name,'\klt_5000_10_trk.txt']);
    save([path_img,file_name,'\trks.mat'], 'trks');
    trks = fun_preprocess_klt(trks, delete_th1, delete_th2, delete_th3);
    save([path_img,file_name,'\klt_5000_10_trk.mat'], 'trks');
    trks = fun_smooth_trk(trks,smooth_th);
    save([path_img,file_name,'\klt_5000_10_trk_smooth.mat'], 'trks');
    
    
    %% motion descriptor
    load([path_img_sub, 'klt_5000_10_trk_smooth.mat'], 'trks');
    param.K = 10; % K nearest neighbour
    param.maskSize = 40;
    param.tLen = 75;
    [~, lenTime, ~, ~] = fun_trkInfo(trks);
    t_start = 2;
    t_end = min(lenTime,param.tLen);
    
    param.z = 0.5/param.K ;
    param.upperBound = param.K*param.z/(1-param.K*param.z);
    param.threshold = 0.6*param.z/(1-param.K*param.z);
    path_save = [path_motion, 'coll\']; mkdir(path_save);
    fun_coll(path_img_sub, path_save, file_name, trks, param, t_start, t_end, lenTime);
    fprintf('Collectiveness done!\n=======================\n');
    
    param.conf_th = 0.2;
    path_save = [path_motion, 'conf\']; mkdir(path_save);
    fun_conf(path_img_sub, path_save, file_name, trks, param, t_start, t_end, lenTime);
    fprintf('Conflict done!\n=======================\n');

    param.invar_th = 0.8;
    param.t_interval = 10;
    path_save = [path_motion, 'stab\']; mkdir(path_save);
    fun_stab(path_img_sub, path_save, file_name, trks, param, t_start, t_end, lenTime);
    fprintf('Stability done!\n=======================\n');
   
    %% appearance & motion channels
    fun_channel_rgb(path_img_sub, path_channel, file_name, t_start, lenTime-t_end-1);
    load('.\motion_norm.mat','motion_norm');
    fun_channel_motion(path_motion, path_channel, file_name, t_start, lenTime-t_end-1, motion_norm);
end


















