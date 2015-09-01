function clusterLabelEachtime = CFunifyClusterEachtime(trkTimeLine,trkClusterTimeLine)
%CFUNIFYCLUSTER associating clusters over time

trkLabel=zeros(size(trkClusterTimeLine,1),1);
maxLabelValue=0;
% clusterLabelEachtime=zeros(size(trkTimeLine,1),size(trkTimeLine,2));
clusterLabelEachtime=uint8(zeros(size(trkClusterTimeLine,1),size(trkClusterTimeLine,2)));

for i=1:size(trkClusterTimeLine,2)
    curCluster=trkClusterTimeLine(:,i);

        for k=1:max(curCluster)
            curSingleCluster=find(curCluster==k);
            ClusterValue=mode(trkLabel(curSingleCluster));
            if (ClusterValue==0)
                maxLabelValue=maxLabelValue+1;
                trkLabel(curSingleCluster)=maxLabelValue;
            else
                trkLabel(curSingleCluster)=ClusterValue;
            end
        end
        
    clusterLabelEachtime(:,i)=trkLabel;    
end

end

