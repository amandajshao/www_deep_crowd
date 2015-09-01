function [XVset] = trk2XV(trks, interval, length_threshold, tLen)
%TRK2XV to transform trk series into point set
%    trks:                trajectory series from gKLT tracker
%    interval:            the interval between trajectory series
%    length_threshold:    keep trajectories with large length
%    
%    XVset: the point set: 1-2 column, XY; 3-4 column, V_xV_y, 5: time; 6: index
% 
%    Mar.28 2013, Bolei Zhou

XVset = [];
for i = 1:length(trks)
    curTrk=trks(i);
    if curTrk.t(1) > tLen
        continue;
    end
    if length(curTrk.x) > length_threshold
        curX1 = curTrk.x(1:interval:end);
        curX2 = curTrk.y(1:interval:end);
        curT = curTrk.t(1:interval:end);
        curX = [curX1(1:end-1) curX2(1:end-1)];
        curV = [curX1(2:end)-curX1(1:end-1) curX2(2:end)-curX2(1:end-1)];      
        curXV = [curX curV curT(1:end-1) ones(size(curX,1),1)*i];
        XVset = [XVset;curXV];
    end    
end

end