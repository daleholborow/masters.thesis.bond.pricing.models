function value = cdfnor(x)
%  Computes cumulative normal distribution function using
%  Matlab's error function.

value = 0.5*(erf(x/sqrt(2))+1);

return
