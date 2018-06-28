%******************************************************************************
%  treetest.m
%  Test of binomial model routines
%  Subject:  "Binomial Models"
%  Backus and Zin, March 1999 and after
%******************************************************************************
clear
close all
format compact
format short

%  1. Calibration
%
disp('************************************************')
disp('Calibration')
y = [6.036 5.809 5.824 5.839];
d = 1./(1+y/200).^[1:length(y)];
y = -200*log(d)./[1:length(y)];
maxmat = length(y);
h = 0.5;
pistar = 0.5;

model = 'hl';
mu = y;  
sigma = 0.972*ones(1,length(y))/sqrt(h); 

%model = 'bdt';  
%mu = log(y); 
%sigma = 0.15*ones(1,maxmat)/sqrt(h); 

now = cputime;
mu = fmins('calmu',mu,foptions,[],sigma,pistar,h,model,y)
etime = cputime - now

r = eval(['tree' model '(mu,sigma,h)']);
disp('Rate tree')
flipud(r)
[spots,d,Q] = r2ybi(r,pistar,h);
disp('Spot rates')
[spots; y]

% convert rates
d = exp(-r/200);
r = 200*(1./d-1);
flipud(r)

return
