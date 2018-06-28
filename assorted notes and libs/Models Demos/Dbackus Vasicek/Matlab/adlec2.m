%******************************************************************************
%  adlec2.m
%  Lecture 2 of "Advanced fixed income analytics"
%  Subject:  "Introduction to options"
%  Backus and Zin, March 1999 and after
%******************************************************************************
clear
close all
format compact
format short

%  0. tests of procedures
%
disp('Test:  call prices and implied vols')
X = [.8:.2:1.2];
%X = .8;
F = 1;
r = 0;
n = 0.50;
sigma = .55;

call = opbs(X,F,r,n,sigma,'C');
disp('Call prices (strikes)')
[call; X]

vol = ivbs(X,F,r,n,call,0,'C');
disp('Implied vols (strikes)')
[vol; X]

disp('Example for notes')
S = 100
X = 97.5
r = 0.05
n = 1
b = exp(-r*n)
F = 95
sigma = 0.173

disp('Call price and vol')
call = opbs(X,F,r,n,sigma,'C')
vol = ivbs(X,F,r,n,call,'C')
disp('Brenner-Subrahmanyam approximation')
volbrsubi = call*sqrt(2*pi)/(b*F*sqrt(n))

disp('Put (from parity condition)')
put = call - b*(F-X)
vol = ivbs(X,F,r,n,put,'P')

disp('ATM call')
callatm = opbs(F,F,r,n,sigma,'C')
vol = ivbs(X,F,r,n,callatm,'C')

%  2. Eurodollar futures
%
disp('Eurodollar futures (quotes for 3-16-99)')
disp('Jun 99')
disp('***********************')
r = 0.05;  %4*log(1+0.05/4);
n = 0.25;
b = exp(-n*r)
F = 94.955

disp('Example for notes')
call = 0.0425 + b*((100-F)-(100-95))
volatmp = ivbs(5.00,5.045,r,n,0.0869,'C',0.2)
disp(' ')

Xputs = [94.5 94.63 94.75 94.88 95];
puts = [0.0075 0.015 0.0225 0.0375 0.0925];
volputs = ivbs(100-Xputs,100-F,r,n,puts,'C',0.2);
disp('Implied vol (puts)')
[volputs; puts; Xputs]

Xcalls = [94.75 94.88 95 95.13 95.25 95.38 95.5];
calls = [0.2225 0.1125 0.0425 0.0225 0.0125 0.0075 0.0075];
volcalls = ivbs(100-Xcalls,100-F,r,n,calls,'P',0.2);
disp('Implied vol (calls)')
[volcalls; calls; Xcalls]

figure(1)
plot(Xputs,100*volputs,'o',Xcalls,100*volcalls,'*')
xlabel('Moneyness: X')
ylabel('Implied Volatility (Annual Percentage)')
print -dps figans2.ps
return

%
disp('Sep 99')
disp('***********************')
r = 0.05;  %2*log(1+(0.05+5.045)/4)
n = 0.50;
F = 94.86

Xputs = [94 94.25 94.50 94.75 95];
puts = [0.0125 0.0275 0.05 0.1075 0.2225];
volputs = ivbs(100-Xputs,100-F,r,n,puts,'C',0.2);
disp('Implied vol (puts)')
[volputs; puts; Xputs]

Xcalls = [94.5 94.75 95 95.25 95.5 95.75];
calls = [0.405 0.2125 0.0875 0.0475 0.0275 0.0125];
volcalls = ivbs(100-Xcalls,100-F,r,n,calls,'P',0.2);
disp('Implied vol (calls)')
[volcalls; calls; Xcalls]

figure(2)
plot(Xputs,100*volputs,'o',Xcalls,100*volcalls,'*')
xlabel('Moneyness: X')
ylabel('Implied Volatility (Annual Percentage)')

%
disp('Dec 99')
disp('***********************')
r = 0.05;  % 4*log(1+(0.05+5.045+5.14)/4)
n = 0.75;
F = 94.55

Xputs = [93.5 93.75 94 94.25 94.50 94.75]; 
puts = [0.04 0.0625 0.1025 0.16 0.25 0.375];
volputs = ivbs(100-Xputs,100-F,r,n,puts,'C',0.2);
disp('Implied vol (puts)')
[volputs; puts; Xputs]

Xcalls = [95 95.25 95.5 95.75];
calls = [0.1025 0.055 0.0375 0.0275];
volcalls = ivbs(100-Xcalls,100-F,r,n,calls,'P',0.2);
disp('Implied vol (calls)')
[volcalls; calls; Xcalls]  

figure(3)
plot(Xputs,100*volputs,'o',Xcalls,100*volcalls,'*')
xlabel('Moneyness: X')
ylabel('Implied Volatility (Annual Percentage)')

%
disp('Mar 00')
disp('***********************')
% (use "last" for this one) 
r = 0.05;  % 4*log(1+(0.05+5.045+5.14)/4)
n = 1.00;
F = 94.64

Xputs = [93.25 93.5 93.75 94 94.25 94.50 94.75 95]; 
puts = [0.025 0.04 0.065 .105 0.165 0.25 0.365 0.515];
volputs = ivbs(100-Xputs,100-F,r,n,puts,'C',0.2);
disp('Implied vol (puts)')
[volputs; puts; Xputs]  

Xcalls = [95 95.25 95.5 95.75];
calls = [0.165 0.10 0.06 0.045];
volcalls = ivbs(100-Xcalls,100-F,r,n,calls,'P',0.2);
disp('Implied vol (calls)')
[volcalls; calls; Xcalls]

figure(4)
plot(Xputs,100*volputs,'o',Xcalls,100*volcalls,'*')
xlabel('Moneyness: X')
ylabel('Implied Volatility (Annual Percentage)')

%
disp('Jun 00') 
disp('***********************')
r = 0.05;  % 4*log(1+(0.05+5.045+5.14)/4)
n = 1.25;
F = 94.55

Xputs = [93.5 94 94.25 94.50 94.75 95]; 
puts = [0.09 0.18 0.255 0.35 0.475 0.625];
volputs = ivbs(100-Xputs,100-F,r,n,puts,'C',0.2);
disp('Implied vol (puts)')
[volputs; puts; Xputs]

Xcalls = [95 95.25 95.5 95.75 96 96.25];
calls = [0.195 0.135 0.095 0.065 0.045 0.03];
volcalls = ivbs(100-Xcalls,100-F,r,n,calls,'P',0.2);
disp('Implied vol (calls)')
[volcalls; calls; Xcalls]  

figure(5)
plot(Xputs,100*volputs,'o',Xcalls,100*volcalls,'*')
xlabel('Moneyness: X')
ylabel('Implied Volatility (Annual Percentage)')

% 
disp('Sep 00') 
disp('***********************')
r = 0.05;  % 4*log(1+(0.05+5.045+5.14)/4)
n = 1.5;
F = 94.475

Xputs = [94 94.25 94.50 94.75];
puts = [0.25 0.335 0.44 0.57];
volputs = ivbs(100-Xputs,100-F,r,n,puts,'C',0.2);
disp('Implied vol (puts)')
[volputs; puts; Xputs]

Xcalls = [94.5 94.75 95 95.25 95.5]; 
calls = [0.415 0.31 0.23 0.17 0.12];
volcalls = ivbs(100-Xcalls,100-F,r,n,calls,'P',0.2);
disp('Implied vol (calls)')
[volcalls; calls; Xcalls]  

figure(6)
plot(Xputs,100*volputs,'o',Xcalls,100*volcalls,'*')
xlabel('Moneyness: X')
ylabel('Implied Volatility (Annual Percentage)')

return

%  1. Volatility for zeros in Vasicek
%
disp('Vasicek volatilities')
mat = 120; imat = [1:mat]';
mur = 6.683/1200;
sigmar = 2.699/1200;
rhor = 0.959;

theta = mur
phi = rhor
sigma = sqrt(1-phi^2)*sigmar

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
yvas = 1200*(A + B*theta)./imat;

B6 = B(6);
B60 = B(60);

varz = sigma^2*(1-phi.^(2*imat))./(1-phi.^2);
varz = sqrt(12*varz./imat);
vol6 = 100*B6*varz;;
vol60 = 100*B60*varz;

figure(1)
plot(imat,vol6,'-',imat,vol60,'--')
xlabel('Maturity of Option in Months')
ylabel('Volatility (Annual Percentage)')
text(20,1.1,'6-month zeros')
text(40,3,'5-year zeros')
print -dps adfig2p1.ps

%
%  3. Normals and lognormals
xgrid = [0:0.5:15];
mur = 6.000;
varz = sigma^2*(1-phi.^(2*imat))./(1-phi.^2);
sigmar = 1200*(B(3)/3)*sqrt(varz(12))

mun = mur;
sigman  = sigmar;
nor = (sqrt(2*pi)*sigman)^(-1)*exp(-0.5*(xgrid-mun).^2/sigman^2);

sigmal = sqrt(log(1+(sigman/mun)^2))
mul = log(mun)-sigmal^2/2
logn = (xgrid*sqrt(2*pi)*sigmal).^(-1).* ...
                exp(-0.5*(log(xgrid)-mul).^2/sigmal^2);

figure(2)
plot(xgrid,nor,'-',xgrid,logn,'--')
xlabel('3-Month LIBOR in 12 Months')
ylabel('Probability Density Function')
text(2,0.2,'log-normal')
text(9,0.1,'normal')
print -dps adfig2p2.ps


return


