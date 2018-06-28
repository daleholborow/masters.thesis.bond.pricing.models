function PlotAssetVolatilityScatter()
	clc
	clear all
	firms = ParseCompanyList();
	for firm_i = 1 : 1 : length(firms)
% 		if 1 == firm_i 
			tmpFirm	= firms(firm_i);
			PlotAssetVolatilityScatterByFirm(tmpFirm.Bond.DSBondCode);
			clear tmpFirm;
% 		end
	end
end


function PlotAssetVolatilityScatterByFirm(dSBondCode)
	const		= Constants();
	paths		= PathInfo();
	load([paths.PreCalcFirmHistory dSBondCode], 'firm');
	
	disp(['Begin processing firm ' firm.CompName]);
	[yrsKeys yrsVals] = dump(firm.Assets.MertonAssetParams);
	yrsKeys	= cell2mat(yrsKeys);
	
% 	xVals			= [];
	yrlySigmaPP		= [];
	yrlySigmaM		= [];
	yrlySigmaLS		= [];
	
	for yrInd = yrsKeys(1) : 1 : yrsKeys(end)
% 		xVals(end+1)	= datenum(['01/01/' num2str(yrInd)], ...
% 			const.DateStringAU);
		
		yrAssetParamsM	= get(firm.Assets.MertonAssetParams, yrInd);
		yrAssetParamsPP	= get(firm.Assets.PureProxyAssetParams, yrInd);
		yrAssetParamsLS	= get(firm.Assets.LSAssetParams, yrInd);
		
		yrlySigmaPP(end+1)	= yrAssetParamsPP.sigma;
		yrlySigmaM(end+1)	= yrAssetParamsM.sigma;
		yrlySigmaLS(end+1)	= yrAssetParamsLS.sigma;
	end
	
	[betas_PPM, betas_Int_PPM, R_PPM, R_Int_PPM, stats_PPM] = ...
		regress(yrlySigmaM',yrlySigmaPP')
	R_sqr_PPM = stats_PPM(1);
	
	[betas_PPLS, betas_Int_PPLS, R_PPLS, R_Int_PPLS, stats_PPLS] = ...
		regress(yrlySigmaLS',yrlySigmaPP')
	R_sqr_PPLS = stats_PPLS(1);
	
	close all;
	finalW	= 20;	% Inches? 
	finalH	= 6.75;	% Inches?
	rect = [0,0,finalW,finalH];
	myPlot1 = figure('PaperPosition',rect);
	
	% Calc min and max region to show in axis
	axisMin = 0.9*min([yrlySigmaPP yrlySigmaM yrlySigmaLS])
	axisMax = 1.05*max([yrlySigmaPP yrlySigmaM yrlySigmaLS])
	% Calc xaxis values to plot fitted line
	fitPP = [0 : 0.01 : axisMax];
	
	% Plot Pure Proxy vs Merton Volatility estimates and a Linear fit
	subplot(1,2,1);
	hold on;
	titleText(1) = {firm.CompName};
	titleText(2) = {['R^2: ' num2str(R_sqr_PPM)]};
	title(titleText);
	scatter(yrlySigmaPP, yrlySigmaM);
	
	plot(fitPP, fitPP*betas_PPM, 'r');
	axis([axisMin axisMax axisMin axisMax]);
	xlabel('Volatility (Pure Proxy)','FontWeight','Bold');
	ylabel('Volatility (Merton MLE)','FontWeight','Bold');
	legend('Volatility Estimates', ...
		['Fitted \beta_1: ' num2str(betas_PPM)],'Location','Best');
	
	subplot(1,2,2);
	hold on;
	titleText(1) = {','};
	titleText(2) = {['R^2: ' num2str(R_sqr_PPLS)]};
	title(titleText);
	scatter(yrlySigmaPP, yrlySigmaLS);
	plot(fitPP, fitPP*betas_PPLS, 'r');
	axis([axisMin axisMax axisMin axisMax]);
	xlabel('Volatility (Pure Proxy)','FontWeight','Bold');
	ylabel('Volatility (Longstaff&Schwartz MLE)','FontWeight','Bold');
	legend('Volatility Estimates', ...
		['Fitted \beta_1: ' num2str(betas_PPLS)],'Location','Best');
	
	displayW	= 700; % Pixels?
	displayH	= displayW*finalH/finalW;
	set(myPlot1,'Position',[100,100,displayW,displayH]);
	
	pause;
	destinationFile	= [paths.ThesisImages paths.AssDynScatPre ...
		firm.Bond.DSBondCode];
	% Print at eps files for final work
	print('-depsc','-r300', destinationFile);
end











