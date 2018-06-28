function [BondPrices] = ParseBondPricesByDSBondCode(dsBondCode)
% function [BondPrices] = ParseBondPricesByDSBondCode()
%--------------------------------------------------------------------------
% @description:	ParseBondPricesByDSBondCode
%				Based on a company's DataStream bond code, find the file
%				with all the historical adjusted equity closing prices.
%				Load up each observation and store it in a collection
%				indexed by datenum() values.
% @params:
%	
%--------------------------------------------------------------------------
% 	dsBondCode = '48410K';
	
	tic
	disp([' ']);
	disp(['Retrieving historical bond price observations for: ' num2str(dsBondCode)]);
	
	constants		= Constants();
	paths			= PathInfo();
	sourceFile		= [paths.BondPricesDir paths.BondPricePre dsBondCode '.csv'];
	[dataIn, result]= readtext(sourceFile, ...
		'[,]', '', '"', 'textual');
	[dataInRows dataInCols]	= size(dataIn);
	
	% Create an initial hash to store daily bond price observations. Start
	% with approx 3 years of spaces reserved, for speed...
	BondPrices = hashtable('size',1000);
	
	% Which columns the various items of interest are to be found in
	dateCol			= find(strcmpi(dataIn(2,:), 'Code'));
	priceCol		= find(strcmpi(dataIn(2,:), [dsBondCode '(GP)']));
	
	% For each end of day bond price observation, record it against the
	% date now. We know that our data might be dirty and might include dates 
	% against which there are no bond price observations. We test that both
	% values exist before adding the date as a key in our hash. This is
	% unfortunately slower than need be, but it handles dirty data more
	% easily.
	for index = 3 : 1 : dataInRows
		dataInDtStr		= cell2mat(dataIn(index,dateCol));
		dataInObsClose	= cell2mat(dataIn(index,priceCol));
		
		% Only add the row of data if all required values exist
		if length(dataInDtStr) ~= 0 && length(dataInObsClose) ~= 0
			dailyObs.ObsDateNum	= datenum(dataInDtStr,constants.DateStringAU);
			dailyObs.ClosePrice	= str2num(dataInObsClose)/100;

			% Add observation values to the series, keyed on observation
			% date
			BondPrices = put(BondPrices, dailyObs.ObsDateNum, dailyObs);
		end
	end
	
	disp(['Successfully loaded historic bond price data for: ' dsBondCode]);
	disp(['Total # observations found: ' num2str(count(BondPrices))]);
	disp(['Total processing time: ' num2str(toc)]);

end

	
	
	