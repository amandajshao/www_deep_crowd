clear

addpath('util\');

%% parameters of Self-Driven Particles
SDPpara.nPoint = 400;         %number of particles
SDPpara.L = 7;                %size of the ground 
SDPpara.R = 1;                %size of the interaction radius
SDPpara.noise = 0.00;         %random perturbation
SDPpara.velocity = 0.03;      %velocity value
SDPpara.outlierRatio = 0.2;     %outlier ratio

%% parameters of collectiveness measurement
para.K = 20;
para.z = 0.5/para.K ;
para.upperBound = para.K*para.z/(1-para.K*para.z);
para.threshold = 0.4*para.z/(1-para.K*para.z);

%% initilize the self-driven particles
[curX,curVelocityDegree,XLabel,SDPpara] = SDP_initialXwithNoise(SDPpara);
keyDotIndex = find(XLabel==1);      % the index of self-driven particles
outlierIndex = find(XLabel==-1);    % the index of randomly moving points
%% begin iteration
figure
while 1
    [nextX,nextVelocityDegree] = SDP_updateXwithOutlier(curX,curVelocityDegree,XLabel,SDPpara); % update SDP model
    curVelocityDegree = nextVelocityDegree;
    curX = nextX;
    curV = [cos(curVelocityDegree) sin(curVelocityDegree)];
    order_system = SDP_order(curV); % compute the average velocty 
    [collectivenessSet, crowdCollectiveness] = measureCollectiveness( curX, curV, para); % compute collectiveness
    subplot(1,2,1),
    hold off
    scatter(curX(keyDotIndex,1),curX(keyDotIndex,2),'b'),hold on
    scatter(curX(outlierIndex,1),curX(outlierIndex,2),'r'),hold on
    quiver(curX(keyDotIndex,1),curX(keyDotIndex,2),curV(keyDotIndex,1),curV(keyDotIndex,2),'b');
    xlim([0 SDPpara.L])
    ylim([0 SDPpara.L])
    title(['System Order=' num2str(order_system) ', Collectiveness=' num2str(crowdCollectiveness)]);
    drawnow
    subplot(1,2,2),hist(collectivenessSet,20) 
    title('Histogram of Individual Collectiveness');
end

