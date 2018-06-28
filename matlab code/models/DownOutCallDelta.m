function [docDelta] = DownOutCallDelta(H,r0,R,sigma,tau,V,X)
%--------------------------------------------------------------------------
% @description: DownOutCallDelta
%				Calculate the delta of a Down and Out Call option using 
%				pricing formula as presented by Li
%				and Wong in their 2008 paper "Structural models of corporate 
%				bond pricing with maximum likelihood estimation". 
%				Specifically, see that paper, Appendix C.
% @params:
%	H			- The barrier level at which default occurs.
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
	
	% Precalculate model placeholder parameters once here for increase 
	% in efficiency and clarity of notation.
	docA	= DownOutCallA(H,r0,sigma,tau,V,X);
	docB	= DownOutCallB(H,r0,sigma,tau,V,X);
	docC	= DownOutCallC(H,r0,sigma,tau,V);
	nu		= DownOutCallNu(r0, sigma);
		
% 	partA		= N(docA) + V*normpdf(docA,0,1)/(V*sigma*sqrt(tau));
% 	partB		= X*exp(-r0*tau)*normpdf(docA-sigma*sqrt(tau),0,1)/(V*sigma*sqrt(tau));

	partA		= N(docA);
	partB		= 0;
	
	partC		= (-2*nu+1)*(H/V)^(2*nu)*N(docB) - ...
		normpdf(docB)*(H/V)^(2*nu)/(sigma*sqrt(tau));
	partD		= (-2*nu+2)*X*exp(-r0*tau)*(H/V)^(2*nu-1)/H*N(docB-sigma*sqrt(tau)) + ...
		(X*exp(-r0*tau)*(H/V)^(2*nu-2)*(-normpdf(docB-sigma*sqrt(tau))/(V*sigma*sqrt(tau))));
	partE		= (-2*nu+1)*R*(H/V)^(2*nu)/H*N(docC) + ...
		R*(H/V)^(2*nu-1)*(-normpdf(docC)/(V*sigma*sqrt(tau)));
	partF		= R/H*N(docC-2*nu*sigma*sqrt(tau)) + R*V/H*(-normpdf(docC-sigma*2*nu*sqrt(tau))/(V*sigma*sqrt(tau)));
	
	docDelta	= partA - partB - partC + partD + partE + partF;	
end














