function TabulateAssetDynamics()

	tic;
	clc;
	clear all;
	const		= Constants();
	paths		= PathInfo();
	
	% Retrieve all the preliminary details about all the firms for whom we
	% wish to perform bond pricing:
	firms = ParseCompanyList();
	
	dataOut		= cell(0,0);
	
	dataCells = cell(0,0);
	dataCells(1,end+1)	= {'Company Name'};
	dataCells(1,end+1)	= {'Moodys Rating'};
	dataCells(1,end+1)	= {'Year'};
	dataCells(1,end+1)	= {'PP.mu'};
	dataCells(1,end+1)	= {'PP.sigma'};
	dataCells(1,end+1)	= {'PP.rho'};
	dataCells(1,end+1)	= {'M.mu'};
	dataCells(1,end+1)	= {'M.sigma'};
	dataCells(1,end+1)	= {'M.rho'};
	dataCells(1,end+1)	= {'LS.mu'};
	dataCells(1,end+1)	= {'LS.sigma'};
	dataCells(1,end+1)	= {'LS.rho'};
	dataOut(end+1,:)	= dataCells(1,:);
	
	for firm_i = 1 : 1 : length(firms)
		
		% For each firm, we need to get the bond name as it was stored in
		% the csv, but then we will load up the ENTIRE firm/bond/financials
		% data which was saved by a previous precalculation process.
		tmpFirm	= firms(firm_i);
		load([paths.PreCalcFirmHistory tmpFirm.Bond.DSBondCode], 'firm');
		clear tmpFirm;


		disp(' ');
		disp(['Begin processing firm ' firm.CompName]);
		
		[yrsKeys yrsVals] = dump(firm.Assets.MertonAssetParams);
		yrsKeys	= cell2mat(yrsKeys);
		
		
		for yrInd = yrsKeys(1) : 1 : yrsKeys(end)
			
			yrAssetParamsM	= get(firm.Assets.MertonAssetParams, yrInd);
			yrAssetParamsPP	= get(firm.Assets.PureProxyAssetParams, yrInd);
			yrAssetParamsLS	= get(firm.Assets.LSAssetParams, yrInd);
			
			dataCells = cell(0,0);
			
			dataCells(1,end+1)	= {firm.CompName};
			dataCells(1,end+1)	= {firm.Bond.MoodysRating};
			dataCells(1,end+1)	= {yrInd};
			
			dataCells(1,end+1)	= {yrAssetParamsPP.mu};
			dataCells(1,end+1)	= {yrAssetParamsPP.sigma};
			dataCells(1,end+1)	= {yrAssetParamsPP.rho};
			
			dataCells(1,end+1)	= {yrAssetParamsM.mu};
			dataCells(1,end+1)	= {yrAssetParamsM.sigma};
			dataCells(1,end+1)	= {yrAssetParamsM.rho};
			
			dataCells(1,end+1)	= {yrAssetParamsLS.mu};
			dataCells(1,end+1)	= {yrAssetParamsLS.sigma};
			dataCells(1,end+1)	= {yrAssetParamsLS.rho};
			
			dataOut(end+1,:)	= dataCells(1,:);
		end
		
		dataOut(end+1,end)	= {[]};
		
	end
	
	% Where do we want to save our results to?
	destination	= paths.TabularAssetDynamicsFile;
	WriteCellToCsv(destination, dataOut);

end




