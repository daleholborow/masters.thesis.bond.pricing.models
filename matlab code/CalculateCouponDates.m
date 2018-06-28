function [CouponDates] = CalculateCouponDates(issDateNum, matDateNum, couponDateStr)
%----------------------------------------------------------------------
% @description:	Based on a string containing two embedded coupon date
%				day/month pairs, parse that string and extract the
%				values so that we can calculate on which days the
%				coupons land. Store a collection of all the dates that
%				the bond will pay coupons.
%----------------------------------------------------------------------
	paths		= PathInfo();
	const		= Constants();
	
	issDateVec		= datevec(issDateNum);
	matDateVec		= datevec(matDateNum);

	% Store all coupons calculated between the issue and maturity date
	% range.
	CouponDates		= [];

% 	len				= length(couponDateStr);
% 	coup2MStr		= couponDateStr(1,len-1:len);
% 	coup2DStr		= couponDateStr(1,len-3:len-2);
% 	coup1MStr		= couponDateStr(1,len-5:len-4);
	coup2MStr		= couponDateStr(1,end-1:end);
	coup2DStr		= couponDateStr(1,end-3:end-2);
	coup1MStr		= couponDateStr(1,end-5:end-4);
	% Some date strings are passed in as a 7 digit string instead of 8
	if 8 == length(couponDateStr)
		spacer = 2;
	else
		spacer = 1;
	end
	coup1DStr		= couponDateStr(1,(1:spacer));

	% For each year in the range of the bond life, calculate a first
	% and second coupon date, and if they are within the issue and
	% maturity date, add them to the collection.
	for yrInd = issDateVec(1) : 1 : matDateVec(1)
		yrStr	= num2str(yrInd);
		coupon1Num	= datenum(datestr([coup1DStr '/' coup1MStr '/' yrStr], const.DateStringAU));
		coupon2Num	= datenum(datestr([coup2DStr '/' coup2MStr '/' yrStr], const.DateStringAU));

		% If the calculated coupon dates are valid, add them
		if coupon1Num > issDateNum && coupon1Num <= matDateNum
			CouponDates(end+1) = coupon1Num;
		end
		if coupon2Num > issDateNum && coupon2Num <= matDateNum
			CouponDates(end+1) = coupon2Num;
		end
	end
end