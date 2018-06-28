function [Financials] = ParseFinancialsByDSBondCode(dsBondCode)
% function [Financials] = ParseFinancialsByDSBondCode()
%--------------------------------------------------------------------------
% @description:	ParseFinancialsByDSBondCode
%				Uses exports of historical financial data from CompuStat in
%				CSV format!!
%--------------------------------------------------------------------------	
% 	dsBondCode = '23332E';
	tic
	disp([' ']);
	disp(['Loading historic firm financials for: ' dsBondCode]);
	
	const			= Constants();
	paths			= PathInfo();
	sourceFile		= [paths.FinancialsDir paths.CompFinPre dsBondCode '.csv'];
	
	[dataIn, result]= readtext(sourceFile, ...
		'[,]', '', '"', 'textual');
	[dataInRows dataInCols]	= size(dataIn);
	
	% Store historical financial information in a hash
	Financials	= hashtable('size', dataInCols);
	
	% Find the appropriate row for each time-series value we are interested
	% in, and then iterate through the rows recording the values as
	% appropriate.
	totLiabRow		= find(strcmpi(dataIn(:,1), const.CsTotalLiabs));
	numShOutstRow	= find(strcmpi(dataIn(:,1), const.CsSharesOutSt));
	datesRow		= (find(strcmpi(dataIn(:,1), const.CsCash)) - 1);
	
	% Loop through as many columns of data as are available, testing each
	% one to make sure that its a valid entry and not just appearing as a
	% result of our broad search range terms:
	for colInd = 2 : 1 : dataInCols
		
		totalLiabsStr	= cell2mat(dataIn(totLiabRow,colInd));
		numOutSharesStr	= cell2mat(dataIn(numShOutstRow,colInd));
		dateStr			= cell2mat(dataIn(datesRow,colInd));
		
		% If is a a valid column, all the fields we require will exist and
		% not equal const.CompuStatDataNA:
		if ~strcmp(totalLiabsStr, const.CompuStatDataNA) && ...
				~strcmp(numOutSharesStr, const.CompuStatDataNA) && ...
				~strcmp(dateStr, const.CompuStatDataNA)
			
			obsDateVec			= datevec(dateStr,const.CsMnthlyDtFormat);
			obsDateVec(3)		= 31; % Set to the end of the month
			dailyObs.ObsDateNum	= datenum(obsDateVec);
			dailyObs.TotLiab	= str2num(totalLiabsStr) * const.CsTotalLiabMult;
			dailyObs.OutStShares= str2num(numOutSharesStr) * const.CsSharesOutStMult;
			
			% Store the yearly observations in the hash, keyed by year
			Financials = put(Financials, obsDateVec(1), dailyObs);
		end
	end
	
	
	disp(['Successfully loaded historical financial data for: ' dsBondCode]);
 	disp(['Total # yearly observations found: ' num2str(count(Financials))]);
	disp(['Total processing time: ' num2str(toc)]);
end





