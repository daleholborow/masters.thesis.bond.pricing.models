%******************************************************************************
%  adlec1.m
%  Lecture 1 of "Advanced fixed income analytics"
%  Subject:  "Intro and Vasicek"
%  Backus and Zin, March 1999 and after
%******************************************************************************
clear
close all
format compact
format long

%  0. Load Fama-Bliss yield data
%
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
%dlmwrite('spots.txt',[mats';yields],',')

%  1. Moments
%
ybar = mean(yields);
momy = moments(yields);
rhoy = acf(yields,1);
tab1 = zeros(nvar,6);
tab1(:,1) = mats;
tab1(:,2:5) = momy';
tab1(:,6) = rhoy';

disp('Properties of spot rates')
tab1

%  2. Vasicek calibration
%
mat = 120; imat = [1:mat]';

mur = tab1(1,2)/1200;
sigmar = tab1(1,3)/1200;
rhor = tab1(1,6);
% truncate digits to fit notes
mur = 6.683/1200;
sigmar = 2.699/1200;
rhor = 0.959;

theta = mur
phi = rhor
sigma = sqrt(1-phi^2)*sigmar

lambda = 0;
delta = lambda^2/2;
A = [0:mat]'; B = [0:mat]';
for nmat = 1:mat;
    A(nmat+1) = A(nmat) + delta + B(nmat)*(1-phi)*theta ...
                                - (lambda + B(nmat)*sigma)^2/2;
    B(nmat+1) = 1 + B(nmat)*phi;
end
A = A(2:mat+1);
B = B(2:mat+1);
ylam0 = 1200*(A + B*theta)./imat;

lambda = 0.10; 
delta = lambda^2/2;
A = [0:mat]'; B = [0:mat]';
for nmat = 1:mat;
    A(nmat+1) = A(nmat) + delta + B(nmat)*(1-phi)*theta ...
                                - (lambda + B(nmat)*sigma)^2/2;
    B(nmat+1) = 1 + B(nmat)*phi;
end
A = A(2:mat+1);
B = B(2:mat+1);
ylampos = 1200*(A + B*theta)./imat;

lambda = -0.13077; 
delta = lambda^2/2;
A = [0:mat]'; B = [0:mat]';
for nmat = 1:mat;
    A(nmat+1) = A(nmat) + delta + B(nmat)*(1-phi)*theta ...
                                - (lambda + B(nmat)*sigma)^2/2;
    B(nmat+1) = 1 + B(nmat)*phi;
end
A = A(2:mat+1);
B = B(2:mat+1);
ylamneg = 1200*(A + B*theta)./imat;
disp('y120 in data and theory + lambda')
[ybar(11),ylamneg(120),lambda]

figure(1)
plot(mats,ybar,'*',imat,ylam0,'-',imat,ylampos,'--',imat,ylamneg,'-.')
xlabel('Maturity in Months')
ylabel('Mean Yield (Annual Percentage)')
text(70,8.0,'lambda < 0') 
text(70,5.5,'lambda > 0')
text(70,6.8,'lambda = 0')
print -dps adfig1p1.ps

%  3. Hedging  
%
hrdur = 60./imat;
hrvas = B(60)./B;

figure(2)
semilogy(imat,hrdur,'-',imat,hrvas,'--') 
xlabel('Maturity of Hedge Position in Months')
ylabel('Hedge Ratio (Abs Value, Log Scale)')
text(20,5,'Duration-based')
text(80,1.3,'Vasicek-based')
%print -dps adfig1p2.ps

matmat = mats(:,[ones(nobs,1)])';
Bn = B([mats]);
%Bn = Bn(:,[ones(nobs,1)]);
bn = exp(-matmat.*yields/1200);
b60 = bn(:,9);
Db60 = b60(2:nobs) - b60(1:nobs-1);
x60 = 100./b60;
x60 = x60(1:nobs-1);

disp('Unhedged mean and std of 5-year zeros')
[mean(x60.*Db60) std(x60.*Db60)]
disp('Mean and std for maturity i')
tab = zeros(length(mats),3);
for i = 1:length(mats)
    Bi = Bn(i);
    bi = bn(:,i);
% vasicek
    Dbi = bi(2:nobs) - bi(1:nobs-1);
    xi = -(100*Bn(9)/Bi)./bi(1:nobs-1);
    Dv = x60.*Db60 + xi.*Dbi;
    tab(i,1) = mats(i);
    tab(i,3) = std(Dv);
% duration
    xi = -(100*mats(9)/mats(i))./bi(1:nobs-1);
    Dv = x60.*Db60 + xi.*Dbi;
    tab(i,2) = std(Dv);
end

disp('Maturity and std of return for dur and vas hedges')
tab

dz = [-2:1:2];
b24 = exp(-A(24)-B(24)*theta);
db24 = exp(-A(24)-B(24)*(theta+dz/1200)) - b24;
b60 = exp(-A(60)-B(60)*theta);
db60 = exp(-A(60)-B(60)*(theta+dz/1200)) - b60;

x60 = 100./b60;
x24dur = -100*60/(24*b24)
x24vas = -100*B(60)/(B(24)*b24)

dvvas = x24vas*db24 + x60*db60;
dvdur = x24dur*db24 + x60*db60;

figure(3)
plot(dz,dvvas,'-',dz,dvdur,'--') 
xlabel('Change in z (x 1200)')
ylabel('Profit/Loss on Hedged Position')
text(-0.7,-1.2,'Duration-based hedge')
text(-1.5,0.3,'Vasicek-based hedge')
print -dps adfig1p2.ps


return

