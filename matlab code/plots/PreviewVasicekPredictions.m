function PreviewVasicekPredictions()

	clc
	clear all
	tic
	const		= Constants();
	paths		= PathInfo();
	
	% Load all precalculated Vasicek interest rate model parameters so we
	% can use the instantaneous spot rates in our estimation of asset
	% dynamics.
	vasParams	= ParseInterestRateParamsVasicek();
	
	%% Show the instanteous interest rate as predicted,
	%% throughout time!!!!
	startdate = datenum('06/01/2001','dd/mm/yyyy');
	enddate = datenum('01/12/2008','dd/mm/yyyy');
	plotValues = [];
	for date_i = startdate : 1 : enddate
		if has_key(vasParams, date_i)
			dailyVasObs			= get(vasParams,date_i);
			plotValues(end+1).ObsDateNum	= dailyVasObs.ObsDateNum;
			plotValues(end).r0	= dailyVasObs.r0;
			plotValues(end).m1	= dailyVasObs.m1;
		end
	end
	xvals	= [plotValues(:).ObsDateNum];
	r0vals	= [plotValues(:).r0];
	m1vals	= [plotValues(:).m1];
	
	finalW	= 15;	% Inches? 
	finalH	= 6;	% Inches?
	rect = [0,0,finalW,finalH];
	myPlot1 = figure('PaperPosition',rect);
	hold on;
	plot(xvals, r0vals, [const.ColourRF const.LineRF]);
	plot(xvals, m1vals, [const.ColourTY const.LineTY]);
	titleText(1)	= {'Predicted Instantaneous Risk-Free Rate (Vasicek model)'};
	titleText(2)	= {'versus US Treasury 1M Yields'};
	title(titleText);
	displayW	= 600; % Pixels?
	displayH	= displayW*finalH/finalW;
	set(myPlot1,'Position',[100,100,displayW,displayH]);
	datetick('x', 'mmmyy','keepticks');
	axis([min(xvals),max(xvals),0,1.05*max([r0vals m1vals])]);
	legend('Vasicek r_0', 'US Treasury 1Month', 'Location','Best');
	xlabel('Time','FontWeight','Bold');
	ylabel('Yield to Maturity','FontWeight','Bold');
	
	pause;
	destinationFile	= [paths.ThesisImages paths.VasR0VsTreasuryPlot];
	% Print as pngs for testing
% 	print('-dpng', '-r300', destinationFile);
	% Print at eps files for final work
	print('-depsc','-r300', destinationFile);
end









