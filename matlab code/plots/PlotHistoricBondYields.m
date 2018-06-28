function PlotHistoricBondYields()
	clc;
	clear all;
	close all;
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
		
		issueDateNums	= [];
		bondYieldsPPM	= [];
		bondYieldsM		= [];
		bondYieldsPPLS	= [];
		bondYieldsLS	= [];
		bondYieldsAct	= [];
		bondYieldsRF	= [];
		
% 		if firm_i == 1
			
			% For each firm, we need to get the bond name as it was stored in
			% the csv, but then we will load up the ENTIRE firm/bond/financials
			% data which was saved by a previous precalculation process.
			tmpFirm	= firms(firm_i);
			load([paths.PreCalcFirmHistory tmpFirm.Bond.DSBondCode], 'firm');
			clear tmpFirm;

			disp(' ');
			disp(['Begin processing firm ' firm.CompName]);

			for yrInd = 2002 : 1 : 2008
				for mnthInd = 1 : 1 : 12
% 					disp(['Processing month: ' num2str(mnthInd) ', year: ' num2str(yrInd)]);

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
						faceVal		= 1;
						coupon		= firm.Bond.CouponRate;

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
						
						
						issueDateNums(end+1)	= actualPriceDtNum;
						bondYieldsPPM(end+1)	= impliedYieldPPM;
						bondYieldsM(end+1)		= impliedYieldM;
						bondYieldsLS(end+1)		= impliedYieldLS;
						bondYieldsPPLS(end+1)	= impliedYieldPPLS;
						bondYieldsAct(end+1)	= impliedYieldAct;
						bondYieldsRF(end+1)		= impliedYieldRF;
					catch
% 						lasterr
						disp('Couldn''t find price within range, ignore and continue processing');
					end
				end
% 			end
		end
		
		close all;
		finalW	= 15;	% Inches? 
		finalH	= 9;	% Inches?
		rect = [0,0,finalW,finalH];
		myPlot1 = figure('PaperPosition',rect);
		hold on;
		plot(issueDateNums,bondYieldsPPM, [const.ColourPPM const.LinePPM]);
		plot(issueDateNums,bondYieldsM, [const.ColourM const.LineM]);
		plot(issueDateNums,bondYieldsPPLS, [const.ColourPPLS const.LinePPLS]);
		plot(issueDateNums,bondYieldsLS, [const.ColourLS const.LineLS]);
		plot(issueDateNums,bondYieldsAct, [const.ColourAct const.LineAct]);
		plot(issueDateNums,bondYieldsRF, [const.ColourRF const.LineRF]);
		
		minX = min(issueDateNums)
% 		datestr(minX)
		maxX = max(issueDateNums);
		minY = 1/2*min([bondYieldsPPM bondYieldsM bondYieldsPPLS bondYieldsLS bondYieldsAct bondYieldsRF]);
		maxY = 1.02*max([bondYieldsPPM bondYieldsM bondYieldsPPLS bondYieldsLS bondYieldsAct bondYieldsRF]);
		axis([minX maxX minY maxY]);
		datetick('x','mmmyyyy');
		titleText(1) = {'Implied bond yields over time:'};
		titleText(2) = {[firm.CompName ' (' firm.Bond.MoodysRating ')']};
		title(titleText,'FontWeight','Bold');
		xlabel('Year','FontWeight','Bold');
		ylabel('Yield to Maturity','FontWeight','Bold');
		legend(const.PlotLegendPPM, const.PlotLegendM, const.PlotLegendPPLS, const.PlotLegendLS, const.PlotLegendAct, const.PlotLegendRF, 'Location','Best');
		displayW	= 600; % Pixels?
		displayH	= displayW*finalH/finalW;
		set(myPlot1,'Position',[100,100,displayW,displayH]);
		axis tight
		pause;
		
		destinationFile	= [paths.ThesisImages paths.YieldHistoryPlotPre firm.Bond.DSBondCode];
		% Print at eps files for final work
		print('-depsc','-r300', destinationFile);
		
	end
end















