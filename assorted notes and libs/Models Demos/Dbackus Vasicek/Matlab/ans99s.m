%******************************************************************************
%  ans99s.m
%  Answer to assignments for "Advanced fixed income analytics"
%  Backus and Zin, March 1999 and after
%******************************************************************************
clear
close all
format compact
format long

%  Assignment 1
disp('******************************************************************')
disp('Assignment 4 (BDT/caps)')
h = 0.25;
pistar = 0.5;
% spot rates
F = [95.00 94.96 94.86 94.53 94.64 94.55 94.48 94.35];
d = 1./(1+(100-F)*h/100);
d = cumprod(d);

% convert to semi
d = reshape(d,2,length(d)/2)';
d = d(:,2)'
h = 0.5;
y = -(100/h)*log(d)./[1:length(d)]

%model = 'hl';
%mu = y;
%sigma = 0.5*ones(size(d));

model = 'bdt';
mu = log(y);
sigma = [0.1 0.12 0.13 0.14];

now = cputime;
mu = fmins('calmu',mu,foptions,[],sigma,pistar,h,model,y)
etime = cputime - now

r = eval(['tree' model '(mu,sigma,h)']);
disp('Rate tree')
flipud(r)
[spots,d,Q] = r2ybi(r,pistar,h);
disp('Spot rates')
[spots; y]

b1 = triu(exp(-r*h/100));
Y = triu((100/h)*(1./b1 - 1));
disp('6-Month LIBOR')
flipud(Y)

% interest rate cap
K = 5.37;
cash = plusop((Y-K).*b1);
cash(1,1) = 0;
cash(:,4) = zeros(4,1);
disp('Cash flow')
flipud(cash)
price = sum(sum(cash.*Q))

return


% term structure
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

return

%  Assignment 1
disp('******************************************************************')
disp('Problem 1 (calibration to DM rates')

%  Load DM rates
%  data (19 cols):  1=date, 2=overnight, 3=1 wk, 4=2 wk, 5=3 wk,
%    6=1 mo, 7=2 mo, 8=3 mo, 9=4 mo, 10=5 mo, 11=6 mo, 12 = 9 mo,
%    13=1 yr, 14=2 yr, 15=3 yr, 16=4 yr, 17=5 yr, 18=7 yr, 19=10yr
load dmr.txt
[nobs,nvar] = size(dmr);
dates = dmr(:,1);
dmr = dmr([1:22:nobs-1],[6 13:19]);     % monthly subset
[nobs,nvar] = size(dmr);
mats = [1/250 1/52 2/52 3/52 1/12 2/12 3/12 4/12 5/12 6/12 9/12 1 ...
	2 3 4 5 7 10];
mats = [1 12 24 36 48 60 84 120]';
dmr(:,1) = -1200*log(1./(1+dmr(:,1)/1200));
dmr(:,2) = -100*log(1./(1+dmr(:,2)/100));

ybar = mean(dmr);
momy = moments(dmr);
rhoy = acf(dmr,1);
tab1 = zeros(nvar,6);
tab1(:,1) = mats;
tab1(:,2:5) = momy';
tab1(:,6) = rhoy';

disp('Properties of spot rates')
tab1
%figure(1)
%plot(mats([1 3 4 6 8]),ybar([1 3 4 6 8]),'*')

%  Vasicek calibration
mat = 120; imat = [1:mat]';
mur = 3.503/1200;
sigmar = .437/1200;
rhor = 0.920;

theta = mur
phi = rhor
sigma = sqrt(1-phi^2)*sigmar

lambda = -1.50;
delta = lambda^2/2;
A = [0:mat]'; B = [0:mat]';
for nmat = 1:mat;
    A(nmat+1) = A(nmat) + delta + B(nmat)*(1-phi)*theta ...
                                - (lambda + B(nmat)*sigma)^2/2;
    B(nmat+1) = 1 + B(nmat)*phi;
end
A = A(2:mat+1);
B = B(2:mat+1);
bbar = exp(- A - B*theta);
yvas = 1200*(A + B*theta)./imat;

%swap rates
b6 = reshape(bbar',6,mat/6)';
b6 = b6(:,6);
swap = 200*(1-b6)./cumsum(b6);
swap = [NaN*zeros(mat/6,5) swap];
swap = reshape(swap',mat,1);

figure(1)
plot(mats([1 3 4 6 8]),ybar([1 3 4 6 8]),'*',imat,yvas,'-',imat,swap,'o')
xlabel('Maturity in Months')
ylabel('Mean Yield (Annual Percentage)')
print -dps ans1p1.ps

disp('******************************************************************')
disp('Problem 2 (calibration to long rate')
%  Load Fama-Bliss yield data
%  data:  first column is date, maturities are:
%    y1 y2 y3 y4 y6 y7 y9 y10 y12 y13 y24 y25 y36 y37 y48 y49           $
%    2  3  4  5  6  7  8  9   10  11  12  13  14  15  16  17            $
%    y60 y61 y84 y85 y120 y121  (22 in all)
%    18  19  20  21  22   23
dates = [1970+1/12:1/12:1996]';
mats = [1 3 6 9 12 24 36 48 60 84 120]';
size(dates);
load sfb2.yld
yields = sfb2(:,[2 4 6 8 10 12 14 16 18 20 22]);
[nobs,nvar] = size(yields);
ybar = mean(yields);
ystd = std(yields);
% calibration
mat = 120; imat = [1:mat]';

phi = 0.978
B60 = (1-phi^60)/(1-phi)
sigma = (2.221/1200)*(60/B60)*sqrt(1-phi^2)
theta = 7.480/1200
lambda = -0.055

delta = lambda^2/2;
A = [0:mat]'; B = [0:mat]';
for nmat = 1:mat;
    A(nmat+1) = A(nmat) + delta + B(nmat)*(1-phi)*theta ...
                                - (lambda + B(nmat)*sigma)^2/2;
    B(nmat+1) = 1 + B(nmat)*phi;
end
A = A(2:mat+1);
B = B(2:mat+1);
yvas = 1200*(A + B*theta)./imat;

figure(2)
plot(mats,ybar,'*',imat,yvas,'-')
xlabel('Maturity in Months')
ylabel('Mean Yield (Annual Percentage)')

% variance vs maturity
varznew = 1200*B*(sigma/sqrt(1-phi^2))./imat;
phi = 0.959;
sigma = (2.699/1200)*sqrt(1-phi^2)
theta = 6.683/1200
lambda = -0.1308
delta = lambda^2/2;
A = [0:mat]'; B = [0:mat]';
for nmat = 1:mat;
    A(nmat+1) = A(nmat) + delta + B(nmat)*(1-phi)*theta ...
                        - (lambda + B(nmat)*sigma)^2/2;
    B(nmat+1) = 1 + B(nmat)*phi;
end
A = A(2:mat+1);
B = B(2:mat+1);
varzold = 1200*B*(sigma/sqrt(1-phi^2))./imat;

figure(3)
plot(mats,ystd,'*',imat,varznew,'--',imat,varzold,'-')
ylabel('Standard Deviation of Spot Rate')
xlabel('Maturity in Months')
print -dps ans1p2.ps

return

