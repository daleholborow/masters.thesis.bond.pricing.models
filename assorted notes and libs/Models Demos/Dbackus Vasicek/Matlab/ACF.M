function [rho]=acf(data,nrho)
%  function [rho]=acf(data,nrho)
%  Autocorrelation function for matrix data (each column is a variable)
%  Updated:  Dec 29, 1998
[nobs,nvar] = size(data);

xbar = mean(data);
x = data - xbar([ones(1,nobs)],:);
gamma0 = sum(x.*x);
rho = zeros(nrho,nvar);
for k = 1:nrho;
    lags = zeros(nobs,nvar);
    lags(k+1:nobs,:) = x(1:nobs-k,:);
    rho(k,:) = sum(lags.*x)./gamma0;
end

return

