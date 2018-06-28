function PlotBondYieldsAtIssue()
	clc;
	clear all;
	close all;
	const		= Constants();
	paths		= PathInfo();
	vasParams	= ParseInterestRateParamsVasicek();
	firms		= ParseCompanyList();
	
	compNames		= {};
	bondYieldsPPM	= [];
	bondYieldsM		= [];
	bondYieldsPPLS	= [];
	bondYieldsLS	= [];
	bondYieldsAct	= [];
	bondYieldsRF	= [];
	
	for firm_i = 1 : 1 : length(firms)
		tmpFirm	= firms(firm_i);
		load([paths.PreCalcFirmHistory tmpFirm.Bond.DSBondCode], 'firm');
		clear tmpFirm;

		% Search into the future, one day at a time
		moveDaysBy			= 1;
		maxDist				= 40;
		actualPriceDtNum	= CalcClosestPossibleValuationDate(firm, ...
			vasParams, firm.Bond.IssueDateNum, moveDaysBy, maxDist);
		actualPriceDtStr	= datestr(actualPriceDtNum,const.DateStringAU);
		
		[remMrktTaus] = CalcRemainingCouponTausInYrs(actualPriceDtNum,...
			firm.Bond.CouponDateNums);
		faceVal		= 1;
		coupon		= firm.Bond.CouponRate;
		
		bondPricePPM = get(firm.Bond.PredBondPricesPPM, actualPriceDtNum);
		impliedYieldPPM = CalcImpliedYield(faceVal,...
			coupon,remMrktTaus,bondPricePPM);
		bondPriceM	= get(firm.Bond.PredBondPricesM, actualPriceDtNum);
		impliedYieldM = CalcImpliedYield(faceVal,coupon,...
			remMrktTaus,bondPriceM);
		bondPricePPLS = get(firm.Bond.PredBondPricesPPLS,actualPriceDtNum);
		impliedYieldPPLS = CalcImpliedYield(faceVal,coupon,...
			remMrktTaus,bondPricePPLS);
		bondPriceLS	= get(firm.Bond.PredBondPricesLS, actualPriceDtNum);
		impliedYieldLS = CalcImpliedYield(faceVal,coupon,...
			remMrktTaus,bondPriceLS);
		[bondPriceAct impliedYieldAct] = CalcActualPriceAndYield(...
			actualPriceDtNum,firm);
		bondPriceRF	= get(firm.Bond.PredBondPricesRF, actualPriceDtNum);
		impliedYieldRF = CalcImpliedYield(faceVal,coupon,...
			remMrktTaus,bondPriceRF);

		compNames(end+1) = {firm.CompName};
		bondYieldsPPM(end+1)	= impliedYieldPPM;
		bondYieldsM(end+1)		= impliedYieldM;
		bondYieldsLS(end+1)		= impliedYieldLS;
		bondYieldsPPLS(end+1)	= impliedYieldPPLS;
		bondYieldsAct(end+1)	= impliedYieldAct;
		bondYieldsRF(end+1)		= impliedYieldRF;
	end	
		
	xVals = [1 : 1 : length(bondYieldsPPM)];
	
	close all;
	finalW	= 16;	% Inches? 
	finalH	= 10;	% Inches?
	rect = [0,0,finalW,finalH];
	myPlot1 = figure('PaperPosition',rect);
	
	hold on;
	minX = xVals(1)-1; maxX = xVals(end)+1;
	minY = 0.03; maxY = 1.05*max([bondYieldsPPM bondYieldsM bondYieldsPPLS ...
		bondYieldsLS bondYieldsAct bondYieldsRF]);
	
	scatter(xVals,bondYieldsPPM, [const.ColourPPM const.PointPPM]);
	scatter(xVals,bondYieldsM, [const.ColourM const.PointM]);
	scatter(xVals,bondYieldsPPLS, [const.ColourPPLS const.PointPPLS]);
	scatter(xVals,bondYieldsLS, [const.ColourLS const.PointLS]);
	scatter(xVals,bondYieldsAct, [const.ColourAct const.PointAct]);
	scatter(xVals,bondYieldsRF, [const.ColourRF const.PointRF]);
	axis([minX maxX minY maxY]);
	set(gca,'XTick',xVals)
% 	set(gca,'XTickLabel',compNames)
	xlabel('Issuing Firm','FontWeight','Bold');
	ylabel('Yield to Maturity','FontWeight','Bold');
	legend(const.PlotLegendPPM, const.PlotLegendM, ...
		const.PlotLegendPPLS, const.PlotLegendLS, ...
		const.PlotLegendAct, const.PlotLegendRF, 'Location','Best');
	
	displayW	= 800; % Pixels?
	displayH	= displayW*finalH/finalW;
	set(myPlot1,'Position',[100,100,displayW,displayH]);
	pause;
	destinationFile	= [paths.ThesisImages paths.YieldsAllFirmsScat];
	% Print at eps files for final work
	print('-depsc','-r300', destinationFile);
end















