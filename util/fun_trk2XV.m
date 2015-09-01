function [allXset,allVset] = fun_trk2XV(trks,curTime,d,interval)
% Function: compute displacement and velocity of a trajectory "trks" every "d" frames from current
%           time "curTime" to end time "curTime+interval".
% if nargin is 3, it means from "curTime" to "curTime+d"

if nargin == 3
    allXset=cell(1,d);
    allVset=cell(1,d);
    
    for i=1:d
        allXset{1,i}=[];
        allVset{1,i}=[];
    end
    
    for i=1:length(trks)
        curStart=trks(i).t(1);curEnd=trks(i).t(end);
        if curTime>curStart && curEnd>=(curTime+d) && length(trks(i).x)>=(curTime+d-curStart)
            curX=[trks(i).x((curTime-curStart):(curTime-curStart)+d-1)';trks(i).y((curTime-curStart):(curTime-curStart)+d-1)'];
            curV=[trks(i).x((curTime-curStart)+1:(curTime-curStart)+d)' - trks(i).x((curTime-curStart):(curTime-curStart)+d-1)';...
                trks(i).y((curTime-curStart)+1:(curTime-curStart)+d)' - trks(i).y((curTime-curStart):(curTime-curStart)+d-1)'];
            for j=1:d
                curX_temp = [curX(:,j); i];
                allXset{1,j}=[allXset{1,j},curX_temp];
                allVset{1,j}=[allVset{1,j},curV(:,j)];
            end
            
        end
    end
    
elseif nargin == 4
    allXset=cell(1,d);
    allVset=cell(1,d);
    
    for i=1:d
        allXset{1,i}=[];
        allVset{1,i}=[];
    end
    
    for i=1:length(trks)
        curStart=trks(i).t(1);curEnd=trks(i).t(end);
        if curTime>curStart && curEnd>=(curTime+interval) && length(trks(i).x)>=(curTime+interval-curStart)
            curX=[trks(i).x((curTime-curStart):(curTime-curStart)+d-1)';trks(i).y((curTime-curStart):(curTime-curStart)+d-1)'];
            curV=[trks(i).x((curTime-curStart)+interval:(curTime-curStart)+interval)' - trks(i).x((curTime-curStart):(curTime-curStart))';...
                trks(i).y((curTime-curStart)+interval:(curTime-curStart)+interval)' - trks(i).y((curTime-curStart):(curTime-curStart))'];
            curV = curV./(sqrt(sum(curV.^2))+eps);
            for j=1:d
                curX_temp = [curX(:,j); i];
                allXset{1,j}=[allXset{1,j},curX_temp];
                allVset{1,j}=[allVset{1,j},curV];
%                 allVset{1,j}=[allVset{1,j},curV(:,j)];
            end
            
        end
    end
    
end

end

