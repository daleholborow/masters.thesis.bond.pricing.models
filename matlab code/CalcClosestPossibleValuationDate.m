function [actualPriceDtNum] = CalcClosestPossibleValuationDate(firm, ...
		vasParams, tryToPriceDtNum, increment, maxDist)
%----------------------------------------------------------------------
% @description:	CalcClosestPossibleValuationDate
%	We wish to price the bond as early as possible on or after its date of
%	issue. To test whether pricing is possible for a particular date, we
%	test that we have:
%	a) Observed equity prices for that date
%	b) Calculated instantaneous interest rate (and additional params) on 
%	that date
%	c) An observed bond price on that date
%	d) Asset dynamics parameter estimates for the financial year prior
%	to pricing:
% @params:
%	firm		-
%	vasParams	-
%	tryToPriceDtNum- Initial target date that we want to try to perform
%		some pricing functionality. Search around this date for the
%		first day where we have all the necessary interest rate,
%		bond price, equity price etc, data, to be able to perform
%		pricing logic.
%	increment	- The number of days to move when trying to search for
%		dates. Typically, a date will be specified which we will
%		try to price, and if we can't price on that intented date
%		because of a lack of data, increment=+1 means we will try
%		the FOLLOWING day. increment=-1 means try the PREVIOUS day.
%----------------------------------------------------------------------
	found		= false;
% 	currDist	= 0;
	tryDtNum	= tryToPriceDtNum;


	% To perform asset estimation, we need to know how many shares there
	% are, and also the total liabilities. For these, we need to turn to
	% the end-of-year report from the year PRIOR to our estimation year:
	prevYr			= year(tryToPriceDtNum)-1;

	while ~found & abs(tryDtNum-tryToPriceDtNum) < maxDist

% 			datestr(tryDtNum)
% 			hasvas = has_key(vasParams, tryDtNum)
% 			haseq = has_key(firm.Equity, tryDtNum)
% 			hasbp = has_key(firm.Bond.Prices, tryDtNum)
% 			hasfin = has_key(firm.Financials, prevYr)

		if has_key(vasParams, tryDtNum) & ...
				has_key(firm.Equity, tryDtNum) & ...
				has_key(firm.Bond.Prices, tryDtNum) & ...
				has_key(firm.Financials, prevYr)

			% The date being tested has all the information we need to
			% perform a bond price test, so use that date.
			actualPriceDtNum = tryDtNum;
			found = true;
		end

% 		currDist = currDist + 1;
		tryDtNum = tryDtNum+increment;
	end

	if ~found
		error(['Could not find a suitable pricing date within range of : ' datestr(tryToPriceDtNum)]);
	end
end




