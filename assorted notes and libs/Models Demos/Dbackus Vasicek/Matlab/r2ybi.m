function [y,d,Q] = r2y(r,pistar,h)
%  function [y,d,Q] = r2y(r,pistar,h)
%  Generates spot rates and discount factors from short rate tree
%  (uses continuous compounding)
%  Parameters:
%	r 	 short rate tree (upper triangular)
% 	h        length of a period in years (0.5 for semiannual)
%	y 	 spot rates (vector)
%	d 	 discount factors (vector)
%	y 	 spot rates (vector)
%       Q        state price tree
%  Backus and Zin, March 1999 and after.
[maxmat,n] = size(r);

dtree = triu(exp(-r*h/100));
Q = d2qbi(dtree,pistar);
d = sum(Q);
d = [d(2:maxmat) sum(Q(:,maxmat).*dtree(:,maxmat))];
y = -(100/h).*log(d)./[1:maxmat];

end