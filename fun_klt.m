function fun_klt(path_img_sub,path_klt,scale)

path_img_sub_dir = dir([path_img_sub, '0*']);
imgNum = length(path_img_sub_dir);

cmd = [path_klt path_img_sub ' ' num2str(imgNum) ' 5000' ' ' num2str(scale) ' 16'];

nameMat = [];
if ~exist([path_img_sub,'imageList.txt']) % need generate imageList.txt
    fid = fopen([path_img_sub,'imageList.txt'], 'wt');
    for n = 1 : length(path_img_sub_dir)
        nameMat(n,:) = path_img_sub_dir(n).name;
        fprintf(fid, '%s\n', nameMat(n,:));
    end
    fclose(fid);
    system(cmd);
else
    system(cmd);
end

