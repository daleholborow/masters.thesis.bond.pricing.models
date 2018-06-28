function [lsUDBP] = UnitDiscBondLongSchwartz(tau,V,K,vParams,rr,rho,sigma)
%--------------------------------------------------------------------------
% @description:	UnitDiscBondLongSchwartz
%				Longstaff and Schwartz 1995 model of Risky Discount Bond
%				Pricing.
%				Calculate the price of a risky discount bond according
%				to the LS model as outlined in LS's 1996 paper, 'A Simple 
%				Approach to Valuing Risky Fixed and Floating Rate Debt, 
%				The Journal of Finance, 1996.
%				Bond is priced as though the face value of the bond at 
%				maturity = 1.
% @notes:		Assumes the short-term risk-free interest rate r dynamics
%				are described by the alternate definition:
%				[dr = (alpha - beta*r)*dt + eta*dZ]
%				We still pass in the values as kappa and theta, and do the
%				equivalent calculations internally.
% @params:
%	tau			- Time until maturity. (i.e. bond has tau=T-t life
%				remaining).
%	V			- Firm asset value.
%	K			- Bankruptcy threshold. Financial distress occurs if V falls
%				below K before the bond matures.
%	vParams		- Structure containing vasicek interest rate parameters.
%	rr			- Recovery rate applied in the event of default. Multiplied 
%				by the face-value payment to get refund received by
%				debt-holder.
%	rho			- Correlation between asset value and short-term risk free 
%				interest rate r.
%	sigma		- Volatility (as std. deviation) of asset process. Constant
%				throughout time.
% @example:		
%				tau						= 1;			% 1 year
%				params.r0			= 0.09;		% params for nested vasicek riskless bond
% 			params.eta		= 0.03;
% 			params.theta	= 0.06;
% 			params.kappa	= 0.2;
%				V							= 100;		% Company value at time t=0
%				K							= 80;			% Default boundary
%				sigma					= 0.3;		
%				rho						= 0.85;
%				rr						= 0.5131;
%				UnitDiscBondLongSchwartz(tau,V,K,params,rr,rho,sigma)
%--------------------------------------------------------------------------
	% For now, we set the number of integration slivers to be a constant
	% regardless of the time til maturity. Possibly this should be a factor
	% of maturity time, for example: [n = tau*100] ???
	n		= 200;
	
	% Calculate our liability ratio X
	X		= V/K;
	
	% Get our interest rate parameters in the variation required for the
	% particular format of the Vasicek model as used in LS1996
	alpha	= vParams.kappa*vParams.theta;
	beta	= vParams.kappa;
	
	
	% The price of a riskless discount 0-coupon bond of equivalent maturity 
	% according to Vasicek
	rfDBP = UnitDiscBondVasicek(tau,vParams);
	
	% The default probability under the risk-neutral measure
	defProbQ = Q_Sum(X,tau,n,vParams.r0,alpha,rho,sigma,vParams.eta,beta);
	
	% Bond price as predicted by LS
	lsUDBP = rfDBP*(1 - (1-rr)*defProbQ);
	
	
	
	%--------------------------------------------------------------------------
	% @description:	
	% @note:		The original LS formula calculates each element Q_i as a recursive 
	%				function. I do not know what sort of processing power they were
	%				throwing at this problem to have had a useable solution in 1997, but
	%				with my relatively new machine in 2008, using a solution coded
	%				exactly as per their equation using n=20 took upwards of 14 seconds
	%				for a single discount bond, and n > 20 became ridiculous.
	%				As a result, I instead calculate each value in a more
	%				linear method, and store it for future use. This makes my
	%				code with n=200 almost instanteous, while values of n out
	%				to about 800 still only take a couple of seconds.
	%				Note also that I DO observe some slight changes in the
	%				predicted bond price using n < 500 or so, in the order of 
	%				1/10,000th. Eg, predicted bond price might move from 0.5411 to
	%				0.5410 as n goes from 200 to 400 for example.
	%--------------------------------------------------------------------------
	function q_Sum = Q_Sum(X,tau,n,r,alpha,rho,sigma,eta,beta)

		q_Sum = 0;		%Probability of default under Q-Measure

		% Realised I can do this HUNDREDS of times faster by not performing
		% the calculations for each recursive iteration... so instead of
		% n-factorial-factorial-etc calculations, we can just do n calculations
		% of M() and S() and retrieve them in the recursive loops whenever we
		% need to!!! Oh Excitement!! Oh Fast Code!!

		M_vals = zeros(1,n);
		S_vals = zeros(1,n);
		for i_n = 1 : 1 : n
			M_vals(i_n) = M((i_n*tau/n),tau,r,alpha,rho,sigma,eta,beta);
			S_vals(i_n) = S((i_n*tau/n),rho,sigma,eta,beta);
		end

		%
		% Now, we prepopulate a grid of all the a_i and b_ij values, since many
		% of these get used time and time again... Note: we store them after
		% running them through the N() function!!!
		%
		NA_vals = zeros(1,n);
		NB_vals = zeros(n,n);

		for i_i = 1 : 1 : n
			NA_vals(i_i) = N(A_I(X,i_i,M_vals,S_vals));
			for i_j = 1 : 1 : n
				% Only need to know halpha of the matrix of values, since
				% calculations never request values where i <= j
				if i_i > i_j
					NB_vals(i_i,i_j) = N(B_IJ(i_i,i_j,M_vals,S_vals));
				end
			end
		end

		%
		% Now, we prepopulate a vector of Q_i elements so that we do NOT have
		% to recursively generate the same value literally hundreds of 
		% thousands of times! This step is the one which above all saves us...
		% the earlier optimisations, while significant in their own right, pale
		% in comparison to this final optimisation!

		% Store all the Q_i elements, start them with value 0
		Q_vals = zeros(1,n);

		for i_i = 1 : 1 : n
			% start by loading each Q_i with the N(a_i) as stored in
			% NA_vals(i), see Equation 6 in LS1996.
			Q_vals(i_i) = NA_vals(i_i);

			if i_i > 1
				% Now, subtract all the lesser indexed Q_i * N() elements.
				% This is effectively performing the recursive functionality,
				% but at a zillionth of the processing cost!!

				% Total amount to subtract...
				toSub = 0;
				for i_x = 1 : 1 : (i_i-1)
					toSub = toSub + Q_vals(i_x)*NB_vals(i_i,i_x);
				end
				Q_vals(i_i) = Q_vals(i_i) - toSub;
			end
		end


		% Finally, to calculate the total probability of default, we merely sum
		% all the Q_i elements for i=1:n.
		q_Sum = sum(Q_vals);
	end


	%--------------------------------------------------------------------------
	% @description:	Corresponds to the equation a_i in LS1995, Equation 6.
	% @params:	
	%	X		- Ratio of V/K
	%	i_i		- Index value to retrieve ith value from the prepopulated 
	%			collection of M() and S() calculations
	%	M_vals	- Collection of prepopulated M() calculations
	%	S_vals	- Collection of prepopulated S() calculations
	%--------------------------------------------------------------------------
	function a_out = A_I(X,i_i,M_vals,S_vals)
		a_out = (- log(X) - M_vals(i_i)) / sqrt(S_vals(i_i));
	end


	%--------------------------------------------------------------------------
	% @description:	Corresponds to the equation b_ij in LS1995, Equation 6.
	% @params:	
	%	i_i		- Index value to retrieve ith value from the prepopulated 
	%			collection of M() and S() calculations
	%	i_j		- Index value to retrieve jth value from the prepopulated 
	%			collection of M() and S() calculations
	%	M_vals	- Collection of prepopulated M() calculations
	%	S_vals	- Collection of prepopulated S() calculations
	%--------------------------------------------------------------------------
	function b_out = B_IJ(i_i,i_j,M_vals,S_vals)
		b_out = (M_vals(i_j) - M_vals(i_i)) / sqrt(S_vals(i_i) - S_vals(i_j));
	end


	%--------------------------------------------------------------------------
	% @description:	Corresponds to the equation M(t,tau) in LS1995, Equation 6.
	%--------------------------------------------------------------------------
	function m_out = M(t,tau,r,alpha,rho,sigma,eta,beta)
		m_out = t*((alpha-rho*sigma*eta)/beta - eta^2/beta^2 - sigma^2/2) + ...
			exp(-beta*tau)*(exp(beta*t)-1)*(rho*sigma*eta/beta^2 + eta^2/(2*beta^3)) + ...
			(1-exp(-beta*t))*(r/beta - alpha/beta^2 + eta^2/beta^3) - ...
			(1-exp(-beta*t))*exp(-beta*tau)*(eta^2/(2*beta^3));
	end


	%--------------------------------------------------------------------------
	% @description:	Corresponds to the equation S(t) in LS1995, Equation 6.
	% @alert:		The Li and Wong 2006/07 equations differ to those of LS's
	%				original, in that they multiple some fractions in this
	%				equation by a factor of two. I have no idea why, only that
	%				it caused me much grief trying to find out why my model
	%				predictions did not match those from an Excel spreadsheet
	%				with the LS logic implemented as a demonstration!!
	%				As a result, I returned to original LS paper for the 'real'
	%				version to implement.
	%--------------------------------------------------------------------------
	function s_out = S(t,rho,sigma,eta,beta)
	%	LI AND WONG 2008 HAVE EXTRA MULTIPLIERS OF 2 -- _WHY_??!!
	% 	s_out = t*(2*rho*sigma*eta/beta + eta^2/beta^2 + sigma^2) - ... 
	% 		(1-exp(-beta*t))*(2*rho*sigma*eta/beta^2 + 2*eta^2/beta^3) + ...
	% 		(1-exp(-2*beta*t))*(eta^2/(2*beta^3));

		s_out = t*(rho*sigma*eta/beta + eta^2/beta^2 + sigma^2) - ... 
			(1-exp(-beta*t))*(rho*sigma*eta/beta^2 + 2*eta^2/beta^3) + ...
			(1-exp(-2*beta*t))*(eta^2/(2*beta^3));
	end
	
end
















