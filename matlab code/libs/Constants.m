function const = Constants()
%--------------------------------------------------------------------------
% @description:	CONSTANTS
%				Declare all the "constant", (i.e. lookup) values used
%				throughout the processing of our bond records.
% @note:		Due to the daftness of Matlab, these are not constant in
%				the true immutable sense of the word, but they will NEVER
%				be overwritten by my code. Could have effectively called
%				this section "lookUpKeys" for example...
%--------------------------------------------------------------------------
	
	%%%
	% Specify which method of parameter estimation is to be
	% used when generating asset dynamics estimates.
	const.ModeMerton		= 'merton';
	const.ModeLS			= 'ls';
	const.ModePureProxyM	= 'ppm';
	const.ModePureProxyLS	= 'ppls';
	const.ModeVasicek		= 'vas';
	
	
	% Constants for plotting consistancy
	const.ColourPP			= 'g';
	const.PointPP			= 'x';
	const.LinePP			= '--';
	const.PlotLegendPP		= 'Pure Proxy';
	
	const.ColourPPM			= 'k';
	const.PointPPM			= 'x';
	const.LinePPM			= '-';
	const.PlotLegendPPM		= 'Merton Pure Proxy';
	
	const.ColourM			= 'r';
	const.PointM			= 's';
	const.LineM				= ':';
	const.PlotLegendM		= 'Merton MLE';
	
	const.ColourPPLS		= 'm';
	const.PointPPLS			= '*';
	const.LinePPLS			= '-';
	const.PlotLegendPPLS	= 'L&S Pure Proxy';
	
	const.ColourLS			= 'b';
	const.PointLS			= '+';
	const.LineLS			= '-.';
	const.PlotLegendLS		= 'L&S MLE';
	
	const.ColourAct			= 'g';
	const.PointAct			= 'o';
	const.LineAct			= '-';
	const.PlotLegendAct		= 'Actual';
	
	% For the VASICEK predictions, NOT actual treasury yields
	const.ColourRF			= 'c';
	const.PointRF			= 'd';
	const.LineRF			= '-';
	const.PlotLegendRF		= 'Vasicek';
	
	% For actual released US Treasury yield curve values
	const.ColourTY			= 'r';
	const.PointTY			= 'x';
	const.LineTY			= '-';
	const.PlotLegendTY		= 'US Treasury';
	
	const.ColourEquity		= 'k';
	const.LineEquity		= '-';
	const.PointEquity		= '';
	const.PlotLegendEquity	= 'Equity';
	
	const.ColourTotLiab		= 'k';
	const.LineTotLiab		= '-.';
	const.PointTotLiab		= '';
	const.PlotLegendTotLiab	= 'Total Liabilities';
	
	
	
	%%%
	% Wong&Choi2007 show empirically that bond default boundaries tend to be
	% less than book value of total liabilities and median default boundary
	% is 73.8% of total liability.
	const.WongChoiDefBoundRatio		= 0.738;
	
	%%%
	% Know how to handle date strings when reading in from csv files
	const.DateStringUSA				= 'mm/dd/yyyy';
	const.DateStringAU				= 'dd/mm/yyyy';
	const.DateStringAUCompressed	= 'ddmmyyyy';
	
	%%%
	% Eom recovery rate on coupons and face value
	const.RecoveryRateCoupons		= 0;
	const.RecoveryRateFaceValue		= 0.5131;
	
	%%%
	% ComputStat-specific codes and constants:
	%
	% String which appears in CompuStat export files when some particular
	% data entry is unavailable. We test for this to see when to quit
	% searches across files etc.
	const.CompuStatDataNA			= '@NA';
	% Total liabilities row string in historical company finances files
	const.CsTotalLiabs				= 'Total Liabilities';
	% Total Liabilities listed in millions in CompuStat?
	const.CsTotalLiabMult			= 1000000;
	% Total shares outstanding
	const.CsSharesOutSt				= 'Common Shares O/S';
	% # Shares listed in millions in CompuStat?
	const.CsSharesOutStMult			= 1000000;
	% Cash row... use this to know where the CompuStat files store the
	% date information, relative to the cash column.
	const.CsCash					= 'Cash';
	% Compustat historic monthly date format
	const.CsMnthlyDtFormat			= 'mmm-yy';
	
	%%%
	% Datastream-specific codes and constants
	%
	% Amount of bond on issue listed in 1000's ?
	const.DSAmountOutStMult			= 1000;
	
end
















