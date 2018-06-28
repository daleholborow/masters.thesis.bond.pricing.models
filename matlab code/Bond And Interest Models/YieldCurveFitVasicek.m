function params = YieldCurveFitVasicek(mrktTaus, mrktYields)
%--------------------------------------------------------------------------
% @description:	Attempt to estimate the parameters of the Vasicek 
%				1977 short-term risk-free interest rate 
%				term structure model of yields. We do this by
%				using least-squares for a cross-sectional data set, that
%				is, a structural yield-to-maturity curve for zero-coupon 
% 				treasury instruments.
% @params:
%	mrktTaus	- Matrix of times to maturity for which we are calculating 
%				the yield-to-maturity under Vasicek model. Must be a 
%				1*n or an n*1 matrix... m*n will cause irregular results.
%	mrktYields	- Matrix of observed yields-to-maturity that correspond to
%				the matching index in mrktTaus.
% @example:
%				mrktTaus			= [.125,.25,.5,1,2,3,5,7,10,20,30];
%				mrktYields	=
%				[2.57,3.18,3.45,3.34,3.12,3.13,3.52,3.77,4.11,4.56,4.51];
%				mrktYields = mrktYields / 100;
%				params = YieldCurveFitVasicek(mrktTaus, mrktYields)
% @author:		Dale Holborow, daleholborow@hotmail.com, August 7, 2008
%--------------------------------------------------------------------------
	
	% Set up some initial values for parameter guesses. Had initial
	% troubles trying to use 'sensible' initial guesses with low number of 
	% function eval/iterations. Resolved by greatly increasing number of 
	% function eval/iterations in order to be sure end result was precice,
	% so initial param estimates become far less important, now we just use
	% some random approximations in the rough vacinity of the expected
	% answers:
	pars(1)		= (0.25)*rand(1,1);	% interest rate r0
	pars(2)		= (0.25)*rand(1,1);	% interest rate long term mean theta
	pars(3)		= (0.40)*rand(1,1);	% interest rate mean reversion rate kappa
	pars(4)		= (0.05)*rand(1,1);	% interest rate volatility eta
	
	% Specify some lower/upper bounds for each parameter we will be
	% estimating (r,theta,kappa,eta):
	lowBound			= [0,0,0,0];
	upBound				= [0.4,0.4,4,10];
	
	% Make optimisation routine VERY precice by performing the routine LOTS
	% of times. Sacrifice a bit of speed for a highly precise and accurate
	% answer (hopefully).
	options				= optimset('lsqnonlin');
	options.TolFun		= 10^-11;
	options.MaxFunEvals = 4*600;
	options.MaxIter		= 4*200;
	options.Display		= 'off';
	
	
	% Now, estimate our optimal parameters to match the observed market yield 
	% curve values.
	[pars,resNorm,residual,exitFlag,output] = lsqnonlin(@(pars) ...
		VasicekFit(pars),pars,lowBound,upBound,options);
	
	
	% Retrieve the optimal values and place them into a structure so they
	% can be returned by the function.
	params.r0		= pars(1);
	params.theta	= pars(2);
	params.kappa	= pars(3);
	params.eta		= pars(4);
	
	%%% End optimal parameter estimation logic %%%
	
	
	%----------------------------------------------------------------------
	% @description:	Return the array of differences between predicted and
	%				observed yields-to-maturity based on an estimated
	%				parameter set, so we can implement our least-squared
	%				error algorithm.
	function [F] = VasicekFit(tmpPars)
		tmpParams.r0	= tmpPars(1);
		tmpParams.theta	= tmpPars(2);
		tmpParams.kappa	= tmpPars(3);
		tmpParams.eta	= tmpPars(4);
				
		prices	= UnitDiscBondVasicek(mrktTaus,tmpParams);
		yields	= CalcDiscountBondYield(mrktTaus,prices);
		if isinf(yields)
			yields
			tmpPars
			error('inf values')
		end
		F		= mrktYields - yields;
	end
end



