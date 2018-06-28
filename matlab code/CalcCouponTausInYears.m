function [mrktTaus] = CalcCouponTausInYears(startDtNum, couponDtNums)
%--------------------------------------------------------------------------
% @description:	CalcCouponTausInYears
%				Calculate the time remaining until maturity for each coupon
%				in the bond. The face value will also occur at the longest
%				maturity, but is not stored as an additional element in the
%				vector.
% @params:
%	startDtNum	-
%	couponDtNums- 
%--------------------------------------------------------------------------
	[mrktTaus] = [couponDtNums - startDtNum] / 365;
end