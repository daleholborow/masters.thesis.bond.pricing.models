function PredictCouponBondPricesByMonthlyDates()
%----------------------------------------------------------------------
% @description:	Specify a broad band of end-of-month dates, over several
%				years, and trigger
%				bond price estimate for each firm accordingly.
%----------------------------------------------------------------------

	const		= Constants();
	
	maxDist = 14;
	tryToPriceDtNums = [];
	
	for yrInd = 2002 : 1 : 2008
		for mnthInd = 1 : 1 : 12
			% We wish to loop through several years, pricing each
			% firm's bond as close to the end of each month that we 
			% can do so. Calculate the end day of each month:
			eom		= eomday(yrInd, mnthInd);
			tryToPriceDtNum	= datenum([num2str(eom) '/' num2str(mnthInd) '/' num2str(yrInd)], const.DateStringAU);
			
			tryToPriceDtNums(end+1) = tryToPriceDtNum;
		end
	end
	
	PredictCouponBondPricesByDates(tryToPriceDtNums,maxDist);
end