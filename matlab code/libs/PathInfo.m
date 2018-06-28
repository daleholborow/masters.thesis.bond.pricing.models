function paths = PathInfo()
%--------------------------------------------------------------------------
% @description:	PathInfo
%				Return a structure containing all the paths for the
%				relevant files and directories of interest while
%				implementing my project. Store these is one convenient
%				location.
%--------------------------------------------------------------------------
	
	c_driveLappy			= 'D:\';
	c_driveBeast			= 'F:\';
	
	c_projectHomeDir		= 'Documents\UQ Study\MastScience\2008 Sem02\MATH7021 Project\ThesisData\';
	c_bondPricesDir			= 'Bond Prices\';
	c_bondInfoDir			= 'Bond Info\';
	c_financialsDir			= 'Financials\';
	c_interestRatesDir		= 'Interest Rates\';
	c_sharePricesDir		= 'Share Prices\';
	c_processedDir			= 'Processed\';
	c_sourcedDir			= 'Sourced\';
	c_firmData				= 'Firm Data\';
	c_imagesDir				= 'Images\';
	
	if exist([c_driveLappy c_projectHomeDir])
		c_drive				= c_driveLappy;
	else
		c_drive				= c_driveBeast;
	end
	
	
	%%% 
	% Sourced information, from a combination of CompuStat, Datastream, and
	% Yahoo share price (bond price?) information.
	paths.SharePricesDir	= [c_drive c_projectHomeDir c_sourcedDir c_sharePricesDir];
	paths.BondPricesDir		= [c_drive c_projectHomeDir c_sourcedDir c_bondPricesDir];
	paths.BondInfoDir		= [c_drive c_projectHomeDir c_sourcedDir c_bondInfoDir];
	paths.FinancialsDir		= [c_drive c_projectHomeDir c_sourcedDir c_financialsDir];
	paths.InterestRatesDir	= [c_drive c_projectHomeDir c_sourcedDir c_interestRatesDir];
	
	
	%%%
	% Prefixes used for each file related to a particular bond issue. Used
	% largely as a method to make the files differently named so we can
	% open up all files related to a single bond issue at the same time in
	% Excel, which is fiddly about files of the same name *sigh*
	
	% Prefix for files related to bond issuance data - issue date, coupon
	% rate etc
	paths.BondInfoPre		= 'bi_';
	% Prefix for files related to daily bond price observations.
	paths.BondPricePre		= 'bp_';
	% Prefix for files related to daily share price observations
	paths.EqtyPricePre		= 'ep_';
	% Prefix for files related to company historical finance statements
	paths.CompFinPre		= 'cf_';
	
	
	%%%
	% All the specific lookup files that we might need
	%
	% The source of historic interest rate information, contains values
	% from the USA Treasury zero-curve out to maturities of 10 years.
	paths.HistoricInterestRateFile	= [paths.InterestRatesDir 'US Treasury Zero1-10.csv'];
	
	% The joining table containing a company name and DS bond code that
	% all a given company's bond, share price, and financial statements 
	% information is subsequently identified by.
	% Contains the bond-specific information about all the bonds that we
	% are analysing for this project (coupon, issue date, maturity etc)
	paths.BondInfoFile				= [c_drive c_projectHomeDir c_processedDir c_bondInfoDir 'Bond Info.csv'];
	
	% Contains parameter estimates for each daily term structure
	% observation matched to the Nelson-Siegel1987 interest rate model
	paths.NelsonSiegelPredictions	= [c_drive c_projectHomeDir c_processedDir c_interestRatesDir 'NelsonSiegelParams.csv'];
	
	% Contains parameter estimates for each daily term structure
	% observation matched to the Vasicek1977 interest rate model
	paths.VasicekPredictions		= [c_drive c_projectHomeDir c_processedDir c_interestRatesDir 'VasicekParams.csv'];
	
	
	%%%
	% For a massive speed increase, we can save precalculated values, such
	% as the Vasicek interest rate parameter predictions, into a matlab
	% binary file for very quick reload. 
	%
	% Filename of the precalculated vasicek interest rate parameters
	paths.PreCalVasicekPredictFile	= [c_drive c_projectHomeDir c_processedDir c_interestRatesDir 'vasicekParams.mat'];
	paths.PreCalVasicekPredictVar	= 'vasicekParams';
	
	% Directory of the individual firm data files, which include all the
	% bond issue data, the equity price history, and financial data
	% history. Firms stored as <dsBondCode>.mat e.g. '1234F3.mat'
	paths.PreCalcFirmHistory		= [c_drive c_projectHomeDir c_processedDir c_firmData];
	
	
	% Where to store our tables of precalculated values for asset dynamics
	% and predictions of bond prices
	paths.TabularAssetDynamicsFile	= [c_drive c_projectHomeDir c_processedDir c_firmData 'Firm Asset Dynamics.csv'];
	paths.TabularBondIssuePricesFile= [c_drive c_projectHomeDir c_processedDir c_firmData 'Bond Issue Price Predictions.csv'];
	paths.TabularBondHistoricalPricesFile= [c_drive c_projectHomeDir c_processedDir c_firmData 'Bond Historical Price Predictions.csv'];
	
	%
	%
	paths.ThesisImages				= [c_drive c_projectHomeDir c_processedDir c_imagesDir];
	% Prefix for plots of yearly asset dynamics, asset paths, implied
	% yields etc:
	
	% Plots of asset dynamics estimates by year
	paths.YrlyAssDynPlotsPre		= 'yadp_';
	% Plots of implied asset valuations
	paths.AssPathPlotsPre			= 'app_';
	% 
	paths.YieldAtIssuePlot			= 'yields_at_issue';
	% Plots of historic yield calculations
	paths.YieldHistoryPlotPre		= 'yhp_';
	paths.VasR0VsTreasuryPlot		= 'vas_r0_vs_treasury';
	% Fitted Vasicek images
	paths.VasLeastSqrFitPre			= 'vas_fit_';
	% Asset dynamics scatter plots per-firm prefix
	paths.AssDynScatPre				= 'ads_';
	% Asset dynamics scatter plot full sample
	paths.AssDynAllFirmsScat		= 'scat_plot_all_vols';
	% Scatter of bond yields at issue
	paths.YieldsAllFirmsScat		= 'scat_all_issue_yld';
	
end




