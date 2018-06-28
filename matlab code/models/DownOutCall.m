function [downOutCall] = DownOutCall(H,r0,R,sigma,tau,V,X)
%--------------------------------------------------------------------------
% @description: Down and Out Call option pricing formula as presented by Li
%				and Wong in their 2008 paper "Structural models of corporate 
%				bond pricing with maximum likelihood estimation". 
%				Specifically, see that paper, Appendix C.
% @params:
%	H			- The barrier level.
%	r0			- The instantaneous risk-free interest rate.
%	R			-Rebate paid to equity holders in the event of default (i.e.
%				asset value falls below the default barrier level H).
%	sigma		- Volatility (as std. deviation) of asset process. Constant
%				throughout time.
%	tau			- The time to maturity
%	V			- The (market) value of the assets upon which the call is 
%				being written. 
%	X			- The future promised payment (e.g.: face value of bond)
%--------------------------------------------------------------------------
	
	% Perform data cleaning. For example, many parameters cannot be set to
	% be exactly zero lest we get Divide-By-Zero errors, so before we begin
	% any calculations, clean those values now:
	H		= ZeroClean(H);
	sigma	= ZeroClean(sigma);
	V		= ZeroClean(V);
	X		= ZeroClean(X);
	tau		= ZeroClean(tau);
	
	% Calculate model placeholder parameters once here for slight increase 
	% in efficiency and clarity of notation.
	docA	= DownOutCallA(H,r0,sigma,tau,V,X);
	docB	= DownOutCallB(H,r0,sigma,tau,V,X);
	docC	= DownOutCallC(H,r0,sigma,tau,V);
	docEta	= DownOutCallEta(r0, sigma);
	
	% Calculate price of down-and-out call option
	downOutCall = V*N(docA) - X*exp(-r0*tau)*N(docA-sigma*sqrt(tau)) - ...
		V*(H/V)^(2*docEta)*N(docB) + ...
		X*exp(-r0*tau)*(H/V)^(2*docEta - 2)*N(docB - sigma*sqrt(tau)) + ...
		R*(H/V)^(2*docEta - 1)*N(docC) + ...
		R*(V/H)*N(docC - 2*docEta*sigma*sqrt(tau));
	
	% Finally, catch the instances where the above formula would generate a
	% negative price, when in fact, it should have a floor of zero:
	downOutCall = max(downOutCall,0);
	
	%%% End down-out-call main logic %%%
end








