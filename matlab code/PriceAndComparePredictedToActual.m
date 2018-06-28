function [PredictedBondPrice PredictedYield ActualBondPrice ActualYield] = PriceAndComparePredictedToActual(estimMode,actualPriceDtNum,firm,vasParams,rr_c,rr_p)
%----------------------------------------------------------------------
% @description:	PriceAndComparePredictedToActual
%				For any particular pricing methodology, calculate the
%				implied and actual price/yields, for comparison
%----------------------------------------------------------------------

	[PredictedBondPrice	PredictedYield] = PredictCouponBondPrice(estimMode,actualPriceDtNum,firm,vasParams,rr_c,rr_p);

	%
	% Now, retrieve the actual observed bond price and the implied
	% yield, and we can compare the two. 
	%

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


