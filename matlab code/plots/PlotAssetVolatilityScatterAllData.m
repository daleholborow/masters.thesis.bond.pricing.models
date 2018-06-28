function PlotAssetVolatilityScatterAllData()
	clc
	clear all
	const		= Constants();
	paths		= PathInfo();
	
	allSigmaPP		= [];
	allSigmaM		= [];
	allSigmaLS		= [];
	
	
	firms = ParseCompanyList();
	for firm_i = 1 : 1 : length(firms)
		tmpFirm	= firms(firm_i);
		load([paths.PreCalcFirmHistory tmpFirm.Bond.DSBondCode], 'firm');
		
		disp(['Begin processing firm ' firm.CompName]);
		[yrsKeys yrsVals] = dump(firm.Assets.MertonAssetParams);
		yrsKeys	= cell2mat(yrsKeys);

		for yrInd = yrsKeys(1) : 1 : yrsKeys(end)
			yrAssetParamsM	= get(firm.Assets.MertonAssetParams, yrInd);
			yrAssetParamsPP	= get(firm.Assets.PureProxyAssetParams, yrInd);
			yrAssetParamsLS	= get(firm.Assets.LSAssetParams, yrInd);

			allSigmaPP(end+1)	= yrAssetParamsPP.sigma;
			allSigmaM(end+1)	= yrAssetParamsM.sigma;
			allSigmaLS(end+1)	= yrAssetParamsLS.sigma;
		end
	end
	
	
	
	[betas_PPM, betas_Int_PPM, R_PPM, R_Int_PPM, stats_PPM] = ...
		regress(allSigmaM', allSigmaPP');
	betas_Int_PPM = betas_Int_PPM
	R_sqr_PPM = stats_PPM(1);
	
	[betas_PPLS, betas_Int_PPLS, R_PPLS, R_Int_PPLS, stats_PPLS] = ...
		regress(allSigmaLS', allSigmaPP');
	betas_Int_PPLS = betas_Int_PPLS
	R_sqr_PPLS = stats_PPLS(1);
	
	close all;
	finalW	= 15;	% Inches? 
	finalH	= 7.5;	% Inches?
	rect = [0,0,finalW,finalH];
	myPlot1 = figure('PaperPosition',rect);
	
	% Calc min and max region to show in axis
	axisMin = 0.9*min([allSigmaPP allSigmaM allSigmaLS])
	axisMax = 1.05*max([allSigmaPP allSigmaM allSigmaLS])
	% Calc xaxis values to plot fitted line
	fitPP = [0 : 0.01 : axisMax];
	
	% Plot Pure Proxy vs Merton Volatility estimates and a Linear fit
	subplot(1,2,1);
	hold on;
	titleText(1) = {['R^2: ' num2str(R_sqr_PPM)]};
	title(titleText);
	scatter(allSigmaPP, allSigmaM);
	
	plot(fitPP, fitPP*betas_PPM, 'r');
	axis([axisMin axisMax axisMin axisMax]);
	xlabel('Volatility (Pure Proxy)','FontWeight','Bold');
	ylabel('Volatility (Merton MLE)','FontWeight','Bold');
	legend('Estimated \sigmas', ...
		['Fitted \beta_1: ' num2str(betas_PPM)],'Location','Best');
	
	subplot(1,2,2);
	hold on;
	titleText(1) = {['R^2: ' num2str(R_sqr_PPLS)]};
	title(titleText);
	scatter(allSigmaPP, allSigmaLS);
	plot(fitPP, fitPP*betas_PPLS, 'r');
	axis([axisMin axisMax axisMin axisMax]);
	xlabel('Volatility (Pure Proxy)','FontWeight','Bold');
	ylabel('Volatility (Longstaff&Schwartz MLE)','FontWeight','Bold');
	legend('Estimated \sigmas', ...
		['Fitted \beta_1: ' num2str(betas_PPLS)],'Location','Best');
	
	displayW	= 700; % Pixels?
	displayH	= displayW*finalH/finalW;
	set(myPlot1,'Position',[100,100,displayW,displayH]);
	
% 	pause;
% 	destinationFile	= [paths.ThesisImages paths.AssDynAllFirmsScat];
% 	% Print at eps files for final work
% 	print('-depsc','-r300', destinationFile);
	
	
end