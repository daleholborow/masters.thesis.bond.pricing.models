function PlotAssetPathEstimates()
	vasParams		= ParseInterestRateParamsVasicek();
	firms = ParseCompanyList();
	for firm_i = 1 : 1 : length(firms)
% 		if firm_i == 14
			% For each firm, we need to get the bond name as it was stored in
			% the csv, but then we will load up the ENTIRE firm/bond/financials
			% data which was saved by a previous precalculation process.
			tmpFirm	= firms(firm_i);
% 			PlotAssetPathEstimatesByFirm(vasParams,tmpFirm.Bond.DSBondCode);
			PlotAssetPathEstimatesByFirmByYearRange(vasParams,tmpFirm.Bond.DSBondCode,2002,2008);
			clear tmpFirm;
% 		end
	end
end


function PlotAssetPathEstimatesByFirmByYearRange(vasParams,dSBondCode,minYear,maxYear)
	close all
	const		= Constants();
	paths		= PathInfo();
	load([paths.PreCalcFirmHistory dSBondCode], 'firm');
	
	disp(['Begin processing firm ' firm.CompName]);
	[yrsKeys yrsVals] = dump(firm.Assets.MertonAssetParams);
	yrsKeys	= cell2mat(yrsKeys);
		
	for estimYr = yrsKeys(1) : 1 : yrsKeys(end)
		
		if estimYr >= minYear && estimYr <= maxYear
		
			% Our num shares outstanding and total liabs must come from the
			% previous year end of year balance sheet
			prevYr			= estimYr - 1;
			prevYrFinObs	= get(firm.Financials, prevYr);
			yrStartNum		= datenum(['01/01/' num2str(estimYr)], const.DateStringAU);
			yrEndNum		= datenum(['31/12/' num2str(estimYr)], const.DateStringAU);

			disp(['Processing year: ' num2str(estimYr)]);
			% Parameters of asset dynamics for the year we are plotting
			estimYrAssetParamsM		= get(firm.Assets.MertonAssetParams, estimYr);
			ImplAssetValsMerton		= CalcCalendarYearImpliedAssetValues(const.ModeMerton,vasParams,firm,estimYr,estimYrAssetParamsM.mu,estimYrAssetParamsM.sigma);
			estimYrAssetParamsLS	= get(firm.Assets.LSAssetParams, estimYr);
			ImplAssetValsLS			= CalcCalendarYearImpliedAssetValues(const.ModeLS,vasParams,firm,estimYr,estimYrAssetParamsLS.mu,estimYrAssetParamsLS.sigma);

			xValsYrGen		= [];
			yValsYrPP		= [];
			yValsYrM		= [];
			yValsYrLS		= [];
			yValsYrE		= [];
			yValsYrTL		= [];

			for day_i = yrStartNum : 1 : yrEndNum
				if has_key(ImplAssetValsMerton, day_i)

					xValsYrGen(end+1)	= day_i;

					yValsYrM(end+1)		= get(ImplAssetValsMerton, day_i);
					yValsYrLS(end+1)	= get(ImplAssetValsLS, day_i);
					dailyEqtyObs		= get(firm.Equity,day_i);
					yValsYrE(end+1)		= dailyEqtyObs.AdjClose*prevYrFinObs.OutStShares;
					yValsYrTL(end+1)	= prevYrFinObs.TotLiab;
					yValsYrPP(end+1)	= yValsYrE(end) + yValsYrTL(end);
				end
			end
			
			yValsYrM = yValsYrM/1000000;
			yValsYrLS = yValsYrLS/1000000;
			yValsYrE = yValsYrE/1000000;
			yValsYrTL = yValsYrTL/1000000;
			yValsYrPP = yValsYrPP/1000000;
			
			close all;
			finalW	= 15;	% Inches? 
			finalH	= 9;	% Inches?
			rect = [0,0,finalW,finalH];
			myPlot1 = figure('PaperPosition',rect);
			hold on;
			plot(xValsYrGen, yValsYrPP, [const.ColourPP const.LinePP]);
			plot(xValsYrGen, yValsYrM, [const.ColourM const.LineM]);
			plot(xValsYrGen, yValsYrLS, [const.ColourLS const.LineLS]);
			plot(xValsYrGen, yValsYrTL, [const.ColourTotLiab const.LineTotLiab]);
			plot(xValsYrGen, yValsYrE, [const.ColourEquity const.LineEquity]);
			titleText(1) = {'Implied Asset Value Paths:'};
			titleText(2) = {[firm.CompName ' (' firm.Bond.MoodysRating ')']};
			title(titleText,'FontWeight','Bold');
			xlabel('Year','FontWeight','Bold');
			ylabel('Asset Value ($Millions)','FontWeight','Bold');
			legend(const.PlotLegendPP, const.PlotLegendM, ...
				const.PlotLegendLS,const.PlotLegendTotLiab,...
				const.PlotLegendEquity,'Location','Best');
			datetick('x','yyyy');
			displayW	= 600; % Pixels?
			displayH	= displayW*finalH/finalW;
			set(myPlot1,'Position',[100,100,displayW,displayH]);

	% 		% For the sake of argument, calculate the drift and volatility of
	% 		% the log-asset-returns
	% 		[yrlyDriftPP yrlyVolPP] = CalcActualYrlyDriftAndVolByObservations(yValsYrPP)
	% 		[yrlyDriftM yrlyVolM] = CalcActualYrlyDriftAndVolByObservations(yValsYrM)
	% 		[yrlyDriftLS yrlyVolLS] =
	% 		CalcActualYrlyDriftAndVolByObservations(yValsYrLS)
		end
	end
	
	try
		destinationFile	= [paths.ThesisImages paths.AssPathPlotsPre firm.Bond.DSBondCode];
		pause;
		% Print at eps files for final work
		print('-depsc','-r300', destinationFile);
	catch
		disp(['Failed to find values in range for company: ' firm.CompName]);
	end
end









