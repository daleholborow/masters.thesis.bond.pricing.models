function TabulateAggregateHistoricPerformance()
	clc;
	clear all;
	const		= Constants();
	paths		= PathInfo();
	
	% Load all precalculated Vasicek interest rate model parameters so we
	% can use the instantaneous spot rates in our estimation of asset
	% dynamics.
	vasParams		= ParseInterestRateParamsVasicek();
	
	bondPricesPPM	= [];
	bondPricesM		= [];
	bondPricesPPLS	= [];
	bondPricesLS	= [];
	bondPricesAct	= [];
	bondPricesRF	= [];
	
	bondYieldsPPM	= [];
	bondYieldsM		= [];
	bondYieldsPPLS	= [];
	bondYieldsLS	= [];
	bondYieldsAct	= [];
	bondYieldsRF	= [];
	
	% Retrieve all the preliminary details about all the firms for whom we
	% wish to perform bond pricing:
	firms = ParseCompanyList();
	for firm_i = 1 : 1 : length(firms)
		% For each firm, we need to get the bond name as it was stored in
		% the csv, but then we will load up the ENTIRE firm/bond/financial
		% data which was saved by a previous precalculation process.
		tmpFirm	= firms(firm_i);
		load([paths.PreCalcFirmHistory tmpFirm.Bond.DSBondCode], 'firm');
		clear tmpFirm;
		
% 		if firm_i == 3
% 			break;
% 		end

		disp(' ');
		disp(['Begin processing firm ' firm.CompName]);
		
		for yrInd = 2002 : 1 : 2008
			for mnthInd = 1 : 1 : 12
				% We wish to loop through several years, pricing each
				% firm's bond as close to the end of each month that we 
				% can do so. Calculate the end day of each month:
				eom		= eomday(yrInd, mnthInd);
				tryToPriceDtNum	= datenum([num2str(eom) '/' num2str(mnthInd) '/' num2str(yrInd)], const.DateStringAU);

				try
					% Search into the future, one day at a time
					moveDaysBy			= 1;
					maxDist					= 14;
					actualPriceDtNum	= CalcClosestPossibleValuationDate(firm,vasParams, tryToPriceDtNum, moveDaysBy, maxDist);
					actualPriceDtStr	= datestr(actualPriceDtNum, const.DateStringAU);
					
					[remMrktTaus] = CalcRemainingCouponTausInYrs(actualPriceDtNum, firm.Bond.CouponDateNums);
					faceVal				= 1;
					coupon				= firm.Bond.CouponRate;

					bondPricePPM = get(firm.Bond.PredBondPricesPPM, actualPriceDtNum);
					impliedYieldPPM = CalcImpliedYield(faceVal,coupon,remMrktTaus,bondPricePPM);
					bondPriceM	= get(firm.Bond.PredBondPricesM, actualPriceDtNum);
					impliedYieldM = CalcImpliedYield(faceVal,coupon,remMrktTaus,bondPriceM);
					bondPricePPLS = get(firm.Bond.PredBondPricesPPLS, actualPriceDtNum);
					impliedYieldPPLS = CalcImpliedYield(faceVal,coupon,remMrktTaus,bondPricePPLS);
					bondPriceLS	= get(firm.Bond.PredBondPricesLS, actualPriceDtNum);
					impliedYieldLS = CalcImpliedYield(faceVal,coupon,remMrktTaus,bondPriceLS);
					[bondPriceAct impliedYieldAct] = CalcActualPriceAndYield(actualPriceDtNum,firm);
					bondPriceRF	= get(firm.Bond.PredBondPricesRF, actualPriceDtNum);
					impliedYieldRF = CalcImpliedYield(faceVal,coupon,remMrktTaus,bondPriceRF);
					
					bondPricesPPM(end+1)	= bondPricePPM;
					bondPricesM(end+1)		= bondPriceM;
					bondPricesPPLS(end+1)	= bondPricePPLS;
					bondPricesLS(end+1)		= bondPriceLS;
					bondPricesAct(end+1)	= bondPriceAct;
					bondPricesRF(end+1)		= bondPriceRF;
					
					bondYieldsPPM(end+1)	= impliedYieldPPM;
					bondYieldsM(end+1)		= impliedYieldM;
					bondYieldsLS(end+1)		= impliedYieldLS;
					bondYieldsPPLS(end+1)	= impliedYieldPPLS;
					bondYieldsAct(end+1)	= impliedYieldAct;
					bondYieldsRF(end+1)		= impliedYieldRF;
				catch
% 						lasterr
% 					disp('Couldn''t find price within range, ignore and continue processing');
				end
			end
		end
	end
	
	
	% Calculate pricing errors
	err_price_ppM		= (bondPricesPPM - bondPricesAct)./bondPricesAct;
	err_price_mleM	= (bondPricesM - bondPricesAct)./bondPricesAct;
	err_price_ppLS	= (bondPricesPPLS - bondPricesAct)./bondPricesAct;
	err_price_mleLS = (bondPricesLS - bondPricesAct)./bondPricesAct;
	% Calculate pricing error mean and std dev:
	err_price_ppM_m			= mean(err_price_ppM);
	err_price_ppM_std		= std(err_price_ppM);
	err_price_mleM_m		= mean(err_price_mleM);
	err_price_mleM_std	= std(err_price_mleM);
	err_price_ppLS_m		= mean(err_price_ppLS);
	err_price_ppLS_std	= std(err_price_ppLS);
	err_price_mleLS_m		= mean(err_price_mleLS);
	err_price_mleLS_std	= std(err_price_mleLS);
	
	% Calculate yield errors
	err_yield_ppM		= (bondYieldsPPM - bondYieldsAct)./bondYieldsAct;
	err_yield_mleM	= (bondYieldsM - bondYieldsAct)./bondYieldsAct;
	err_yield_ppLS	= (bondYieldsPPLS - bondYieldsAct)./bondYieldsAct;
	err_yield_mleLS = (bondYieldsLS - bondYieldsAct)./bondYieldsAct;
	% Calculate pricing error mean and std dev:
	err_yield_ppM_m			= mean(err_yield_ppM);
	err_yield_ppM_std		= std(err_yield_ppM);
	err_yield_mleM_m		= mean(err_yield_mleM);
	err_yield_mleM_std	= std(err_yield_mleM);
	err_yield_ppLS_m		= mean(err_yield_ppLS);
	err_yield_ppLS_std	= std(err_yield_ppLS);
	err_yield_mleLS_m		= mean(err_yield_mleLS);
	err_yield_mleLS_std	= std(err_yield_mleLS);
	
	% Calculate yield diffs
	diff_yield_ppM		= (bondYieldsPPM - bondYieldsAct);
	diff_yield_mleM		= (bondYieldsM - bondYieldsAct);
	diff_yield_ppLS		= (bondYieldsPPLS - bondYieldsAct);
	diff_yield_mleLS	= (bondYieldsLS - bondYieldsAct);
	% Calculate yield diff mean and std
	diff_yield_ppM_m		= mean(diff_yield_ppM);
	diff_yield_ppM_std	= std(diff_yield_ppM);
	diff_yield_mleM_m		= mean(diff_yield_mleM);
	diff_yield_mleM_std	= std(diff_yield_mleM);
	diff_yield_ppLS_m			= mean(diff_yield_ppLS);
	diff_yield_ppLS_std		= std(diff_yield_ppLS);
	diff_yield_mleLS_m		= mean(diff_yield_mleLS);
	diff_yield_mleLS_std	= std(diff_yield_mleLS);
	
	% Now output the results in a format that we can copy and paste easily
% 	disp('Merton values');
% 	% Merton prices
% 	disp_err_price_ppM_m		= [num2str(err_price_ppM_m*100,4) '%'];
% 	disp_err_price_ppM_std	= [num2str(err_price_ppM_std*100,4) '%'];
% 	disp_err_price_mleM_m		= [num2str(err_price_mleM_m*100,4) '%'];
% 	disp_err_price_mleM_std	= [num2str(err_price_mleM_std*100,4) '%'];
% 	% Merton yields
% 	disp_err_yield_ppM_m		= [num2str(err_yield_ppM_m*100,4) '%'];
% 	disp_err_yield_ppM_std	= [num2str(err_yield_ppM_std*100,4) '%'];
% 	disp_err_yield_mleM_m		= [num2str(err_yield_mleM_m*100,4) '%'];
% 	disp_err_yield_mleM_std	= [num2str(err_yield_mleM_std*100,4) '%'];
% 	% Merton yield differences
% 	disp_diff_yield_ppM_m		= [num2str(diff_yield_ppM_m*100,4) '%'];
% 	disp_diff_yield_ppM_std	= [num2str(diff_yield_ppM_m*100,4) '%'];
% 	disp_diff_yield_mleM_m		= [num2str(diff_yield_mleM_m*100,4) '%'];
% 	disp_diff_yield_mleM_std	= [num2str(diff_yield_mleM_m*100,4) '%'];
% 	
% 	disp('LS values');
% 	% Longstaff and schwartz prices
% 	disp_err_price_ppLS_m		= [num2str(err_price_ppLS_m*100,4) '%'];
% 	disp_err_price_ppLS_std	= [num2str(err_price_ppLS_std*100,4) '%'];
% 	disp_err_price_mleLS_m		= [num2str(err_price_mleLS_m*100,4) '%'];
% 	disp_err_price_mleLS_std	= [num2str(err_price_mleLS_std*100,4) '%'];
% 	% Longstaff and schwartz yields
% 	disp_err_yield_ppLS_m		= [num2str(err_yield_ppLS_m*100,4) '%'];
% 	disp_err_yield_ppLS_std	= [num2str(err_yield_ppLS_std*100,4) '%'];
% 	disp_err_yield_mleLS_m		= [num2str(err_yield_mleLS_m*100,4) '%'];
% 	disp_err_yield_mleLS_std	= [num2str(err_yield_mleLS_std*100,4) '%'];
% 	% Longstaff and schwartz yield differences
% 	disp_diff_yield_ppLS_m		= [num2str(diff_yield_ppLS_m*100,4) '%'];
% 	disp_diff_yield_ppLS_std	= [num2str(diff_yield_ppLS_m*100,4) '%'];
% 	disp_diff_yield_mleLS_m		= [num2str(diff_yield_mleLS_m*100,4) '%'];
% 	disp_diff_yield_mleLS_std	= [num2str(diff_yield_mleLS_m*100,4) '%'];
	
	displayM(1,1:3) = [err_price_ppM_m err_yield_ppM_m diff_yield_ppM_m];
	displayM(1,4:6) = [err_price_mleM_m err_yield_mleM_m diff_yield_mleM_m];
	displayM(2,1:3) = [err_price_ppM_std err_yield_ppM_std diff_yield_ppM_std];
	displayM(2,4:6) = [err_price_mleM_std err_yield_mleM_std diff_yield_mleM_std];
	
	displayM = displayM*100
	
	displayLS(1,1:3) = [err_price_ppLS_m err_yield_ppLS_m diff_yield_ppLS_m];
	displayLS(1,4:6) = [err_price_mleLS_m err_yield_mleLS_m diff_yield_mleLS_m];
	displayLS(2,1:3) = [err_price_ppLS_std err_yield_ppLS_std diff_yield_ppLS_std];
	displayLS(2,4:6) = [err_price_mleLS_std err_yield_mleLS_std diff_yield_mleLS_std];
	
	displayLS = displayLS*100
	
end










