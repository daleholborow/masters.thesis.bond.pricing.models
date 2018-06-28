%******************************************************************************
%  adlec4.m
%  Lecture 4 of "Advanced fixed income analytics"
%  Subject:  "Binomial Models 2"
%  Backus and Zin, March 1999 and after
%******************************************************************************
clear
close all
format compact
format short

disp('******************************************************************')
%  1. compute spot rates
%
disp('Interest rates')
pistar = 0.5;
h = 0.25;
% compute spot rates (y) and discount factors (d)
% from eurodollar futures prices (F)
F = [95.00 94.96 94.86 94.53 94.64 94.55 94.48 94.35 94.34 94.31 94.28 94.22];
d = 1./(1+(100-F)*h/100);
d = cumprod(d);

% convert to semiannual
d = reshape(d,2,length(d)/2)';
d = d(:,2)';
h = 0.5;
y = -(100/h)*log(d)./[1:length(d)];
f = (100/h)*([1 d(1:length(d)-1)]./d-1);
swap = (100/h)*(1-d)./cumsum(d);
disp('d y f swap')
[d' y' f' swap']

disp('forward starting swap rate')
cumd = cumsum(d);
fswap = (100/h)*(d(2)-d(6))/(cumd(6)-cumd(2))

%  2. Black-Scholes caplet calculations
%
% caplets
vol = [12.5 15.00 16.5 17 17.5]/100;    %  these are made up
K = 5.50;
caplet = zeros(size(vol));
for j = 1:length(vol)
    vj = vol(j)*sqrt(h*j);
    dcap = (log(f(j+1)/K)+vj^2/2)/vj;
    caplet(j) = h*d(j+1)*(f(j+1)*cdfnor(dcap)-K*cdfnor(dcap-vj));
end
disp('******************************************************************')
disp('Cap and caplet calculations')
disp('vol caplet cap')
[vol' caplet' cumsum(caplet)']

%  3. BDT calculations
%
disp('******************************************************************')
disp('BDT calculations')
model = 'bdt';
mu = log(y);                            % use current spots for initial value
sigma = [vol 17.5];                     % add one more number to vol vector

% "fmins" finds the mu parameters that match current spot rates y
now = cputime;
mu = fmins('calmu',mu,foptions,[],sigma,pistar,h,model,y);
disp('computation time')
etime = cputime - now

% various trees
r = eval(['tree' model '(mu,sigma,h)']);
disp('Short rate tree')
flipud(r)
[spots,d,Q] = r2ybi(r,pistar,h);
disp('Spot rates (to check that they match)')
[spots; y]
disp('State prices')
flipud(Q)

b1 = triu(exp(-r*h/100));
Y = triu((100/h)*(1./b1 - 1));
disp('6-Month LIBOR tree')
flipud(Y)

% interest rate cap
K = 5.50;
cash = 0.5*plusop((Y-K).*b1);
cash(1,1) = 0;
cash(:,5) = zeros(6,1);
cash(:,6) = zeros(6,1);
disp('Cash flows for 2-year cap')
flipud(cash)

disp('Price of cap')
price = sum(sum(cash.*Q))

return

