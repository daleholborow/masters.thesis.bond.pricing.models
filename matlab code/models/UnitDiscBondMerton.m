function out = UnitDiscBondMerton(tau,V,K,vParams,sigma,rr)
%--------------------------------------------------------------------------
% @description:	Merton1974 model for risky zero-coupon bond prices.
%				Calculate the price of a risky discount bond according
%				to the extended Merton model as outlined in EHH2004
%				paper.
%				Assumes that asset value fluctuates (under a risk-neutral 
%				measure) according to:
%				[dV = (r-delta)Vt*dt + sigma*Vt*dZ]
%
%				NOTE: Assumes that the face value of the bond is equal
%				to 1. Thus, to ensure that the pricing calculations are
%				correct, value of assets MUST be passed in as a ratio of
%				the unit face value. For example, for a company with 
%				$120 of assets issuing a $5 bond, we should input V=120/5!!
% @params:
%	tau			- Time until bond matures. (i.e. bond has tau=T-t life 
%				remaining).
%	V			- Firm asset value. (Expressed as a ratio compared to the
%				face-value of the bond, where we scale FV to equal a unit
%				bond.
%	K			- Default boundary, K in [0,1] (expressed as a percentage of
%				the face value of the bond.
%	vParams		- Structure containing vasicek interest rate parameters.
%	sigma		- Volatility (as std. deviation) of asset process. Constant
%				throughout time.
%	rr			-  Recovery rate after default, eg: (rr*ndp = 0.5131*1 = 0.5131)
%				suggests that 51% of face value is recovered after costly 
%				default. It is implied that rr <= K always - the validity of
%				this statement been debated.
%--------------------------------------------------------------------------
	
	% Perform data cleaning. For example, many parameters cannot be set to
	% be exactly zero lest we get Divide-By-Zero errors, so before we begin
	% any calculations, clean those values now:
	kappa		= ZeroClean(vParams.kappa);
	rr			= ZeroClean(rr);
	sigma		= ZeroClean(sigma);
	
	% Payout ratio: weighted average of c and the share repurchase-adjusted 
	% divident yield. Always set to zero, since should be incorporated by use
	% of adjusted close prices etc.
	delta		= 0;
	
	% The price of a riskless discount 0-coupon bond of equivalent maturity 
	% according to Vasicek
 	rfBP = UnitDiscBondVasicek(tau,vParams);
	
	% Important idea behind Merton model: Calculate the weighted average of
	% the value of the payment received if the bond defaults multiplied by 
	% the probabilty that it defaults, and sum that with the payout 
	% received if the bond does NOT default multiplied by the probability 
	% that it does NOT default. We do this now, in two parts:
	
	%
	% Part A: NO DEFAULT OCCURS
	%
	% Calculate the probability that no default occurs:
	noDefProb = N(d2(K,tau,V,rfBP,delta,sigma));
	% Calculate expected payout contributed by probability of no default
	weightedNoDefPayout = 1 * noDefProb;
	
	%
	% Part B: DEFAULT OCCURS AND IS COSTLY
	%
	% Calculate the expected payout contributed by probability that 
	% costly default occurs:
	% (See EHH equation 6 for reference)
	weightedDefPayout = V/rfBP *exp(-delta*tau) * ...
		N(-d1(rr,tau,V,rfBP,delta,sigma)) + ...
		rr * (N(d2(rr,tau,V,rfBP,delta,sigma)) - ...
		N(d2(K,tau,V,rfBP,delta,sigma)));
	
	%
	% Part C: Finally, return the price for the risky Merton discount bond
	%
	out = rfBP * (weightedNoDefPayout + weightedDefPayout);
	
	
	
	%--------------------------------------------------------------------------
	% @description:	See EHH2004 Equation 7 for original definition.
	% @usage:		PRIVATE METHOD - NOT TO BE USED PUBLICLY!!! Should ONLY
	%				EVER call this function from the BdVUnitDiscBond function.
	%--------------------------------------------------------------------------
	function out = d1(x,T,V,rfdb,delta,sigma)
		out = (log(V/(x*rfdb)) + (-delta+sigma^2/2)*T) / sigma*sqrt(T);
	end


	%--------------------------------------------------------------------------
	% @description:	See EHH2004 Equation 7 for original definition.
	% @usage:		PRIVATE METHOD - NOT TO BE USED PUBLICLY!!! Should ONLY
	%				EVER call this function from the BdVUnitDiscBond function.
	%--------------------------------------------------------------------------
	function out = d2(x,T,V,rfdb,delta,sigma)
		out = d1(x,T,V,rfdb,delta,sigma) - sigma*sqrt(T);
	end

end





