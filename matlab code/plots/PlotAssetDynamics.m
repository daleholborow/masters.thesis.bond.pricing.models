function PlotAssetDynamics()
	% Retrieve all the preliminary details about all the firms for whom we
	% wish to perform bond pricing:
	firms = ParseCompanyList();
	
	for firm_i = 1 : 1 : length(firms)
		% For each firm, we need to get the bond name as it was stored in
		% csv, but then we will load up the ENTIRE firm/bond/financials
		% data which was saved by a previous precalculation process.
		tmpFirm	= firms(firm_i);
		PlotAssetDynamicsByFirm(tmpFirm.Bond.DSBondCode);
		clear tmpFirm;
	end
end


function PlotAssetDynamicsByFirm(dSBondCode)
	const		= Constants();
	paths		= PathInfo();
	load([paths.PreCalcFirmHistory dSBondCode], 'firm');
	
	disp(['Begin processing firm ' firm.CompName]);
	[yrsKeys yrsVals] = dump(firm.Assets.MertonAssetParams);
	yrsKeys	= cell2mat(yrsKeys);
	
	xVals			= [];
	yrlySigmaPP		= [];
	yrlySigmaM		= [];
	yrlySigmaLS		= [];
	
	for yrInd = yrsKeys(1) : 1 : yrsKeys(end)
		xVals(end+1)	= datenum(['01/01/' num2str(yrInd)], ...
			const.DateStringAU);
		
		yrAssetParamsM	= get(firm.Assets.MertonAssetParams, yrInd);
		yrAssetParamsPP	= get(firm.Assets.PureProxyAssetParams, yrInd);
		yrAssetParamsLS	= get(firm.Assets.LSAssetParams, yrInd);
		
		yrlySigmaPP(end+1)	= yrAssetParamsPP.sigma;
		yrlySigmaM(end+1)	= yrAssetParamsM.sigma;
		yrlySigmaLS(end+1)	= yrAssetParamsLS.sigma;

	end
	
	close all;
	finalW	= 15;	% Inches? 
	finalH	= 6;	% Inches?
	rect = [0,0,finalW,finalH];
	myPlot1 = figure('PaperPosition',rect);
	hold on;
	plot(xVals, yrlySigmaPP, ...
		[const.ColourPP const.LinePP const.PointPP]);
	plot(xVals, yrlySigmaM, [const.ColourM const.LineM const.PointM]);
	plot(xVals, yrlySigmaLS, [const.ColourLS const.LineLS const.PointLS]);
	axis([min(xVals),max(xVals),0,...
		1.05*max([yrlySigmaPP yrlySigmaM yrlySigmaLS])]);
	datetick('x','yyyy');
	titleText(1) = {'Yearly volatility \sigma estimate:'};
	titleText(2) = {[firm.CompName ' (' firm.Bond.MoodysRating ')']};
	legend(const.PlotLegendPP, const.PlotLegendM, ...
		const.PlotLegendLS,'Location','Best');
	title(titleText,'FontWeight','Bold');
	xlabel('Year','FontWeight','Bold');
	ylabel('Yearly Volatility','FontWeight','Bold');
	displayW	= 600; % Pixels?
	displayH	= displayW*finalH/finalW;
	set(myPlot1,'Position',[100,100,displayW,displayH]);
	destinationFile	= [paths.ThesisImages paths.YrlyAssDynPlotsPre ...
		firm.Bond.DSBondCode];
	
	% Pause so we can adjust the legend if need be
	pause;
	
	% Print at eps files for final work
	print('-depsc','-r300', destinationFile);
	
end











