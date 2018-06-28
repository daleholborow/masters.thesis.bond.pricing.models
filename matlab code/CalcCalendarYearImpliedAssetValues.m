function [ImplAssetVals] = CalcCalendarYearImpliedAssetValues(estimMode,vasParams,firm,estimYr,mu,sigma)
	
	paths		= PathInfo();
	const		= Constants();

	% For a given parameter set, and a collection of observed
	% market prices of equity, calculate the implied asset value at
	% each point in time, treating the end of the year being estimated as the 
	% time of maturity of the equity-as-an-option.
	
	% We MUST loop through and calculate each implied asset value for each
	% daily observation individually, because the fzero optimisation can only 
	% receive scalar values as input!
	
	% Establish the start and end dates of the year we intend to analyse
	estimYrStartNum	= datenum(['01/01/' num2str(estimYr)], const.DateStringAU);
	estimYrEndNum	= datenum(['31/12/' num2str(estimYr)], const.DateStringAU);
	
	% To perform asset estimation, we need to know how many shares there
	% are, and also the total liabilities. For these, we need to turn to
	% the end-of-year report from the year PRIOR to our estimation year:
	priorYr			= estimYr-1;
	priorYrFinObs	= get(firm.Financials, priorYr);
	
	
	% Store all the calculated values in a hashtable. That way we never
	% have to worry about remembering whether values are indexed in chrono 
	% order etc, as we would if we used arrays
	ImplAssetVals = hashtable;
	
	% MUST calculate maturities IN YEARS, because all our volatility and
	% drift params are specified on a yearly basis!! Decide how many
	% days are in this year.
	daysInEstimYear = DaysInYear(estimYr);
	
	
	% Loop through each day within the year period specified, and based on
	% the asset dynamics parameters (mu and sigma) specified, calculate the
	% implied asset values under the Merton model:
	
	% Don't estimate the assets on the final day, since the time to expiry
	% of the equity-as-an-option is zero and thus worthless.
	for dayInd = estimYrStartNum : 1 : (estimYrEndNum-1)
		
		% Only estimate the asset values if there are share
		% price and interest rate observations:
		if has_key(firm.Equity, dayInd) && has_key(vasParams, dayInd)
			
			% Time to maturity (i.e. time till end of year)
			tau					= (estimYrEndNum - dayInd)/daysInEstimYear;
			
			% Get interest rate params estimated based on daily term
			% structure
			dailyVasParams		= get(vasParams,dayInd);
			
			% Get the share price observation data for that day
			dailyEqtyObs		= get(firm.Equity, dayInd);
			equityVal			= dailyEqtyObs.AdjClose *  priorYrFinObs.OutStShares;
			
			% Calculate implied asset values according to merton model
			if strcmp(const.ModeMerton, estimMode)
				
				dailyImplAssetVal	= ImpliedAssetValueBlackScholes(...
					priorYrFinObs.TotLiab, ...
					mu, ...
					dailyVasParams.r0, ...
					sigma, ...
					equityVal, ...
					tau);
% 				disp('calcing merton');
			
			% Calculate implied asset values according to Longstaff&Schwartz model
			elseif strcmp(const.ModeLS, estimMode)
				
				dailyImplAssetVal	= ImpliedAssetValueDownAndOutCall(...
					priorYrFinObs.TotLiab, ...
					mu, ...
					dailyVasParams.r0, ...
					sigma, ...
					equityVal, ...
					tau);
% 				disp('calcing ls');
				
			else
				error(['Died: Undetected asset estimation method detected']);
			end
			
			% Add the implied asset valuation into a hash, ready to be
			% returned
			ImplAssetVals = put(ImplAssetVals, dayInd, dailyImplAssetVal);
		end		
	end
	
end
















