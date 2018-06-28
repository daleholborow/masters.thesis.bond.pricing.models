function aaDemo()
	
	clear all;
	close all;
	clc;
	
% 	%----------------------------------------------------------------------
% 	% Declare Parameters for testing of Vasicek Riskless Bond Pricing Demo
% 	tic
% 	t		= 0;
% 	T		= 1;
% 	kappa	= 1;			% [kappa = beta]
% 	theta	= 0.06;			% [theta = alpha / beta]
% 	nu		= sqrt(0.001);
% 	r		= 0.05;
% 
% 	% Calc vasicek discount risk free bond price
% 	vasicekDiscBondPrice = UnitDiscBondVasicek(t,T,r,kappa,nu,theta)
% 	
% 	% Calculate vasicek yield for comparison purposes
% 	vasicekYield = CalcDiscountBondYield((T-t),vasicekDiscBondPrice)
% 	toc
% 	%----------------------------------------------------------------------
	

% 	%----------------------------------------------------------------------
% 	% Declare Parameters for testing of Merton Risky Bond Pricing Demo
% 	tic
% 	t		= 0;
% 	T		= 1;
% 	kappa	= 0.2;			% [kappa = beta]
% 	theta	= 0.06;			% [theta = alpha / beta]
% 	nu		= sqrt(0.001);
% 	r0		= 0.05;
% 	FV		= 1;
% 	V		= FV * 1.5;		% 66% leverage example
% 	sigma	= 0.2;
% 	K		= 0.9;
% 	delta	= 0.04;
% 	rr		= 0.5131;
% 	
% 	% Calc vasicek discount risk free bond price
% % 	(taus,params)
% % 	vasicekDiscBondPrice = UnitDiscBondVasicek(t,T,r,kappa,nu,theta)
% 	vParams.kappa	= kappa;
% 	vParams.nu		= nu;
% 	vParams.theta	= theta;
% 	vParams.r0		= r0;
% 	tau				= T-t;
% 	vasicekDiscBondPrice = UnitDiscBondVasicek(tau,vParams)
% 	
% 	% Calc Merton discount risky bond price
% 	mertonBP = MUnitDiscBond((T-t),V,K,vParams,delta,sigma,rr)
% 	
% 	% Calculate merton yield for comparison purposes
% 	mertonYield = CalcDiscountBondYield((T-t),mertonBP)
% 	toc
% 	%----------------------------------------------------------------------
	
	
% 	%----------------------------------------------------------------------
% 	% Declare parameters for testing of Longstaff and Schwartz bond pricing
% 	% model demo.
% 	tic
% 	rho		= -0.25;
% 	V		= 1.05;
% 	K		= 1;
% 	sigma	= 0.2;
% 	delta	= 0;
% 	%rr_p	= 1-0.9;
% 	rr_p	= 0.55;
% 	rr_c	= 0;
% 	
% 	vParams.kappa	= 1;			% [kappa = beta]
% 	vParams.nu		= sqrt(0.001);
% 	vParams.theta	= 0.06;			% [theta = alpha / beta]
% 	vParams.r0		= 0.05;
% 	tau				= 1;
% 	
% 	% Calc vasicek discount risk free bond price
% 	vasicekDiscBondPrice = UnitDiscBondVasicek(tau,vParams)
% 	
% 	% Calculate the discount bond price as predicted by the LS model
% 	lsUDBP = LSUnitDiscBond(tau,V,K,vParams,rr_p,delta,rho,sigma)
% 	toc
% 	%----------------------------------------------------------------------
	
	
	
% 	%----------------------------------------------------------------------
% 	% Generate a graph to match LS1995, Figure 1 to be sure that both our
% 	% LS _and_ our Vasicek model are correct:
% 	% Requires alpha=0.06 and beta=1.0.
% 	tic
% 	rho		= -0.25;
% 	V		= 1.05;
% 	K		= 1;
% 	sigma	= 0.2;
% 	delta	= 0;
% 	rr_p	= 1-0.9;
% 	
% 	vParams.kappa	= 1;			% [kappa = beta]
% 	vParams.nu		= sqrt(0.001);
% 	vParams.theta	= 0.06;			% [theta = alpha / beta]
% 	vParams.r0		= 0.04;
% 	
% 	taus = [0.1 : 0.1 : 1, 1.5 : 0.5 : 4];
% 	[rows cols] = size(taus);
% 	for taus_i = 1 : 1 : cols
% 		prices(taus_i) = LSUnitDiscBond(taus(taus_i),V,K,vParams,rr_p,delta,rho,sigma);
% 	end
% 	% Plot the graph so we can see the comparison against LS1995's Figure 1.
% 	plot(taus, prices, 'red');
% 	axis([0,4,0.15,0.65]);
% 	toc
% 	%----------------------------------------------------------------------
	
	
	
% 	%----------------------------------------------------------------------
% 	% Declare parameters for demo of Briys and de Varenne 2001 pricing
% 	% model.
% 	tic
% 	tau		= 1;
% 	rho		= -0.25;
% 	V		= 1.55;
% 	F		= 1.5;
% 	gamma	= 1.54;			
% 	sigma	= 0.2;
% 	f1		= 0.8;
% 	f2		= 0.8;
% 	
% 	vParams.kappa	= 0.2;			% [kappa = beta]
% 	vParams.nu		= sqrt(0.001);
% 	vParams.theta	= 0.06;			% [theta = alpha / beta]
% 	vParams.r0		= 0.05;
% 	
% 	% Calc vasicek discount risk free bond price
% 	vasicekDiscBondPrice = F*UnitDiscBondVasicek(tau,vParams)
% 	
% 	% Calculate the discount bond price as predicted by the LS model
% 	bdvUDBP = BdVDiscBond(tau,V,F,vParams,f1,f2,gamma,rho,sigma)
% 	
% 	toc
% 	%----------------------------------------------------------------------
	
	
	
% 	%----------------------------------------------------------------------
% 	% Test Briys and de Varenne 1999 pricing model against the values of
% 	% their Table 1.
% 	tic
% 	
% 	t		= 0;
% 	T		= 5;
% 	rho		= -0.25;
% 	sigma	= 0.2;
% 	tau		= T-t;
% 	
% 	vParams.r0		= 0.05;
% 	vParams.kappa	= 0.2;		% [kappa = beta]
% 	vParams.theta	= 0.06;		% [theta = alpha / beta]
% 	vParams.nu		= 0.02;
% 	
% 	
% 	% Calc vasicek discount risk free bond price
% 	vasDiscBP = UnitDiscBondVasicek(tau,vParams)
% 	
% 	V		= 1 * vasDiscBP;
% 	F		= 1;
% 	gamma	= 1;			% To make Q0 = x*L0: gamma = 1/x
% % 	gamma	= 1/1.25;		
% 	f1		= 0.8;
% 	f2		= f1;
% 	
% 	% Calculate the discount bond price as predicted by the BdV model
% % 	bdvUDBP = BdVDiscBond(T,V,F,r,f1,f2,gamma,kappa,nu,rho,sigma,theta)
% 	bdvUDBP = UnitDiscBondBriysDeVarenne(tau,V,F,vParams,f1,f2,gamma,rho,sigma)
% 	
% 	% Calculate the spread between the risk-free bond and the equivalent
% 	% BdV risky bond:
% 	ys = CalcDiscountBondYield(tau,bdvUDBP/(F*vasDiscBP))
% 	
% 	toc
% 	%----------------------------------------------------------------------
	

	
% 	%----------------------------------------------------------------------
% 	% Demonstrate that the BdV discount bond pricing model is correct by
% 	% reproducing BdV1997's Corporate Spreads results as displayed in their
% 	% Figure 1:
% 	tic
% 	rho		= -0.25;
% 	sigma	= 0.2;
% 	F		= 1;
% 	gamma	= 0.9;
% 	f1		= 0.8;
% 	f2		= f1;
% 	
% 	vParams.kappa	= 0.2;			% [kappa = beta]
% 	vParams.nu		= 0.02;
% 	vParams.theta	= 0.06;			% [theta = alpha / beta]
% 	vParams.r0		= 0.05;
% 	
% 	% Generate a smooth range of taus so we get a nice graph
% 	mats = [0.1 : 0.2 : 20];
% 	[rows cols] = size(mats);
% 	for mat_i = 1 : 1 : cols
% 		% Calculate maturity time
% 		T = mats(mat_i);
% 
% 		% Calc vasicek discount risk free bond price
% 		vasDiscBP = UnitDiscBondVasicek(T,vParams);
% 		
% 		% Calculate the ratio of V over the discount bond so we can match
% 		% BdV's demo L0 values (2.5, 1.25 and 0.9)
% 		V09		= 0.9 * vasDiscBP;
% 		V125	= 1.25 * vasDiscBP;
% 		V250	= 2.5 * vasDiscBP;
% 		
% 		% Calculate the discount bond price as predicted by the BdV model
% 		bdvUDBP09 = UnitDiscBondBriysDeVarenne(T,V09,F,vParams,f1,f2,gamma,rho,sigma);
% 		bdvUDBP125 = UnitDiscBondBriysDeVarenne(T,V125,F,vParams,f1,f2,gamma,rho,sigma);
% 		bdvUDBP250 = UnitDiscBondBriysDeVarenne(T,V250,F,vParams,f1,f2,gamma,rho,sigma);
% 		
% 		% Calculate the yield spread
% 		yields09(mat_i) = CalcDiscountBondYield(T,bdvUDBP09/(F*vasDiscBP));
% 		yields125(mat_i) = CalcDiscountBondYield(T,bdvUDBP125/(F*vasDiscBP));
% 		yields250(mat_i) = CalcDiscountBondYield(T,bdvUDBP250/(F*vasDiscBP));
% 	end
% 	% Plot the graph so we can see the comparison against BdV1997's 
% 	% Figure 1.
% 	hold on
% 	plot(mats, yields250, 'red');
% 	plot(mats, yields125, 'blue');
% 	plot(mats, yields09, 'green');
%  	axis([0,20,0,0.1]);
% 	
% 	toc
% 	%----------------------------------------------------------------------
	
	
% 	%----------------------------------------------------------------------
% 	% Declare variables for the Black-Scholes European Call option pricing
% 	% demo
% 	K			= 4;
% 	r			= 0.0;
% 	sigma		= 0.2;
% 	T			= 1;
% 	V			= 5;
% 	
% 	bsEC = BSCallEuro(K,r,sigma,T,V)
% 	%----------------------------------------------------------------------
	
	
	
% 	%----------------------------------------------------------------------
% 	% Declare variables for the Down-and-Out Call option demonstration.
% 	X			= 1;
% 	H			= 0.8 * X;
% 	r			= 0.05;
% 	sigma		= 0.2;
% 	T			= 1;
% 	V			= 5.5;
% 	eqtyRebate		= 0.51*X;
% 	
% 	doc = DownOutCall(H,r,eqtyRebate,sigma,T,V,X)
% 	%----------------------------------------------------------------------
	

% 	%----------------------------------------------------------------------
% 	% Demonstrate that the Vasicek discount bond pricing model is correct by
% 	% reproducing yield curves 
% 	tic
% 	
% 	taus			= [0.1 : 0.1 : 30];
% 	hold on;
% 	
% 	% Creates a gently downward sloping yield curve that slowly becomes 
% 	% flat (red line)
% 	params.kappa	= 0.2;			% [kappa = beta]
% 	params.theta	= 0.06;			% [theta = alpha / beta]
% 	params.nu		= 0.02;
% 	params.r		= 0.09;
% 	prices			= UnitDiscBondVasicek(taus,params);
% 	yields			= CalcDiscountBondYield(taus, prices);
% 	plot(taus, yields, 'red');
% 	
% 	% Creates a gently upward sloping curve that slowly becomes flat 
% 	% (blue line)
% 	params.kappa	= 0.2;			% [kappa = beta]
% 	params.theta	= 0.06;			% [theta = alpha / beta]
% 	params.nu		= 0.02;
% 	params.r		= 0.03;
% 	prices			= UnitDiscBondVasicek(taus,params);
% 	yields			= CalcDiscountBondYield(taus, prices);
% 	plot(taus, yields, 'b');
% 	
% 	% Creates a sharly upward early sloping curve that then quickly becomes 
% 	% flat (green line)
% 	params.kappa	= 1;			% [kappa = beta]
% 	params.theta	= 0.06;			% [theta = alpha / beta]
% 	params.nu		= 0.02;
% 	params.r		= 0.03;
% 	prices			= UnitDiscBondVasicek(taus,params);
% 	yields			= CalcDiscountBondYield(taus, prices);
% 	plot(taus, yields, 'g');
% 	
% 	% Creates an early humped curve that then quickly becomes 
% 	% flat (cyan line)
% 	params.kappa	= 2;			% [kappa = beta]
% 	params.theta	= 0.095;		% [theta = alpha / beta]
% 	params.nu		= 0.65;
% 	params.r		= 0.035;
% 	prices			= UnitDiscBondVasicek(taus,params);
% 	yields			= CalcDiscountBondYield(taus, prices);
% 	plot(taus, yields, 'cyan');
% 	
% 	% Creates a long, gently bowed curve (black(
% 	params.kappa	= 0.02;			% [kappa = beta]
% 	params.theta	= 0.095;		% [theta = alpha / beta]
% 	params.nu		= 0.015;
% 	params.r		= 0.035;
% 	prices			= UnitDiscBondVasicek(taus,params);
% 	yields			= CalcDiscountBondYield(taus, prices);
% 	plot(taus, yields, 'k');
% 	
% 	
% 	axis([0,30,0,0.1]);
% 	toc
% 	%----------------------------------------------------------------------
	
	

% 	%----------------------------------------------------------------------
% 	% Demonstrate that our Nelson-Siegel1987 interest rate model code is 
% 	% correct by recreating their Figure 1 plots of interest yield curves.
% 	tic
% 	taus = [0 : 0.25 : 10];
% 	params.beta1 = 1;
% 	params.beta2 = -1;
% 	params.zeta = 1;
% 	
% 	for beta3_i = -6 : 3 : 12
% 		params.beta3 = beta3_i;
% 		yields = NelsonSiegelYield(taus, params);
% 		
% 		% Plot the graphs to show our code works
% 		hold on
% 		plot(taus, yields, 'r-x')
% 	end
% 	toc
% 	%----------------------------------------------------------------------
	

% 	%----------------------------------------------------------------------
% 	% Demonstrate Nelson-Siegel1987 interest rate model parameter
% 	% estimation code:
% 	tic
% 	% Assign a selection of "market observations" - a cross-sectional yield
% 	% curve observation
% % 	taus			= [.125 .25  .5   1    2    3    5    7    10   20   30];
% % 	marketYields	= [2.57 3.18 3.45	3.34 3.12 3.13 3.52 3.77 4.11 4.56 4.51];
% 	taus			= [.125 .25  .5   1    2    3    5    7    10];
% 	marketYields	= [2.57 3.18 3.45	3.34 3.12 3.13 3.52 3.77 4.11];
% 	marketYields	= marketYields/100;
% 	% Estimate the parameters to best fit the NS model to the market
% 	% observations
% 	params		= NelsonSiegelCurveFit(taus,marketYields);
% 	guessYields	= NelsonSiegelYield(taus, params);
% 	
% 	% Plot the curve to match the estimated param curve against the actual
% 	% market data curve
% 	hold on
% 	plot(taus, guessYields, 'b-s');
% 	plot(taus, marketYields, 'g-+');
% 	axis([0,10,0,0.05]);
% 	toc
% 	
% 	% Now calculate the instantaneous interest rate
% 	instant		= 0
% 	instantRate	= NelsonSiegelInstantForward(instant, params)
% 	instantRateSimple	= params.beta1 + params.beta2
% 	interestRateYield	= NelsonSiegelYield(instant, params)
% 	%----------------------------------------------------------------------
	
	
% 	%----------------------------------------------------------------------
% 	% Another NS demo
% 	tic
% 	mrktTaus	=[0	0.083333	0.16667	0.25	0.33333	0.41667	0.5	0.58333	0.66667	0.75	0.83333	0.91667	1	2	3	4	5	6	7	8	9	10];
% 	mrktYields	=[6.9155	6.896	7.008	7.0867	7.0898	7.1367	7.1858	7.214	7.2421	7.2703	7.2907	7.3112	7.3316	7.4242	7.4491	7.4358	7.4353	7.4412	7.4538	7.4667	7.4799	7.4936];
% % 	mrktYields		=[3.6117	3.8998	3.9936	4.0522	4.1108	4.1685	4.2585	4.3197	4.3713	4.4281	4.4862	4.5385	4.5939	4.9247	5.1105	5.2009	5.2482	5.274	5.2891	5.2987	5.3028	5.3009];
% 	mrktYields = mrktYields/100;
% 	
% 	params		= NelsonSiegelCurveFit(mrktTaus,mrktYields)
% 	guessYields	= NelsonSiegelYield(mrktTaus, params)
% 	toc
% 	hold on
% 	plot(mrktTaus,guessYields,'b')
% 	plot(mrktTaus,mrktYields,'g');
% 	%----------------------------------------------------------------------

	
% 	%----------------------------------------------------------------------
% 	% Demonstrate the Vasicek interest rate cross-sectional yield curve data 
% 	% parameter estimation
% 	tic
% 	
% % 	mrktTaus	= [.125 .25  .5   1    2    3    5    7    10   20   30];
% % 	mrktYields	= [2.57 3.18 3.45	3.34 3.12 3.13 3.52 3.77 4.11 4.56 4.51];
% 	
% 	mrktTaus	=[0.083333	0.16667	0.25	0.33333	0.41667	0.5	0.58333	0.66667	0.75	0.83333	0.91667	1	2	3	4	5	6	7	8	9	10];
% 	mrktYields	=[6.896	7.008	7.0867	7.0898	7.1367	7.1858	7.214	7.2421	7.2703	7.2907	7.3112	7.3316	7.4242	7.4491	7.4358	7.4353	7.4412	7.4538	7.4667	7.4799	7.4936];
% % 	mrktYields	=[3.8998	3.9936	4.0522	4.1108	4.1685	4.2585	4.3197	4.3713	4.4281	4.4862	4.5385	4.5939	4.9247	5.1105	5.2009	5.2482	5.274	5.2891	5.2987	5.3028	5.3009];
% 	mrktYields = mrktYields/100;
% 	
% 	
% 	hold on;
% 	params			= VasicekCurveFit(mrktTaus, mrktYields)
% 	
% 	% Predict the zero-coupon bond prices based on the Vasicek interest
% 	% rate params
% 	prices			= UnitDiscBondVasicek(mrktTaus,params);
% 	% Now calculate the yields to maturity
% 	yields			= CalcDiscountBondYield(mrktTaus, prices);
% 	% Plot the difference between the actual market data and our predicted
% 	% values
% 	plot(mrktTaus, yields, 'r-x');
% 	plot(mrktTaus, mrktYields, 'g-*');
% 	
% 	params		= NelsonSiegelCurveFit(mrktTaus,mrktYields);
% 	guessYields	= NelsonSiegelYield(mrktTaus, params);
% 	plot(mrktTaus, guessYields, 'b-s');
% 	
% %  	axis([0,30,0,0.06])
% 	toc
% 	
% 	% Now calculate the instantaneous rate
% % 	instantRate	= params.r
% 	%----------------------------------------------------------------------
	

% 	% Just a test of the values being outputted by the vasicek estimation,
% 	% seems all good
% % 	mrktYields	= [0.06255	0.061724	0.061579	0.061791	0.061633	0.061583	0.06164	0.061696	0.061753	0.061818	0.061883	0.061947	0.062773	0.063401	0.063466	0.063803	0.064028	0.064381	0.064618	0.064863	0.065115];
% 	mrktTaus	= [0.083333	0.16667	0.25	0.33333	0.41667	0.5	0.58333	0.66667	0.75	0.83333	0.91667	1	2	3	4	5	6	7	8	9	10];
% % 	28/02/2005					
% 	mrktYields	= [0.049835	0.050174	0.050481	0.050681	0.050875	0.051106	0.051258	0.051379	0.051544	0.051634	0.051732	0.051817	0.051937	0.051666	0.051418	0.05131	0.051257	0.051202	0.051114	0.050993	0.050838];
% 
% 	params.r0	= 0.049371;
% 	params.theta= 0.060307;
% 	params.kappa= 0.99608;
% 	params.nu	= 0.13875;
% 	
% % 	params.r0	= 0.068612;
% % 	params.theta= 0.086778;
% % 	params.kappa= 1.0098;
% % 	params.nu	= 0.15773;
% 
% 	guessPrices	= UnitDiscBondVasicek(mrktTaus,params);
% 	guessYields	= CalcDiscountBondYield(mrktTaus, guessPrices);
% 	
% 	hold on
% 	plot(mrktTaus, mrktYields, 'g-s');
% 	plot(mrktTaus, guessYields, 'r-x');
% 
% 
% % 	mrktYields	= [0.062346	0.061719	0.061574	0.061329	0.061163	0.061064	0.061028	0.060992	0.060956	0.060965	0.060974	0.060983	0.061594	0.062151	0.062131	0.062471	0.062698	0.063053	0.06329	0.063534	0.063784];
% % 	params.r0	= 0.061125	
% % 	params.theta= 0.0877	
% % 	params.kappa= 0.021026	
% % 	params.nu	= 0.000000000000022204
% % 
% % 	guessPrices	= UnitDiscBondVasicek(mrktTaus,params);
% % 	guessYields	= CalcDiscountBondYield(mrktTaus, guessPrices);
% % 	
% % 	hold on
% % 	plot(mrktTaus, mrktYields, 'b-s');
% % 	plot(mrktTaus, guessYields, 'k-x');




%-----------------------------------------------------------------------

% 	% 2/2/2006 - BAD!!
% 	mrktYields	= [4.7127	4.756	4.8407	4.8838	4.9158	4.9468	4.9641	4.9813	4.9989	5.0088	5.0195	5.0289	5.0393	5.0338	5.0446	5.0614	5.0784	5.0955	5.107	5.1187	5.137]/100;
% 	mrktTaus	= [0.083333	0.16667	0.25	0.33333	0.41667	0.5	0.58333	0.66667	0.75	0.83333	0.91667	1	2	3	4	5	6	7	8	9	10];
% 	params.r0	= 0.0461
% 	params.theta= 0.0539
% 	params.kappa= 0.5509
% 	params.nu	= 0.0712
	
% 	% 28/2/2005 - BAD!!
% 	mrktYields	= [2.751	2.8415	2.9624	3.0393	3.1305	3.1984	3.2641	3.3273	3.3902	3.4416	3.4926	3.5385	3.9572	4.1448	4.2825	4.3953	4.4937	4.5887	4.6678	4.7431	4.814]/100;
% 	mrktTaus	= [0.083333	0.16667	0.25	0.33333	0.41667	0.5	0.58333	0.66667	0.75	0.83333	0.91667	1	2	3	4	5	6	7	8	9	10];
% 	params.r0	= 0.0494
% 	params.theta= 0.0603
% 	params.kappa= 0.9961
% 	params.nu	= 0.1388
	
% 	guessPrices	= UnitDiscBondVasicek(mrktTaus,params)
% 	guessYields	= CalcDiscountBondYield(mrktTaus, guessPrices);
% 	
% 	hold on
% 	plot(mrktTaus, mrktYields, 'b-s');
% 	plot(mrktTaus, guessYields, 'k-x');

% 	mrktTaus			= [.125,.25,.5,1,2,3,5,7,10,20,30];
% 	mrktYields	=[2.57,3.18,3.45,3.34,3.12,3.13,3.52,3.77,4.11,4.56,4.51];
% 	mrktYields = mrktYields / 100;
% 	params = YieldCurveFitVasicek(mrktTaus, mrktYields)
end















