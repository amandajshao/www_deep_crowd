function [nextX,nextVelocityDegree]=SDP_updateXwithOutlier(curX,curVelocityDegree,Xlabel,para)
correlationMatrix=repmat(curVelocityDegree,[1, size(curX,1)])';

distanceMatrix=slmetric_pw(curX',curX','eucdist');
neighborMatrix=distanceMatrix<=para.R;
nNeighbor=sum(neighborMatrix,2);
nextVelocityDegreeSet=correlationMatrix.*neighborMatrix;


nextVelocityDegree=curVelocityDegree;
for i=1:size(distanceMatrix,1)
    curNeighborIndex=find(nextVelocityDegreeSet(i,:)~=0);
    curCosAverage=sum(cos(nextVelocityDegreeSet(i,curNeighborIndex)))/nNeighbor(i);
    curSinAverage=sum(sin(nextVelocityDegreeSet(i,curNeighborIndex)))/nNeighbor(i);
    nextVelocityDegree(i)=atan2(curSinAverage,curCosAverage);
end

%%
velocityDegree_noise=pi*para.noise*(-1+2*rand([para.nPoint,1])); %% adding noise
outlierIndex=find(Xlabel==-1);
nextVelocityDegree(outlierIndex)=curVelocityDegree(outlierIndex);
nextVelocityDegree=nextVelocityDegree+velocityDegree_noise;
incrementX=[para.velocity*cos(nextVelocityDegree) para.velocity*sin(nextVelocityDegree)];
nextX=curX+incrementX;
nextX=mod(nextX,para.L);

end

