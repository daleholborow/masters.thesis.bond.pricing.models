function PredictCouponBondPricesByDates(targetPriceDtNums,maxDist)
%-----------------------------------------------------------------------
% @description:	
%		Given an array of dates that we wish to price all our bonds on,
%		loop through all firms and calculate our predictions using each 
%		different model and save the updated firm data binaries.
% @note:
%		If no parameters are passed in, the logic defaults to pricing the 
%		bonds as close as possible to the date of issue.
%-----------------------------------------------------------------------

	const		= Constants();
	paths		= PathInfo();
	
	% Load all precalculated Vasicek interest rate model parameters so we
	% can use the instantaneous spot rates in our estimation of asset
	% dynamics.
	vasParams	= ParseInterestRateParamsVasicek();
	
	% Set up the recovery rates on the coupons and face values. In this
	% way, we add/remove risk from the bond pricing....
	rr_c		= const.RecoveryRateCoupons;
	rr_p		= const.RecoveryRateFaceValue;
	
	% Retrieve all the preliminary details about all the firms for whom we
	% wish to perform bond pricing:
	firms = ParseCompanyList();
	
	for firm_i = 1 : 1 : length(firms)
		% For each firm, we need to get the bond name as it was stored in
		% the csv, but then we will load up the ENTIRE firm/bond/financials
		% data which was saved by a previous precalculation process.
		tmpFirm	= firms(firm_i);
		load([paths.PreCalcFirmHistory tmpFirm.Bond.DSBondCode], 'firm');
		clear tmpFirm;

		
		if nargin == 0
			disp('No datenums to price bond at specified, default to issue date!');
			targetPriceDtNums = [firm.Bond.IssueDateNum];
			maxDist = 40;
		end
		
		
		% Now, loop through all the intended targeting dates and predict
		% bond prices for each date, for each model.
		for targetDate_i = 1 : 1 : length(targetPriceDtNums)
			
			disp(' ');
			disp(['Begin processing firm ' firm.CompName]);
			tryToPriceDtNum = targetPriceDtNums(targetDate_i);
			trytopriceon = datestr(tryToPriceDtNum)
			
			try
				% Search into the future, one day at a time
				moveDaysBy			= 1;
				actualPriceDtNum	= CalcClosestPossibleValuationDate(firm,vasParams, tryToPriceDtNum, moveDaysBy, maxDist);
				actualPriceDtStr	= datestr(actualPriceDtNum, const.DateStringAU);
				
				if ~isfield(firm.Bond, 'PredBondPricesPPM')
					firm.Bond.PredBondPricesPPM = hashtable;
				end
				estimMode = const.ModePureProxyM;
				disp(['Estimating: ' estimMode]);
				[PredictedBondPrice	PredictedYield] = PredictCouponBondPriceAndYield(estimMode,actualPriceDtNum,firm,vasParams,rr_c,rr_p)
				firm.Bond.PredBondPricesPPM = put(firm.Bond.PredBondPricesPPM,actualPriceDtNum,PredictedBondPrice);
				
				if ~isfield(firm.Bond, 'PredBondPricesM')
					firm.Bond.PredBondPricesM = hashtable;
				end
				estimMode = const.ModeMerton;
				[PredictedBondPrice	PredictedYield] = PredictCouponBondPriceAndYield(estimMode,actualPriceDtNum,firm,vasParams,rr_c,rr_p)
				firm.Bond.PredBondPricesM = put(firm.Bond.PredBondPricesM,actualPriceDtNum,PredictedBondPrice);
				
				if ~isfield(firm.Bond, 'PredBondPricesPPLS')
					firm.Bond.PredBondPricesPPLS = hashtable;
				end
				estimMode = const.ModePureProxyLS;
				disp(['Estimating: ' estimMode]);
				[PredictedBondPrice	PredictedYield] = PredictCouponBondPriceAndYield(estimMode,actualPriceDtNum,firm,vasParams,rr_c,rr_p)
				firm.Bond.PredBondPricesPPLS = put(firm.Bond.PredBondPricesPPLS,actualPriceDtNum,PredictedBondPrice);
				
				if ~isfield(firm.Bond, 'PredBondPricesLS')
					firm.Bond.PredBondPricesLS = hashtable;
				end
				estimMode = const.ModeLS;
				[PredictedBondPrice	PredictedYield] = PredictCouponBondPriceAndYield(estimMode,actualPriceDtNum,firm,vasParams,rr_c,rr_p)
				firm.Bond.PredBondPricesLS = put(firm.Bond.PredBondPricesLS,actualPriceDtNum,PredictedBondPrice);
				
				if ~isfield(firm.Bond, 'PredBondPricesRF')
					firm.Bond.PredBondPricesRF = hashtable;
				end
				estimMode = const.ModeVasicek;
				[PredictedBondPrice	PredictedYield] = PredictCouponBondPriceAndYield(estimMode,actualPriceDtNum,firm,vasParams,rr_c,rr_p);
				firm.Bond.PredBondPricesRF = put(firm.Bond.PredBondPricesRF,actualPriceDtNum,PredictedBondPrice);
				
			catch
				disp('Some error in the pricing attempts, just ignore and continue pricing attempts.');
			end
		end
		
		% Finally, save the individual firm objects as matlab binary files
		% so they can be retrieved very quickly in future.
		save([paths.PreCalcFirmHistory firm.Bond.DSBondCode], 'firm');
	end
end














