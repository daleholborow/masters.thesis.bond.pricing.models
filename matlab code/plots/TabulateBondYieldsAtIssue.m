function TabulateBondYieldsAtIssue()
%--------------------------------------------------------------------------
% @description:	TabulateBondYieldsAtIssue
%				For the bond as close as possible to the issue date (within
%				a month, or it fails), perform pricing estimations and
%				save to a file.
%--------------------------------------------------------------------------
	
	tic;
	clc;
	clear all;
	const		= Constants();
	paths		= PathInfo();
	vasParams	= ParseInterestRateParamsVasicek();
	
	
	% Retrieve all the preliminary details about all the firms for whom we
	% wish to perform bond pricing:
	firms = ParseCompanyList();
	
	dataOut		= cell(0,0);
	dataCells	= cell(0,0);
	dataCells(1,end+1)	= {'Company Name'};
	dataCells(1,end+1)	= {'Moodys Rating'};
	dataCells(1,end+1)	= {'Issue Date'};
	dataCells(1,end+1)	= {'Priced Date'};
	dataCells(1,end+1)	= {'r0'};
	dataCells(1,end+1)	= {'RF.price'};
	dataCells(1,end+1)	= {'RF.yield'};
	dataCells(1,end+1)	= {'Act.price'};
	dataCells(1,end+1)	= {'Act.yield'};
	dataCells(1,end+1)	= {'M.PP.price'};
	dataCells(1,end+1)	= {'M.PP.yield'};
	dataCells(1,end+1)	= {'M.MLE.price'};
	dataCells(1,end+1)	= {'M.MLE.yield'};
	dataCells(1,end+1)	= {'LS.PP.price'};
	dataCells(1,end+1)	= {'LS.PP.yield'};
	dataCells(1,end+1)	= {'LS.MLE.price'};
	dataCells(1,end+1)	= {'LS.MLE.yield'};
	dataOut(end+1,:)	= dataCells(1,:);
	
	for firm_i = 1 : 1 : length(firms)
		
% 		if firm_i == 2
% 			error('died here for testing purposes');
% 		end
		
		issueDateNums	= [];
		bondYieldsPPM	= [];
		bondYieldsM		= [];
		bondYieldsPPLS	= [];
		bondYieldsLS	= [];
		bondYieldsAct	= [];
		bondYieldsRF	= [];

		
		
		% For each firm, we need to get the bond name as it was stored in
		% the csv, but then we will load up the ENTIRE firm/bond/financials
		% data which was saved by a previous precalculation process.
		tmpFirm	= firms(firm_i);
		load([paths.PreCalcFirmHistory tmpFirm.Bond.DSBondCode], 'firm');
		clear tmpFirm;


		disp(' ');
		disp(['Begin processing firm ' firm.CompName]);

		% We wish to price the bond as early as possible on or after its date of
		% issue. To test whether pricing is possible for a particular date, we
		% test that we have:
		%	a) Observed equity prices for that date
		%	b) Calculated instantaneous interest rate (and additional params) on that date
		%	c) An observed bond price on that date
		%	d) Asset dynamics parameter estimates for the financial year prior
		%	to pricing:
		tryToPriceDtNum		= firm.Bond.IssueDateNum;
		% Search into the future, one day at a time
		moveDaysBy		= 1;
		maxDist				= 40;
		actualPriceDtNum	= CalcClosestPossibleValuationDate(firm, vasParams, tryToPriceDtNum, moveDaysBy, maxDist);
		
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

		[ActualBondPrice ActualYield] = CalcActualPriceAndYield(actualPriceDtNum,firm);
		
		issueDateNums(end+1)	= actualPriceDtNum;
		bondYieldsPPM(end+1)	= impliedYieldPPM;
		bondYieldsM(end+1)		= impliedYieldM;
		bondYieldsLS(end+1)		= impliedYieldLS;
		bondYieldsPPLS(end+1)	= impliedYieldPPLS;
		bondYieldsAct(end+1)	= impliedYieldAct;
		bondYieldsRF(end+1)		= impliedYieldRF;
		
		vParamsAtObsDt		= get(vasParams, actualPriceDtNum);
		disp(['Priced over the risk-free rate of: ' num2str(vParamsAtObsDt.r0)]);
		disp(['The bond was priced on: ' datestr(actualPriceDtNum)]);
		
		
		%%%%
		% Logic to save the data into a CSV file for analysis... probably
		% supercede this by using the values stored internally in the firm
		% objects once I get that graphing working in Matlab
		%%%%
		dataCells	= cell(0,0);
		dataCells(1,end+1)	= {firm.CompName};
		dataCells(1,end+1)	= {firm.Bond.MoodysRating};
		dataCells(1,end+1)	= {datestr(firm.Bond.IssueDateNum,const.DateStringAU)};
		dataCells(1,end+1)	= {datestr(actualPriceDtNum,const.DateStringAU)};
		dataCells(1,end+1)	= {vParamsAtObsDt.r0};
		
		dataCells(1,end+1)	= {bondPriceRF};
		dataCells(1,end+1)	= {impliedYieldRF};
		dataCells(1,end+1)	= {ActualBondPrice};
		dataCells(1,end+1)	= {ActualYield};
		dataCells(1,end+1)	= {bondPricePPM};
		dataCells(1,end+1)	= {impliedYieldPPM};
		dataCells(1,end+1)	= {bondPriceM};
		dataCells(1,end+1)	= {impliedYieldM};
		dataCells(1,end+1)	= {bondPricePPLS};
		dataCells(1,end+1)	= {impliedYieldPPLS};
		dataCells(1,end+1)	= {bondPriceLS};
		dataCells(1,end+1)	= {impliedYieldLS};
		dataOut(end+1,:)	= dataCells(1,:);
	end
	
	% Where do we want to save our results to?
	destination	= paths.TabularBondIssuePricesFile;
	WriteCellToCsv(destination, dataOut);
end











