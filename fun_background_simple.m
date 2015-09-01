function fun_background_simple(path, pic_num)

if find(path=='\', 1, 'last') < length(path)
    path = [path, '\'];
end

if nargin == 2
    im = im2double(imread(strcat(path, sprintf('%06d', 1),'.jpg')));
    for i = 2 : pic_num
        im = im + im2double(imread(strcat(path, sprintf('%06d', i), '.jpg')));
    end
    im = im./pic_num;
    
    % imwrite(im, [path, 'background.jpg'], 'jpg')
    imwrite(im, [path, '000000.jpg'], 'jpg')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
elseif nargin == 1
    file = dir([path, '*']);
    
    for fileN = 3 : length(file)
        fileN
        nameMat = file(fileN).name;
        imFile = [path, nameMat, '\'];
        
        imDir = dir([imFile, '0*.jpg']);
        imDir(1).name
        
%         if ~strcmp(imDir(1).name, '000000.jpg')
            imNum = length(imDir);
            im = im2double(imread(strcat(imFile, sprintf('%06d', 1), '.jpg')));
            for i = 2 : imNum-1
                im = im + im2double(imread(strcat(imFile, sprintf('%06d', i), '.jpg')));
            end
            im = im./(imNum-1);
            
            % imwrite(im, [path, 'background.jpg'], 'jpg')
            imwrite(im, [imFile, '000000.jpg'], 'jpg')
%         end
    end
end


