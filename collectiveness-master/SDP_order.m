function order_system = SDP_order(curV)
%SPP_ORDER to compute the average velocity as the system order of particles

velocityValue = sqrt(sum(curV.^2,2));
curV_normalized = curV./(repmat(velocityValue,[1,2])+eps);
order_system = sum(curV_normalized,1)./size(curV,1);
order_system = sqrt(order_system(1)^2+order_system(2)^2);

end

