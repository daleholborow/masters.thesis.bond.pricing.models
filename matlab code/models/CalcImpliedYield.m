function [ImpliedYield] = CalcImpliedYield(faceVal,coupon,taus,bondPrice)
%--------------------------------------------------------------------------
% @description:	CalculateImpliedYield
%				Based on some observed or predicted bond price, and values
%				for the remaining coupon and face value payment rates and
%				maturities, calculate the implied bond yield which would
%				produce that bond price.
% @params:		
%	
% @example:
%				coupon	= 0.05;
%				taus	= [1/2 : 1/2 : 10];
%				faceVal	= 100;
%				bondPrice	= 97;
%				implYield = CalcImpliedYield(faceVal,coupon,taus,bondPrice)
%--------------------------------------------------------------------------
	
	% Min and max boundaries of our search, expect realistic values to be
	% between 0 and 0.15...
	minYield	= 0;
	maxYield	= 0.5;
	ImpliedYield = fminbnd(@(yieldGuess) SeekForYield(yieldGuess,coupon,taus,bondPrice,faceVal),minYield,maxYield);
	
	
	%----------------------------------------------------------------------
	% @description:	SeekForYield
	%				Method to use to search for optimum implied yield given
	%				an observed bond price, coupon rate, and maturity
	%				dates.
	%----------------------------------------------------------------------
	function [yieldError] = SeekForYield(yieldGuess,coupon,taus,targetPrice,faceVal)

		% Calculate implied present value of all coupons using current yield
		% guess:
		implPresVal = 0.5 * coupon * faceVal * exp(-yieldGuess*taus);

		% Calculate also the present value of the fave value payment using the
		% current yield guess:
		matTau		= taus(end);
		implPresVal(end+1) = faceVal * exp(-yieldGuess*matTau);

		% Implied price given a particular yield is the sum of the present 
		% value of all coupons and the face value payment.
		implPrice	= sum(implPresVal);

		% Calculate the difference between the implied price and the observed
		% price, to find the optimal implied yield.
		yieldError = abs(implPrice - targetPrice);
	end
end






