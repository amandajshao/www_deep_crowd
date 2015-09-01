function trk_new = fun_smooth_trk(trk, smooth_th)

trk_new = trk;
for i = 1 : length(trk)
    for j = floor(smooth_th/2)+1 : length(trk(i).x)-floor(smooth_th/2)
        trk_new(i).x(j) = round(mean(trk(i).x(j-floor(smooth_th/2):j+floor(smooth_th/2))));
        trk_new(i).y(j) = round(mean(trk(i).y(j-floor(smooth_th/2):j+floor(smooth_th/2))));
    end
end
