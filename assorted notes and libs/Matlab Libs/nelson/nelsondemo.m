% % Example 1. Nelson-Siegel function: a sample shape
% par.beta = [.05 -.1 .15]';
% par.tau  = 1;
% x = [.125 .25 .5 1 2 3 5 7 10 20 30];
% y = nelsonfun(x,par);
% figure
% set(gcf,'Color','w')
% plot(x,y)
clc
% Example 2. Actual yield curve and NS approximation
x = [.125 .25  .5   1    2    3    5    7    10   20   30];
y = [2.57 3.18 3.45	3.34 3.12 3.13 3.52 3.77 4.11 4.56 4.51];

x	=[0 0.083333	0.16667	0.25	0.33333	0.41667	0.5	0.58333	0.66667	0.75	0.83333	0.91667	1	2	3	4	5	6	7	8	9	10];
y	=[6.9155 6.896	7.008	7.0867	7.0898	7.1367	7.1858	7.214	7.2421	7.2703	7.2907	7.3112	7.3316	7.4242	7.4491	7.4358	7.4353	7.4412	7.4538	7.4667	7.4799	7.4936];
% 	mrktObs		=[3.6117	3.8998	3.9936	4.0522	4.1108	4.1685	4.2585	4.3197	4.3713	4.4281	4.4862	4.5385	4.5939	4.9247	5.1105	5.2009	5.2482	5.274	5.2891	5.2987	5.3028	5.3009];
y = y/100;


par = nelsonfit(x,y);
p = nelsonfun(x,par)'

	x2	=[0	0.083333	0.16667	0.25	0.33333	0.41667	0.5	0.58333	0.66667	0.75	0.83333	0.91667	1	2	3	4	5	6	7	8	9	10];
	y2	=[6.9155	6.896	7.008	7.0867	7.0898	7.1367	7.1858	7.214	7.2421	7.2703	7.2907	7.3112	7.3316	7.4242	7.4491	7.4358	7.4353	7.4412	7.4538	7.4667	7.4799	7.4936];
% 	mrktObs		=[3.6117	3.8998	3.9936	4.0522	4.1108	4.1685	4.2585	4.3197	4.3713	4.4281	4.4862	4.5385	4.5939	4.9247	5.1105	5.2009	5.2482	5.274	5.2891	5.2987	5.3028	5.3009];
	y2 = y2/100;

params		= NelsonSiegelCurveFit(x2,y2)
yieldNS = NelsonSiegelYield(x2, params);

% params.zeta = par.tau;
% params.beta0 = par.beta(1);
% params.beta1 = par.beta(2);
% params.beta2 = par.beta(3);
% yieldNS = NelsonSiegelYield(x, params)
figure
set(gcf,'Color','w')
hold on
plot(x,y,'-rs'); 
plot(x,p,'-g' )
plot(x2,yieldNS,'-b' )
title('Nelson-Siegel approximation: example')
xlabel('Maturity, years')
legend('US Treasury yield curve (as of 12/28/07)', ...
      ['NS(\beta_{0} = '  sprintf('%3.2f',par.beta(1)) ',' ...
           '\beta_{1} = ' sprintf('%3.2f',par.beta(2)) ',' ...
           '\beta_{2} = ' sprintf('%3.2f',par.beta(3)) ',' ...
           '\tau = '      sprintf('%3.2f',par.tau)     ')'])
legend(gca,'boxoff')       