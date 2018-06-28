function PlotVasicekCurveFits()
	clc
	clear all
	tic
	const		= Constants();
	paths		= PathInfo();
	
	% Load all precalculated Vasicek interest rate model parameters so 
	% can use the instantaneous spot rates in our estimation of asset
	% dynamics.
	vasParams	= ParseInterestRateParamsVasicek();
	
% 	% Code to loop thru day by day over a range and check out how the 
% 	% yield curve changes
% 	yrStartNum	= datenum('19/01/2001', const.DateStringAU);
% 	yrEndNum	= datenum('19/01/2001', const.DateStringAU);
% 	for day_i = yrStartNum : 1 : yrEndNum
% 		PlotDailyVasicekCurveFit(const,paths,day_i,vasParams,'');
% 	end
	
	
	% Retrieve all firms so we can load their issue dates
	firms = ParseCompanyList();
	for firm_i = 1 : 1 : length(firms)
		tmpFirm	= firms(firm_i);
		load([paths.PreCalcFirmHistory tmpFirm.Bond.DSBondCode], 'firm');
		
		actualPriceDtNum = CalcClosestPossibleValuationDate(firm, ...
			vasParams, firm.Bond.IssueDateNum, 1, 40);
		
		PlotDailyVasicekCurveFit(const,paths,actualPriceDtNum,...
			vasParams,firm.CompName, firm.Bond.DSBondCode);
	end
	
end

function PlotDailyVasicekCurveFit(const, paths, dateOfObsNum, ...
		vasParams, companyName, dsBondCode)
	if has_key(vasParams, dateOfObsNum)
		dailyVasParams	= get(vasParams,dateOfObsNum);
		mrktTaus	= [];
		mrktYields	= [];
		for m_i = 1 : 1 : 10*12
			month_field = ['m' num2str(m_i)];
			if isfield(dailyVasParams, month_field)
				mrktTaus(end+1) = m_i;
				mrktYields(end+1) = dailyVasParams.(month_field);
			end
		end
		mrktTaus = mrktTaus/12;	% Convert to years!
		
		guessPrices	= UnitDiscBondVasicek(mrktTaus,dailyVasParams);
		guessYields	= CalcDiscountBondYield(mrktTaus, guessPrices);
		
		close all;
		finalW	= 15;	% Inches? 
		finalH	= 6;	% Inches?
		rect = [0,0,finalW,finalH];
		myPlot1 = figure('PaperPosition',rect);
		hold on;
		plot(mrktTaus, mrktYields, ...
			[const.ColourTY const.LineTY const.PointTY]);
		plot(mrktTaus, guessYields, [const.ColourRF const.LineRF]);
		axis([0, max(mrktTaus), 0, 1.05*max([mrktYields guessYields])]);
		legend(const.PlotLegendTY,const.PlotLegendRF,'Location','Best');
		xlabel('Maturity in Years','FontWeight','Bold');
		ylabel('Yield to Maturity','FontWeight','Bold');
% 		titleText(1) = {'US Treasury Zero Yield Curve '};
% 		titleText(2) = {['on ' datestr(dateOfObsNum)]};
		titleText(1) = {'US Treasury Zero Yield Curve versus Vasicek'};
		titleText(2) = {['Least-Squares fit on ' datestr(dateOfObsNum)]};
		titleText(3) = {['\kappa: ' num2str(dailyVasParams.kappa) ', ' ...
			'\theta: ' num2str(dailyVasParams.theta) ', ' ...
			'r_0: ' num2str(dailyVasParams.r0) ', ' ...
			'\eta: ' num2str(dailyVasParams.eta) ...
			]};
		titleText(4) = {['for ' companyName]};
		title(titleText,'FontWeight','Bold');
		displayW	= 600; % Pixels?
		displayH	= displayW*finalH/finalW;
		set(myPlot1,'Position',[100,100,displayW,displayH]);
		pause;
		
		saveDateStr = [num2str(year(dateOfObsNum)) ...
			num2str(month(dateOfObsNum)) num2str(day(dateOfObsNum)) ...
			'_' dsBondCode];
% 		destinationFile	= [paths.ThesisImages paths.VasLeastSqrFitPre ...
% 			saveDateStr '_mrktObs'];
		destinationFile	= [paths.ThesisImages paths.VasLeastSqrFitPre ...
			saveDateStr];
		% Print at eps files for final work
		print('-depsc','-r300', destinationFile);
	end
end







