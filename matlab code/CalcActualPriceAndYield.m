function [ActualBondPrice ActualYield] = CalcActualPriceAndYield(actualPriceDtNum,firm)
%----------------------------------------------------------------------
% @description:	CalcActualPriceAndYield
%				Calculate the actual price/yields for a particular bond
%				based on market observations of its price on a particular
%				date. That way, we can calculate the implied yield to
%				maturity also.
%----------------------------------------------------------------------

	% Retrieve the actual observed bond price and the implied
	% yield

	% Since for testing purposes, all
	% bonds are priced as though they have a unit payoff, and our close
	% closes are stored similarly, we set the face value of the bond to
	% equal 1 when calculating yields.
	faceVal				= 1;

	% Calculate the remaining coupon payment times, so we can solve for
	% yield
	remMrktTaus	= CalcRemainingCouponTausInYrs(actualPriceDtNum, firm.Bond.CouponDateNums);

	% Calculate actual bond price and subsequent yield to compare with
	% our above predictions.
	bondPriceObs		= get(firm.Bond.Prices, actualPriceDtNum);
	ActualYield			= CalcImpliedYield(...
		faceVal,...
		firm.Bond.CouponRate,...
		remMrktTaus,...
		bondPriceObs.ClosePrice);
	ActualBondPrice = bondPriceObs.ClosePrice;
end


