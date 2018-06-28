function [discBondYields] = CalcDiscountBondYield(taus,bondPrices)
%--------------------------------------------------------------------------
% @description:	Calculate the yield-to-maturity of zero-coupon discount
%				bond(s). Pricing coupon bonds is a more complex procedure.
%				Can price yield SPREADS by calling function along the lines
%				of:
%				yieldSpread = DiscBondYield(taus,(riskyBP/riskFreeBP)).
%				This allows us to derive the term structure of default 
%				spreads. Refer to Briys 
%				and de Varenne's 1997 paper, Section 4, Equation 12.
%				Calculates the difference between the yield of a risky
%				corporate bond and a risk-free bond of equivalent maturity.
%				This calculation is only valid for zero-coupon discount
%				bonds, the presence of coupons means yield calculations are
%				more complex.
% @params:
%	taus		- Matrix of times to maturity for which we are calculating 
%				the yield-to-maturity under some interest rate model. 
%				Must be a 1*n or an n*1 matrix... m*n will cause irregular 
%				results.
%	bondPrices	- The n*1 or 1*n matrix of bond prices of zero-coupon bonds for 
%				which we determining the yield-to-maturity. 
% @example:		
%				taus = [0 : 0.1 : 10];
%				params.r		= 0.09;
% 				params.nu		= 0.03;
% 				params.theta	= 0.06;
% 				params.kappa	= 0.2;
%				bondPrices		= VasicekUnitDiscBond(taus,params);
%				yields			= DiscBondYield(taus,bondPrices)
% @author:		
%--------------------------------------------------------------------------


	% Perform data cleaning. For example, many parameters cannot be set to
	% be exactly zero lest we get Divide-By-Zero errors, so before we begin
	% any calculations, clean those values now:
	bondPrices	= ZeroClean(bondPrices);
	taus		= ZeroClean(taus);
	
	% Note: As per Hull, Chapter 23, P538, if R(t,T) is the continuously
	% compounded interest rate at time t for a term T-t, (i.e. R(t,T) is 
	% the yield-to-maturity, NOT the instantaneous rate) then:
	% R(t,T) = - (1 / (T-t)) * log(BondPrice(t,T)).
	discBondYields = (-taus.^(-1)).*log(bondPrices);
end


