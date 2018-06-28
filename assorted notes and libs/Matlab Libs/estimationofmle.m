function [para,standard_deviation]=estimationofmle(sumoffc,fc,para0,y,eps)
%estimate parameters and standard errors when using maximium likelihood estimation(MLE) 
%sumoffc is the sum of -fc
%para0 and y are colummn vectors;eps is the precision when caculating the
%first-order derivative;y is the observed values;para0 is the  given initial
%parameters;fc is log maximium likelihood function
%example:
%function f=mynormpdf(x,y)
%y=1/sqrt(2*pi)/x(2)*exp(-(y-x(1)).^2/2/x(2)^2);
%f=log(y);
%%%%%%%%%%
%function f=mynormpdfsum(x,y)
%y=1/sqrt(2*pi)/x(2)*exp(-(y-x(1)).^2/2/x(2)^2);
%f=-sum(log(y));
%%%%%%%%%example1
%y=randn(1000,1);
%[para,standard_deviation]=estimationofmle('mynormpdfsum','mynormpdf',[0;2],y,1e-6)


%Zhiguang Cao, 2006,2,23
%caozhiguang@21cn.com
para=fminsearch(sumoffc,para0,[],y);
n=length(para);logf=feval(fc,para,y);
for i=1:n
    a=zeros(n,1);
    a(i)=eps;
    nlogf(:,i)=feval(fc,para+a,y);
    d(:,i)=(nlogf(:,i)-logf)/eps;
end
para=para;
standard_deviation=sqrt(diag(inv(d'*d)));