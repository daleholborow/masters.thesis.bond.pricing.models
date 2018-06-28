function bondPrice = UnitDiscBondVasicek(taus,params)
%--------------------------------------------------------------------------
% @description:	Vasicek 1977 model for Default-Free (Riskless) Zero-Coupon 
%				Bond Pricing.
%				Calculates the price of a riskless zero-coupon bond 
%				according to the model of Vasicek (1977), using the
%				particular formula specified in Hulls 'Options, Futures and 
%				Other Derivatives', for a practical definition of the formula 
%				to implement. 
% @notes:		Considers the short-term risk-free interest rate dynamics
%				(in the risk-neutral measure!!)
%				to be described by the following stochastic equation:
%				[dr = kappa*(theta - r0)*dt + eta*dZ].
%				See Hull's Options Futures and Other Derivatives v6
%				Equation 23.6
%				Some bond pricing formulas use the alternative notation:
%				[dr = (alpha - beta*r0)*dt + eta*dZ]
%				We must be aware of these instances and work around them when 
%				calculating our prices!! Transformation is:
%				alpha	= kappa*theta
%				beta	= kappa
% @params:
%	taus		- Matrix of times to maturity for which we are calculating the 
%				yield-to-maturity under Vasicek model. Must be a 1*n
%				or an n*1 matrix... m*n will cause irregular results.
%	params		- Structure containing the properties required to calculate
%				yield-to-maturity. "params" has the following properties:
%				"params.r0": Instantaneous risk-free interest rate as observed 
%				at time t. Typically used as the risk-free instantaneous
%				short-term rate.
%				"params.kappa": 'Pull-back' factor. Rate of mean reversion 
%				(rate at which r0 is pulled back to long-term mean theta). 
%				Constant through time.
%				"params.eta": Volatility of r0 (as std. deviation).
%				"params.theta": Constant. Long term average value of r0.
% @example:		
%				taus = [0 : 0.1 : 10];
%				params.r0		= 0.09;
% 			params.eta		= 0.03;
% 			params.theta	= 0.06;
% 			params.kappa	= 0.2;
%				bondPrices		= UnitDiscBondVasicek(taus,params);
% @author:		Dale Holborow, daleholborow@hotmail.com, Aug 7th, 2008
%--------------------------------------------------------------------------

	% Perform data cleaning. For example, many parameters cannot be set to
	% be exactly zero lest we get Divide-By-Zero errors, so before we begin
	% any calculations, clean those values now:
	params.kappa = ZeroClean(params.kappa);

	vasB = VasicekB();
	vasA = VasicekA(vasB);
	bondPrice = vasA.*exp(-params.r0*vasB);
	
	%%% End bond pricing logic  %%%
	
	
	%%% Begin private methods %%%
	
	%--------------------------------------------------------------------------
	% @notes:		See Hull's Options Futures and Other Derivatives v6
	%				Equation 23.8
	%--------------------------------------------------------------------------
	function a = VasicekA(vasB)
		a = exp(((vasB - taus).*(params.kappa^2*params.theta - 0.5*params.eta^2)/(params.kappa^2)) - ...
			(params.eta^2*vasB.^2/(4*params.kappa)));
	end

	%--------------------------------------------------------------------------
	% @notes:		See Hull's Options Futures and Other Derivatives v6
	%				Equation 23.7
	%--------------------------------------------------------------------------
	function b = VasicekB()
		b = (1-exp(-params.kappa*taus))/params.kappa;
	end
end





