function [value] = calmu(mu,sigma,pistar,h,model,y)
%  function [value] = calmu(mu,sigma,pistar,h,model,y)
%  Calibrates drift parameters mu to hit current spot rates y
%  Parameters:
%	mu       (cumulative) drift parameters (mu1 = r00)
% 	sigma    vector of volatilities (annualized)
% 	pistar   risk-neutral prob of up
% 	h        length of a period in years (eg, 0.5 for semiannual)
%	model 	 choice of:  hl, bdt, ss
%       y	 spot rates in data (continuously compounded %)
%  Backus and Zin, March 1999 and after.
%
maxmat = length(mu);

r = eval(['tree' model '(mu,sigma,h)']);
spots = r2ybi(r,pistar,h);

rho = 8;
error = y-spots;
error = (abs(error).^rho).^(1/rho);

value = sum(error.^2); 

end 
