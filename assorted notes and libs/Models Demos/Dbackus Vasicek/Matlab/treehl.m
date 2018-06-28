function [r] = treehl(mu,sigma,h)
%  function [value] = treehl(mu,sigma,h)
%  Generates interest rate tree for Ho and Lee model
%  Parameters:
%	mu       (cumulative) drift parameters (mu1 = r00)
% 	sigma    vector of volatilities (annualized)
% 	h        length of a period in years (0.5 for semiannual)
%	r 	 short rate tree (upper triangular)
%  Backus and Zin, March 1999 and after.
%
maxmat = length(mu);
cummu = mu;
sigmah = sigma*sqrt(h);

r = zeros(maxmat,maxmat);
r(1,1) = mu(1);
for t = 2:maxmat
    for i = 1:t
        r(i,t) = cummu(t) + (2*i-t-1)*sigmah(t-1);
    end
end

