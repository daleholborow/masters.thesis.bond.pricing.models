function PredictCouponBondPricesAtIssue()
%--------------------------------------------------------------------------
% @description:	PredictCouponBondPricesAtIssue
%				For the bond as close as possible to the issue date (within
%				a month, or it fails), perform pricing estimations and
%				save to a firm-specific file.
%--------------------------------------------------------------------------
	
	% Predict the bond prices at issue
	PredictCouponBondPricesByDates();
	
	% Make sure that our csv copy is up to date
	TabulateBondYieldsAtIssue();
	
end











