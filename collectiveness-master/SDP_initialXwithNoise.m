function [curX,curVelocityDegree,Label,newpara] = SDP_initialXwithNoise(para)
%SPP_INITIALX to initilize the spatial locations and velocities of particles
% 
% 
nOutlier=round(para.outlierRatio*para.nPoint);
para.nPoint=para.nPoint+nOutlier;
p=randperm(para.nPoint);
Label=ones(1,para.nPoint);
Label(1,p(1:nOutlier))=-1;
oldX=[para.L*[rand([para.nPoint,1])] para.L*[rand([para.nPoint,1])]];
velocityDegree=pi*(-1+2*rand([para.nPoint,1]));
incrementX=[para.velocity*cos(velocityDegree) para.velocity*sin(velocityDegree)];
curX=oldX+incrementX;
z=incrementX(:,1)+1i*incrementX(:,2);
curVelocityDegree=angle(z);
newpara=para;

end

