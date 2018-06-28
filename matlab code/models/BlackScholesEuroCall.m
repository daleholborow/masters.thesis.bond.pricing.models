function [BSCallEuro] = BlackScholesEuroCall(X,r,sigma,tau,V)
%--------------------------------------------------------------------------
% @description: BSCallEuro
%				Black-Scholes european call option.
% @params:
%	X			- Exercise/Strike price of option. 
%	r			- Short-term risk-free interest rate
%	sigma		- Standard deviation of company asset value. Cannot be exactly
%				zero lest we get Divide-By-Zero errors.. use ZeroClean() 
%				function to catch this.
%	tau			- Time to maturity of call option
%	V			- Current value of some traded asset, be it a share price, full
%				firm asset value, whatever...
%--------------------------------------------------------------------------
	
	% Default the value of the european call to be as low as it can
	% possibly be, i.e. zero.
	BSCallEuro		= 0;
	
% 	% Option only has value if it has some time left until expiry and the
% 	% underlying asset has some strictly positive value.
% 	if tau > 0 && V > 0
	% Perform data cleaning. For example, many parameters cannot be set to
	% be exactly zero lest we get Divide-By-Zero errors, so before we begin
	% any calculations, clean those values now:
	X			= ZeroClean(X);
	sigma		= ZeroClean(sigma);
	tau			= ZeroClean(tau);
	V			= ZeroClean(V);

	% Calculate d1 and d2 placeholder variable values
	d1			= BSCallEuroD1(X,r,sigma,tau,V);
	d2			= BSCallEuroD2(X,r,sigma,tau,V);

	% Calculate price of option
	BSCallEuro	= V.*N(d1) - X*exp(-r*tau).*N(d2);
% 	end

	%%%
	%%% End european call option pricing logic %%%
	%%%
	
	
	%%%
	%%% Begin private methods %%%
	%%%
	
	%--------------------------------------------------------------------------
	% @description: Corresponds to LiWong2008 Appendix B definition of 
	%				Black-Scholes standard call option model parameter d1
	%--------------------------------------------------------------------------
	function outBSCED1 = BSCallEuroD1(X,r,sigma,tau,V)
		outBSCED1 = (log(V/X) + tau.*(r+0.5*sigma^2))./(sqrt(tau).*sigma);
	end


	%--------------------------------------------------------------------------
	% @description: Corresponds to LiWong2008 Appendix B definition of 
	%				Black-Scholes standard call option model parameter d2.
	%				N(d2) = Risk neutral probability of achieving strike price.
	% @see:			http://www.bionicturtle.com/forum/viewthread/464/
	%--------------------------------------------------------------------------
	function outBSCED2 = BSCallEuroD2(X,r,sigma,tau,V)
		outBSCED2 = (log(V/X) + (r-0.5*sigma^2)*tau)./(sigma*sqrt(tau));
	end
end







