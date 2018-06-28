function CalculateAndStorePureProxyDynamics()
%----------------------------------------
% Patch, to fix bug in the calculation of M and LS rho values, and to also
% calculate Pure Proxy mean, std and rho values, which wasnt done earlier.
%----------------------------------------

% 	tic;
% 	clc;
% 	clear all;
	const		= Constants();
	paths		= PathInfo();
	
	% Load all precalculated Vasicek interest rate model parameters so we
	% can use the instantaneous spot rates in our estimation of asset
	% dynamics.
	vasParams		= ParseInterestRateParamsVasicek();
	
	
	% Retrieve all the preliminary details about all the firms for whom we
	% wish to perform bond pricing:
	firms = ParseCompanyList();
	
	for firm_i = 1 : 1 : length(firms)
		
% 		if firm_i == 2
% 			break;
% 		end
		
		% For each firm, we need to get the bond name as it was stored in
		% the csv, but then we will load up the ENTIRE firm/bond/financials
		% data which was saved by a previous precalculation process.
		tmpFirm	= firms(firm_i);
		load([paths.PreCalcFirmHistory tmpFirm.Bond.DSBondCode], 'firm');
		clear tmpFirm;


		disp(' ');
		disp(['Begin processing firm ' firm.CompName]);

		[yrsKeys yrsVals] = dump(firm.Assets.MertonAssetParams);
		yrsKeys	= cell2mat(yrsKeys)

		% Create somewhere to store pure proxy info:
		firm.Assets.PureProxyAssetParams = hashtable;

		for estimYr = yrsKeys(1) : 1 : yrsKeys(end)
			prevYr		=	estimYr-1;
			yrlyParamsM = get(firm.Assets.MertonAssetParams, estimYr);
			yrlyParamsLS= get(firm.Assets.LSAssetParams, estimYr);

			estimMode		= const.ModeMerton;
			implAssetValsM	= CalcCalendarYearImpliedAssetValues(estimMode, vasParams,firm,estimYr,yrlyParamsM.mu,yrlyParamsM.sigma);
			estimMode		= const.ModeLS;
			implAssetValsLS	= CalcCalendarYearImpliedAssetValues(estimMode, vasParams,firm,estimYr,yrlyParamsLS.mu,yrlyParamsLS.sigma);

			% Our num shares outstanding and total liabs must come from the
			% previous year end of year balance sheet
			prevYrFinObs	= get(firm.Financials, prevYr);
			yrStartNum		= datenum(['01/01/' num2str(estimYr)], const.DateStringAU);
			yrEndNum		= datenum(['31/12/' num2str(estimYr)], const.DateStringAU);

			% Calculate the pure proxy asset values, and hence the yearly
			% drift, volatility and correlation to interest rate changes.
			dailyVasR0s		= [];
			dailyAssValsPP	= [];
			dailyAssValsM	= [];
			dailyAssValsLS	= [];
			for dayInd = yrStartNum : 1 : yrEndNum

				if has_key(vasParams, dayInd) & has_key(firm.Equity, dayInd) & ...
					has_key(implAssetValsM, dayInd) & has_key(implAssetValsLS, dayInd)

					% store the instantaneous interest rate
					dailyVasObs			= get(vasParams, dayInd);
					dailyVasR0s(end+1)	= dailyVasObs.r0;

					% Store the relevant asset estimation in matching index
					dailyEqtyObs			= get(firm.Equity, dayInd);
					dailyEqtyVal			= dailyEqtyObs.AdjClose*prevYrFinObs.OutStShares;
					dailyAssValsPP(end+1)	= dailyEqtyVal + prevYrFinObs.TotLiab;

					dailyAssValsM(end+1)	= get(implAssetValsM, dayInd);
					dailyAssValsLS(end+1)	= get(implAssetValsLS, dayInd);
				end

			end

			% Now that we have found all the relevant asset and interest
			% rate values, calculate their drift, volatility and
			% correlation:
			dailyAssValsPPLog			= log(dailyAssValsPP);
			dailyAssValsPPLogDiff		= diff(dailyAssValsPPLog);

			[yrlyParamsPP.mu yrlyParamsPP.sigma] = CalcActualYrlyDriftAndVolByObservations(dailyAssValsPP)
			yrlyParamsPP.rho	= corr2(dailyAssValsPP, dailyVasR0s);

			% Now store it all back into the object, ready for saving
			yrlyParamsM.rho		= corr2(dailyAssValsM, dailyVasR0s);
			yrlyParamsLS.rho	= corr2(dailyAssValsLS, dailyVasR0s);


			% Store all or calced values
			firm.Assets.PureProxyAssetParams = put(firm.Assets.PureProxyAssetParams, estimYr, yrlyParamsPP);
			firm.Assets.MertonAssetParams	= put(firm.Assets.MertonAssetParams, estimYr, yrlyParamsM);
			firm.Assets.LSAssetParams		= put(firm.Assets.LSAssetParams, estimYr, yrlyParamsLS);
		end

		% Finally, save the individual firm objects as matlab binary files
		% so they can be retrieved very quickly in future.
		save([paths.PreCalcFirmHistory firm.Bond.DSBondCode], 'firm');
	end
end





