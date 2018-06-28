% function PlotFirmAssets()
% %--------------------------------------------------------------------------
% % Creates a plot of the implied asset values for some firm, over some year,
% % according to each of the various pricing methodologies.
% %--------------------------------------------------------------------------
% 	clc
% 	close all
% 	
% 	const		= Constants();
% 	paths		= PathInfo();
% 	
% 	
% 	% Load up a firm by its bond code
% 	bondCode		= '48998L';
% 	load([paths.PreCalcFirmHistory bondCode], 'firm');
% 	
% 	% Load all precalculated Vasicek interest rate model parameters so we
% 	% can use the instantaneous spot rates in our estimation of asset
% 	% dynamics.
% 	vasParams		= ParseInterestRateParamsVasicek();
% 	
% 	% The year we intend to plot results for
% 	estimYr			= 2004;
% 	% The year for which we need to retrieve num shares outstanding, and
% 	% total liabs from
% 	prevYr			= estimYr - 1;
% 	
% 	
% 	disp('remove this hack, just making the leverage greater to test influence on implied asset values');
% 	Financials	= get(firm.Financials, prevYr)
% 	Financials.TotLiab		= Financials.TotLiab*10
% 	firm.Financials = put(firm.Financials, prevYr, Financials);
% 	
% 	
% 	% Our num shares outstanding and total liabs must come from the
% 	% previous year end of year balance sheet
% 	prevYrFinObs	= get(firm.Financials, prevYr);
% 	yrStartNum		= datenum(['01/01/' num2str(estimYr)], const.DateStringAU);
% 	yrEndNum		= datenum(['31/12/' num2str(estimYr)], const.DateStringAU);
% 	
% 	
% 	
% 	% Parameters of asset dynamics for the year we are plotting
% 	estimYrAssetParamsM		= get(firm.Assets.MertonAssetParams, estimYr);
% 	estimYrAssetParamsM
% 	ImplAssetValsMerton		= CalcCalendarYearImpliedAssetValues(const.ModeMerton,vasParams,firm,estimYr,estimYrAssetParamsM.mu,estimYrAssetParamsM.sigma);
% 	
% 	estimYrAssetParamsLS	= get(firm.Assets.LSAssetParams, estimYr);
% 	estimYrAssetParamsLS
% 	ImplAssetValsLS			= CalcCalendarYearImpliedAssetValues(const.ModeLS,vasParams,firm,estimYr,estimYrAssetParamsLS.mu,estimYrAssetParamsLS.sigma);
% 	
% 	
% 	
% % 	% temp hack to debug code
% % 	estimYrAssetParamsLS.mu	= 0.1676
% % 	estimYrAssetParamsLS.sigma	= 0.0079
% % 	estimMode				= const.ModeLS;
% % 	ImplAssetValsLS			= CalcCalendarYearImpliedAssetValues(const.ModeLS,vasParams,firm,estimYr,estimYrAssetParamsLS.mu,estimYrAssetParamsLS.sigma);
% % 	logLikeSum = LogLikelihoodSummation(estimMode,ImplAssetValsLS,firm,estimYr,vasParams,estimYrAssetParamsLS.mu,estimYrAssetParamsLS.sigma)
% 	
% 	
% 	
% 
% % 	dates					= [ImplAssetValsMerton.ObsDate
% 
% 	% Get the Merton implied asset values for plotting
% 	[keysM valsM]	= dump(ImplAssetValsMerton);
% 	keysM			= cell2mat(keysM);
% 	valsM			= cell2mat(valsM);
% 	keyIndM			= find(keysM > yrStartNum & keysM < yrEndNum);
% 	xValsM			= keysM(keyIndM);
% 	yValsM			= valsM(keyIndM);
% 	
% 	% Retrieve the interest rate observations on the days which we observe
% 	% asset valuations, in order to calculate their correlation
% 	% coefficients.
% 	[keysV valsV]	= dump(vasParams);
% 	keysV			= cell2mat(keysV);
% 	valsV			= cell2mat(valsV);
% 	keyIndV			= find(keysM);
% 	xValsV			= keysV(keyIndV);
% 	yValsV			= [valsV(keyIndV).r0]';
% 	
% % % 	size(yValsM)
% % % 	size(yValsV)
% % 	corr2(yValsM, yValsV)
% 	
% % 	plot(xValsM, yValsV');
% % 	return
% 	
% 	% Get the longstaff&schwartz values for plotting
% 	[keysLS valsLS]	= dump(ImplAssetValsLS);
% 	keysLS			= cell2mat(keysLS);
% 	valsLS			= cell2mat(valsLS);
% 	keyIndLS		= find(keysLS > yrStartNum & keysLS < yrEndNum);
% 	xValsLS			= keysLS(keyIndLS);
% 	yValsLS			= valsLS(keyIndLS);
% 
% % 	% Get the BdV implied asset values for plotting
% % 	[keysBdV valsBdV]	= dump(ImplAssetValsBdV);
% % 	keysBdV			= cell2mat(keysBdV);
% % 	valsBdV			= cell2mat(valsBdV);
% % 	keyIndBdV			= find(keysBdV > yrStartNum & keysBdV < yrEndNum);
% % 	xValsBdV			= keysBdV(keyIndBdV);
% % 	yValsBdV			= valsBdV(keyIndBdV);
% 	
% 	% Get all the equity values for plotting
% 	[keysE valsE]	= dump(firm.Equity);
% 	keysE			= cell2mat(keysE);
% 	valsE			= cell2mat(valsE);
% 	keyIndE			= find(keysE > yrStartNum & keysE < yrEndNum);
% 	xValsE			= keysE(keyIndE);
% 	yValsE			= [valsE(keyIndE).AdjClose]*prevYrFinObs.OutStShares;
% 	
% 	% Have to create an array of total liabs of exact same length or else
% 	% our colour plot misbehaves in the legend... *sigh*
% 	yValsTL			= ones(1,length(xValsM))*prevYrFinObs.TotLiab;
% 	
% 	hold on
% 	plot(xValsM, yValsM, 'r-');			% Merton assets
% 	
% 	plot(xValsM, yValsTL, 'b-');		% Total Liabs
% 	plot(xValsE, yValsE, 'k-');			% Equity
% 	plot(xValsE, yValsE+prevYrFinObs.TotLiab, 'c-'); % Pure Proxy
% 	plot(xValsLS, yValsLS, 'm-');	% Longstaff&Schwartz assets
% % 	plot(xValsBdV, yValsBdV, 'g-');	% Briys & De Varenne assets
% 	
% 	axis([min(xValsM), max(xValsM), 0, max(yValsM)*1.1]);
% 	
% 	legend('Merton Asset Valuation', 'Tot Liabs Before Issue','Equity','Pure Proxy Asset Valuation','LS Asset Vals');
% 	title(['Asset valuation for the year: ' num2str(estimYr) ' for firm bond: ' bondCode]);
% 	
% 
% end
% 
% 
% 
% 
