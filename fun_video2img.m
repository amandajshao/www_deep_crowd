%% fun_video2img
function fun_video2img(path_video,path_img,img_size,resize_flag,img_len_limit,file_name)

fprintf('Extract frames begin ...\n');
save_file = file_name;
save_folder = [path_img, save_file(1:end-4), '\'];
[~,b,~] = mkdir(save_folder);

if ~strcmp('Directory already exists.',b)
    file = [path_video, file_name];
    vid = VideoReader(file);
    NumFr = min(img_len_limit,vid.NumberOfFrames);
    mov = read(vid, [1 NumFr]);
    
    % ========= save image sequence
    start_n = 25;
    for img_n = start_n : min(img_len_limit,size(mov,4)) % originally n starts at 1
        disp(['Frame ',num2str(img_n)]);
        im = mov(:,:,:,img_n);
        if resize_flag == 1 % need resize
            imwrite(imresize(im,img_size), [save_folder,sprintf('%06d',img_n-start_n+1),'.jpg'], 'jpg');
        else
            imwrite(im, [save_folder,sprintf('%06d',img_n-start_n+1),'.jpg'], 'jpg');
        end
    end
    
    % ========= compute bg
    fun_background_simple(save_folder,length(dir([save_folder,'*.jpg'])));
    clear im vid
    
    % ========= compute txtImgList
    img_dir = dir([save_folder, '0*.jpg']);
    fid = fopen([save_folder,'imageList.txt'], 'wt');
    
    for i = 1 : length(img_dir)
        nameMat(i,:) = img_dir(i).name;
        fprintf(fid, '%s\n', nameMat(i,:));
    end
    fclose(fid);
    nameMat = [];
else
    disp('Done!');
end

