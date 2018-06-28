function [r] = treebdt(mu,sigma,h)
%  function [value] = treebdt(mu,sigma,h)
%  Generates interest rate tree for Black-Derman-Toy model
%  Parameters:
%	mu       (cumulative) drift parameters (mu1 = log(r00))
% 	sigma    vector of volatilities (annualized)
% 	h        length of a period in years (0.5 for semiannual)
%	r 	 short rate tree (upper triangular)
%  Backus and Zin, March 1999 and after.
maxmat = length(mu);
cummu = mu;
sigmah = sigma*sqrt(h);

r = zeros(maxmat,maxmat);
%  generate log of tree, then exponentiate
r(1,1) = mu(1);
for t = 2:maxmat
    for i = 1:t
        r(i,t) = cummu(t) + (2*i-t-1)*sigmah(t-1);
    end
end
r = triu(exp(r));

end 