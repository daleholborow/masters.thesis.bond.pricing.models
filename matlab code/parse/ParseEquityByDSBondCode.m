function [Equity] = ParseEquityByDSEquityCode(dsBondCode)
% function [Equity] = ParseEquityByDSBondCode()
%--------------------------------------------------------------------------
% @description:	ParseEquityByDSEquityCode
%				Based on a company's DataStream bond code, find the file
%				with all the historical adjusted equity closing prices.
%				Load up each observation and store it in a collection
%				indexed by datenum() values.
% @params:
%	
%--------------------------------------------------------------------------
% 	dsBondCode = '96730P';
	
	tic
	disp([' ']);
	disp(['Retrieving share price observations for: ' num2str(dsBondCode)]);
	
	constants		= Constants();
	paths			= PathInfo();
	sourceFile		= [paths.SharePricesDir paths.EqtyPricePre dsBondCode '.csv'];
	[dataIn, result]= readtext(sourceFile, ...
		'[,]', '', '"', 'textual');
	[dataInRows dataInCols]	= size(dataIn);
	
	% Create an initial hash to store daily share price observations. Start
	% with approx 3 years of spaces reserved, for speed...
	Equity = hashtable('size',1000);
	
	% Which columns the various items of interest are to be found in
	dateCol			= find(strcmpi(dataIn(1,:), 'Date'));
	adjCloseCol		= find(strcmpi(dataIn(1,:), 'Adj Close'));
	
	% For each end of day adjusted price observation, record it against the
	% date now. We know that our data might be dirty and might include dates 
	% against which there are no share price observations. We test that both
	% values exist before adding the date as a key in our hash. This is
	% unfortunately slower than need be, but it handles dirty data more
	% easily.
	for index = 2 : 1 : dataInRows
		dataInDtStr		= cell2mat(dataIn(index,dateCol));
		dataInObsClose	= cell2mat(dataIn(index,adjCloseCol));
		
		% Only add the row of data if all required values exist
		if length(dataInDtStr) ~= 0 && length(dataInObsClose) ~= 0
			dailyObs.ObsDateNum	= datenum(dataInDtStr,constants.DateStringAU);
			dailyObs.AdjClose	= str2num(dataInObsClose);

			% Add observation values to the series, keyed on observation
			% date
			Equity = put(Equity, dailyObs.ObsDateNum, dailyObs);
		end
	end
	
	disp(['Successfully loaded share price data for: ' dsBondCode]);
	disp(['Total # observations found: ' num2str(count(Equity))]);
	disp(['Total processing time: ' num2str(toc)]);
end


