function [value] = ivbs(X,F,r,n,opprice,optype,vol0)
%  function [value] = ivbs(X,F,r,n,opprice,optype,vol0)
%  Black-Scholes implied volatility (partner function to opbs.m)
%  (vectorized, dim=length(X), other inputs assumed scalars)
%  Parameters:
%	F        forward price of underlying
% 	X 	 strike price
%	r 	 interest rate [bn = exp(-r*n)]
% 	n	 maturity of option
%	opprice  option price
%	optype   option type ('C' or 'P')
%       vol0     initial value for volatility (optional)
%  Uses Newton's method.
%  Backus, Wu, and Zin, March 1999 and after.
tol = 1.e-5;
maxit = 50;

if nargin < 7
    vol = 0.2*ones(size(X));
  else
    vol = vol0;
end

dim = length(X);
if dim > 1
    if length(X)==1
        F = F*ones(size(X));
    end
    if length(r)==1
        r = r*ones(size(X));
    end
    if length(n)==1
        n = n*ones(size(X));
    end
    if length(opprice)==1
        opprice = opprice*ones(size(X));
    end
    if length(vol0)==1
        vol0 = vol0*ones(size(X));
    end
    if length(optype)==1
        optype = setstr(optype*ones(size(X)));
    end
end
calldum = optype == 'C';	% convert to dummy (1 for call)

bn = exp(-r.*n);
bnf  = bn.*F;
bnfx = bn.*(F-X);
put2call = opprice + bnfx;      % convert to call
opprice = calldum.*opprice + (1-calldum).*put2call;

call = opbs(X,F,r,n,vol,'C');
for it = 1:maxit
    sigman = vol.*sqrt(n);
    d = (log(F./X)+sigman.^2/2)./sigman;
    f = call - opprice;                         % function
    fp = bn.*F.*sqrt(n/(2*pi)).*exp(-d.^2/2);   % derivative (vega)
    volnew = vol - f./fp;
    callnew = opbs(X,F,r,n,volnew,'C');
    if max(abs(volnew-vol)) < tol, break, it, end
    if max(abs(callnew-call)) < tol, break, it, end
    volold = vol; callold = call;
    vol = volnew; call = callnew;
    if i == maxit
        disp('Possible nonconvergence of implied volatility')
        disp('Call prices (true and estimated)')
        [opprice; opbs(X,F,r,n,vol,'C')]
    end
end

%  check for violation of arbitrage...

bnfx = bnfx.*(bnfx >= 0);
for i=1:length(X)
    call = opprice(i);
    callmin = bnfx(i);
    callmax = bnf(i);
    if call >= callmax
        vol(i) = NaN;
    end
    if call <= callmin
        vol(i) = 0;
    end
end

value = vol;

end
