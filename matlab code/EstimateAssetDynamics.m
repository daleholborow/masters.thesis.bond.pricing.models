function EstimateAssetDynamics()
%--------------------------------------------------------------------------
% @description:	
%--------------------------------------------------------------------------	
	tic;
	clc;
	clear all;
	paths		= PathInfo();
	const		= Constants();
	
	% Load all precalculated Vasicek interest rate model parameters so we
	% can use the instantaneous spot rates in our estimation of asset
	% dynamics.
	vasParams	= ParseInterestRateParamsVasicek();
	
	
	% Retrieve all the preliminary details about all the firms for whom we
	% wish to perform bond pricing:
	firms = ParseCompanyList();
	
	for firm_i = 1 : 1 : length(firms)
		
% 		if firm_i == 2
% % 			error('faild here for testing purposes');
% 			break
% 		end
		
		firm = firms(firm_i);
		
		% Load up as much historical bond price information as possible.
		firm.Bond.Prices = ParseBondPricesByDSBondCode(firm.Bond.DSBondCode);
		
		% Load up historical equity information (adjusted closing prices) so we can 
		% calculate the implied asset dynamics
		firm.Equity		= ParseEquityByDSBondCode(firm.Bond.DSBondCode);

		% Load up historical financial statement information about the company
		firm.Financials	= ParseFinancialsByDSBondCode(firm.Bond.DSBondCode);

		% Preallocate firm assets params storage space for each pricing model
		firm.Assets.MertonAssetParams	= hashtable;
		firm.Assets.LSAssetParams		= hashtable;
	% 	firm.Assets.BdVAssetParams		= hashtable;

		% Based on the year in which we see a bond issued, estimate the asset
		% dynamics for the previous year.
		estimYr			= year(firm.Bond.IssueDateNum)-1;


	% 	for yrInd = estimYr : 1 : year(firm.Bond.IssueDateNum)
		% While developing, only work on one year's values...
% 		disp('Dale, remove this year restriction hack');
% 		for yrInd = estimYr : 1 : estimYr
		for yrInd = estimYr : 1 : 2007
			
% 			yrInd = yrInd
			
			try

				% For each year of interest, and each bond pricing model, calculate
				% and store the implied asset parameters.
				% Store the results of the different methods of parameter estimation,
				% keyed on the year for which they are applicable.

				% First, estimate the yearly asset dynamics using the Merton model
				estimMode		= const.ModeMerton;
				yrlyParamsMert	= EstimateAssetDynamicsByFirmAndYear(estimMode,vasParams,firm,yrInd);
				firm.Assets.MertonAssetParams = put(firm.Assets.MertonAssetParams, yrInd, yrlyParamsMert);
				disp(['Calculated Merton MLE of ' num2str(yrInd) ' asset params-> mu:' num2str(yrlyParamsMert.mu) ', sigma: ' num2str(yrlyParamsMert.sigma)]);


				% Second, estimate the yearly asset dynamics using the LS model
				estimMode		= const.ModeLS;
				yrlyParamsLS	= EstimateAssetDynamicsByFirmAndYear(estimMode,vasParams,firm,yrInd);
				firm.Assets.LSAssetParams = put(firm.Assets.LSAssetParams, yrInd, yrlyParamsLS);
				disp(['Calculated LS MLE of ' num2str(yrInd) ' asset params-> mu:' num2str(yrlyParamsLS.mu) ', sigma: ' num2str(yrlyParamsLS.sigma)]);

				disp(['Estimated asset values for firm: ' firm.CompName ' for year: ' num2str(yrInd)]);
				
			catch
				disp(['Tried to estimate ' firm.CompName ' for the year ' num2str(yrInd) ' but failed']);
			end
		end
		
		% Finally, save the individual firm objects as matlab binary files
		% so they can be retrieved very quickly in future.
		save([paths.PreCalcFirmHistory firm.Bond.DSBondCode], 'firm');
		
		disp(['Total time taken: ' num2str(toc)]);
		
		
		
	end
	
	% Now patch our records by calculating the pure proxy, and also Merton
	% and LS correlation coefficients between assets and interest rates
	CalculateAndStorePureProxyDynamics();
	
	
	
	
	
	
	%%%
	%%% Begin logic for private methods 
	%%%
	
	%----------------------------------------------------------------------
	% 
	%----------------------------------------------------------------------
	function logLikeSum = GenericLogLikelihood(pars,estimMode,vasParams,firm,estimYr)
		
		% Sometimes the search algorithm passes in negative and/or zero values 
		% for mu
		% and sigma, but of course, we can't have a negative sigma value.
		% Catch this now by letting the optimiser know that negative sigmas
		% are BAD, we set the "minimal" value to something massive so that
		% it doesn't continue processing, and also doesn't appear to be a 
		% valid path to continue with when searching for optimal
		% parameters.
		
		% Tiny sigma values fail in MLE models, because they result in
		% transition probabilities of zero, which in turn trigger infinite
		% values in our log-likelihood calculations. We have to manually
		% test for these, and to assist the optimiser search, we set a
		% minimum 'realistic' volatility value of 0.01.
		sigmaMin	= 0.01;
% 		muGuessedTmp = pars(1)
% 		sigmaGuessedTmp = pars(2)
		if pars(2) <= sigmaMin
			% Invalid sigma, exit early and let search algorithm know it
			% tried something naughty... set to artificially massive
			% positive number to tell our fMINsearch function to head the
			% other direction:
			disp(['Guessed a small value of sigma, turn around now:' num2str(pars(2))]);
			logLikeSum = 99999999;
		else
			% Retrieve the guessed values of the drift and volatility, price
			% the implied asset value, and solve for the maximum of the 
			% log-likelihood. 
			muGuess			= pars(1);
			sigmaGuess		= pars(2);
			
			% For a specified pricing model, and a given parameter set, and a collection of observed
			% market prices of equity, calculate the implied asset value at
			% each point in time, so we can then perform MLE to estimate
			% the driving asset dynamics:
			implAssetVals	= CalcCalendarYearImpliedAssetValues(estimMode, vasParams,firm,estimYr,muGuess,sigmaGuess);
			
% 			[xvals yvals] = dump(implAssetVals);
% 			xvals		= cell2mat(xvals);
% 			yvals		= cell2mat(yvals);
% 			colours		= ['r-', 'b-', 'g-'];
% 			colInd		= floor(rand*2)+1
% 			plot(xvals, yvals, colours(colInd))
% 			hold on
% 			pause(0.5)
			
			
			% Now calculate the loglikelihood of the MLE function for these
			% parameter estimates, so we can establish which param values are
			% most likely:
			logLikeSum = LogLikelihoodSummation(estimMode,implAssetVals,firm,estimYr,vasParams,muGuess,sigmaGuess);
			
			
			% Since we want to MAXIMISE the log-likelihood function, but we
			% are using the FMINSEARCH function, we need to negate our
			% results which are coming back from the loglikelihood 
			logLikeSum = -logLikeSum;
			
% 			if isnan(logLikeSum) || isinf(logLikeSum)
% 				muGuess
% 				sigmaGuess
% 				logLikeSum
% 				error('Not a Number encountered');
% 			end
		end
		
% 		logLikeSum = logLikeSum
	end


	
	function [yrlyParams] = EstimateAssetDynamicsByFirmAndYear(estimMode,vasParams,firm,estimYr)
		
		% Guess some starting parameters for the asset price, to initialise our
		% optimisation process. These aren't especially important but since we
		% have to declare the variables anyway, set them to something random in
		% the rough vacinity of 'real world' values. 
		% For some stupid reason, randomising these values seems to cause
		% problems, but hardcoded guesses dont? Even though our initial 
		% hard coded guesses are typically miles off anyway??
% 		guessPars(1)			= 0.2*rand;		% mu
% 		guessPars(2)			= 0.4*rand;		% sigma
		guessPars(1)			= 0.2;		% mu
		guessPars(2)			= 0.4;		% sigma


		% Configure search options to make sure that our optimal asset dynamics
		% values are a good estimate. Increase the number of trials, just in
		% case. With 250 observations over a 1 year time period, the number of
		% calculations used is typically well below our limits, but we have CPU
		% to spare, so lets aim for EXTREME attempts to get estimate accuracy.
		% We go for such extremely large estimation numbers because sometimes,
		% the parameter estimates are problematic, they run thru maximum
		% searches without finding good values, without much consistency to
		% this performance. In an attempt to never encounter this problem, we 
		% get brutal....
		options				= optimset('fminsearch');
		options.TolFun		= 10^-5;
		options.MaxIter		= 2*400;
		options.MaxFunEvals	= 2*800;	% 2*700 wasn't solving all scenarios!
		options.Display		= 'notify';	% Notify only if it did NOT converge.
		options.FunValCheck	= 'on';


		% Search for the optimum mu and sigma for the dynamics of the asset
		% value evolution process, using whichever implied asset pricing mode 
		% was requested:
		[results,fval,exitflag,output] = fminsearch(@(pars) GenericLogLikelihood(pars,estimMode,vasParams,firm,estimYr),guessPars,options);

		% Retrieve the estimates for the asset parameters and store them ready
		% to be returned by the function.
		yrlyParams.mu			= results(1);
		yrlyParams.sigma		= results(2);
		
		

		% Potentiall BUGS in this code, because it doesnt make sure the
		% values are all sorted correctly so that dates correspond!!
		% FIXED THIS IN THE CALCULATEANDSTOREPUREPROXYDYNAMICS.M file!!
		
% 		% Lastly, want to calculate the correlation coefficient between the
% 		% asset values and the changes in instantaneous interest rate r0:
% 		implAssetVals	= CalcCalendarYearImpliedAssetValues(estimMode, vasParams,firm,estimYr,yrlyParams.mu,yrlyParams.sigma);		
% 		% Get out the asset valuations and the corresponding times, so we
% 		% can compare assets and interest rates on the same day:
% 		yrStartNum		= datenum(['01/01/' num2str(estimYr)], const.DateStringAU);
% 		yrEndNum		= datenum(['31/12/' num2str(estimYr)], const.DateStringAU);
% 		[keysA valsA]	= dump(implAssetVals);
% 		keysA			= cell2mat(keysA);
% 		valsA			= cell2mat(valsA);
% 		keyIndA			= find(keysA > yrStartNum & keysA < yrEndNum);
% 		xValsA			= keysA(keyIndA);
% 		yValsA			= valsA(keyIndA);
% 		
% 		% Retrieve the interest rate observations on the days which we observe
% 		% asset valuations, in order to calculate their correlation
% 		% coefficients.
% 		[keysV valsV]	= dump(vasParams);
% 		keysV			= cell2mat(keysV);
% 		valsV			= cell2mat(valsV);
% 		keyIndV			= find(keysA);
% 		xValsV			= keysV(keyIndV);
% 		yValsV			= [valsV(keyIndV).r0]';
% 		
% 		% Calc corr-coeff and store it now
% 		yrlyParams.rho	= corr2(yValsA, yValsV);
	end
	
end



























