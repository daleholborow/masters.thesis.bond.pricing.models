function [remMrktTaus] = CalcRemainingCouponTausInYrs(startDtNum, couponDtNums)
	mrktTaus = CalcCouponTausInYears(startDtNum, couponDtNums);
	
	% Return only coupon dates which are still outstanding after the
	% observation start date at which time we are trying to price the
	% bond
	remMrktTaus	= mrktTaus(find(mrktTaus > 0));
end