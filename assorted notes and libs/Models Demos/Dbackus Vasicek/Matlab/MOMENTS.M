function [mom]=moments(data)
%  function [mom]=moments(data)
%  Moments for matrix data (each column is a variable)
[nobs,nvar] = size(data);
mom = zeros(4,nvar);

xbar = mean(data);
x = data - xbar([ones(1,nobs)],:);
mu2 = mean(x.^2);
mu3 = mean(x.^3);
mu4 = mean(x.^4);
mom(1,:) = xbar;
mom(2,:) = sqrt(mu2);
mom(3,:) = mu3./mu2.^1.5;
mom(4,:) = mu4./mu2.^2 - 3;

return
