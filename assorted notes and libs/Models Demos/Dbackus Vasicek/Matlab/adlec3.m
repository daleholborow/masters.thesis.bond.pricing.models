%******************************************************************************
%  adlec3.m
%  Lecture 3 of "Advanced fixed income analytics"
%  Subject:  "Binomial Models"
%  Backus and Zin, March 1999 and after
%******************************************************************************
clear
close all
format compact
format short

%  2. Ho-Lee
%
disp('************************************************')
disp('Eurodollar calculations with the Ho-Lee model')
h = 0.25;
pistar = 0.5;
% spot rates
F = [95.00 94.955 94.860 94.55 94.64 94.55 94.475];
d = 1./(1+(100-F)*h/100);
d = cumprod(d);
y = -(100/h)*log(d)./[1:length(d)]

model = 'hl';
mu = y;
sigma = 0.5*ones(size(d));

%model = 'bdt';
%mu = log(y);
%sigma = 0.15*ones(size(d));

now = cputime;
mu = fmins('calmu',mu,foptions,[],sigma,pistar,h,model,y)
etime = cputime - now

r = eval(['tree' model '(mu,sigma,h)']);
disp('Short rate tree')
flipud(r)
[spots,d,Q] = r2ybi(r,pistar,h);
disp('Spot rates (to check that they match)')
[spots; y]

b1 = triu(exp(-r*h/100));
disp('3-Month LIBOR')
Y = triu((100/h)*(1./b1 - 1));
flipud(Y)

% term structure of volatility
Ks = [5 5.25 5.5 5.25 5.5 5.5];
mats = [1:6];
vol = zeros(1,length(mats));
p   = zeros(1,length(mats));
for i = 1:length(mats)
    mat = mats(i);
%   K = Ks(i);
    K = 100-F(mat+1);
%   K = 5;
    cash = zeros(size(r));
    cash(:,mat+1) = Y(:,mat+1) - K;
    cash = cash.*(cash > 0);
%    flipud(cash)
    p(i) = sum(sum(cash.*Q));
    vol(i) = ivbs(K,100-F(mat),spots(mat)/100,mat*h,p(i),'C',0.2);
     [i,K,p(i),vol(i)]
end

voldata = [0.0687 0.1087 0.1502 0.1541 0.1628 0.1766];

figure(1)
plot(h*mats,voldata,'*',h*mats,vol,'o')
xlabel('Maturity in Years')
ylabel('Implied Volatility (Annual Percentage)')
text(.25,.17,'* = data, o = model')
print -dps adfig3p1.ps
pause(2)


% volatility smile
mat = 3;
Ks  = [4.5:0.125:6.5];
vol = zeros(1,length(Ks));
p   = zeros(1,length(Ks));
for i = 1:length(Ks)
    K = Ks(i);
    cash = zeros(size(r));
    cash(:,mat+1) = plusop(Y(:,mat+1) - K);

    p(i) = sum(sum(cash.*Q));

    volK = ivbs(K,100-F(mat+1),0.00,h*mat,p(i),'C',0.2);
    vol(i) = volK;
end

figure(2)
plot(Ks,vol,'o')
xlabel('Strike Price')
ylabel('Implied Volatility (Annual Percentage)')
print -dps adfig3p2.ps

return

%  1. Initial examples
%
disp('************************************************')
r = [5 4 6 2; 0 6 1 3; 0 0 9 6; 0 0 0 8];
[maxmat,n] = size(r);
h = 0.25;
pistar = 0.5;
disp('Rate tree')
flipud(r)

b1 = triu(exp(-r*h/100));
disp('Discount factor tree')
flipud(b1)

[spots,d,Q] = r2ybi(r,pistar,h);
disp('State prices')
flipud(Q)

disp('Example 1 (3-period zero)')
cash = zeros(maxmat,maxmat);
cash(:,maxmat) = 100*ones(maxmat,1);
flipud(cash)

zeropath = pathbi(b1,cash,pistar);
disp('Path for zero')
flipud(zeropath)

price = sum(Q(:,maxmat).*cash(:,maxmat))

disp('Example 2 (3-period 8% bond)')
cash = zeros(maxmat,maxmat);
cash(:,maxmat) = 100*ones(maxmat,1);
cash = triu(cash+2)
flipud(cash)

bondpath = pathbi(b1,cash,pistar);
disp('Path for bond')
flipud(bondpath)

price = sum(sum(Q.*cash))

disp('Example 3 (pure state-contingent claim)')
cash = zeros(maxmat,maxmat);
cash(3,3) = 1;
flipud(cash)

claimpath = pathbi(b1,cash,pistar);
disp('Path for state-contingent claim')
flipud(claimpath)

price = sum(sum(Q.*cash))

return

