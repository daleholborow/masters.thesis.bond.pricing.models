function [LogLikelihoodSum] = LogLikelihoodSummation(estimMode,implAssetVals,firm,estimYr,vasParams,mu,sigma,H)
%--------------------------------------------------------------------------
% @description:	
% % % %				Large values for the default boundary cause infinity values
% % % %				in the MLE occasionally, as it is raised to high powers. As
% % % %				a solution, before we perform the MLE, we rescale all our
% % % %				values to use a face value (i.e. a default boundary) of
% % % %				unit value, and scale our asset value accordingly. 
%--------------------------------------------------------------------------

	% Retrieve constants and path information 
	const		= Constants();
	paths		= PathInfo();
	
	% Store each element required to calculate the total of the MLE
	% functions
	LogLikelihoodSums		= [];
	
	% Get start and end dates of the year for which we are estimating
	% parameters
	estimYrStartNum	= datenum(['01/01/' num2str(estimYr)], const.DateStringAU);
	estimYrEndNum	= datenum(['31/12/' num2str(estimYr)], const.DateStringAU);
	
	% To perform asset estimation, we need to know how many shares there
	% are, and also the total liabilities. For these, we need to turn to
	% the end-of-year report from the year PRIOR to our estimation year:
	priorYr			= estimYr-1;
	priorYrFinObs	= get(firm.Financials, priorYr);
	defBoundary		= priorYrFinObs.TotLiab;
	
	% MUST calculate maturities IN YEARS, because all our volatility and
	% drift params are specified on a yearly basis!! Decide how many
	% days are in this year.
	daysInEstimYear = DaysInYear(estimYr);
	
	
	% Retrieve all the asset valuations by examining the day on which they
	% were made.
	[assetDtKeys assetVals] = dump(implAssetVals);
	assetDtKeys				= cell2mat(assetDtKeys);
	assetVals				= cell2mat(assetVals);
	% The log of all the observation dates, for the transitional density
	assetValLogs			= log(assetVals);
	
	
	% Loop through each day in the year, calculating transitional densities
	% for the implied asset valuations.
	for dayIndex = 2 : 1 : length(assetDtKeys)
		
		currDayNum		= assetDtKeys(dayIndex);
		prevDayNum		= assetDtKeys(dayIndex-1);
		tDiffInYrs		= (currDayNum-prevDayNum)/365;
		
		currDayVal		= assetVals(dayIndex);
		currDayLogVal	= assetValLogs(dayIndex);
		prevDayLogVal	= assetValLogs(dayIndex-1);
		
		% Time to maturity (i.e. time till end of year)
		tau					= (estimYrEndNum - currDayNum)/daysInEstimYear;

		% Get interest rate params estimated based on daily term
		% structure
		dailyVasParams		= get(vasParams,currDayNum);
		
		% Calc the loglikelihood values for each transitional date etc
		% For some parameter estimates, we get very small values, and 
		% subsequently get LogOfZero warnings. Matlab seems to be
		% capable of continuing on and getting valid results, so suppress
		% the warning messages temporarily, since they just slow our
		% calculations down.
		warning off MATLAB:log:logOfZero;
		
		
		% Log likelihood asset dynamics parameter estimation via the Merton model:
		if strcmp(const.ModeMerton,estimMode)
			
			% Transitional density of Merton model
			gIndex		= MertonG(mu,sigma,tDiffInYrs,currDayLogVal,prevDayLogVal);
			% Delta of Merton model
			md1			= MertonD1(defBoundary,dailyVasParams.r0,sigma,tau,currDayVal);
			% Store loglikelihood estimate for this transition
			optionDelta	= N(md1);
			
		% Log likelihood asset dynamics parameter estimation via the Longstaff-Schwartz model:
		elseif strcmp(const.ModeLS,estimMode)
			
			bb			= BarrierB(defBoundary);
			bEta		= DownOutCallEta(mu, sigma);
			eqtyRebate	= 0;	% Equity holders receive nothing on default
			
			% Transitional density of LS model
			gIndex		= BarrierG(defBoundary,mu,sigma,tDiffInYrs,currDayLogVal,prevDayLogVal,bb,bEta);
			% Delta of LS model, according to DOC option pricing
			% methodology
			optionDelta	= DownOutCallDelta(...
				defBoundary,...
				dailyVasParams.r0, ...
				eqtyRebate, ...
				sigma,...
				tau,...
				currDayVal,...
				defBoundary);
			% Store loglikelihood estimate for this transition
% 			logg = log(gIndex)
% 			minusbit = log(currDayVal*lsDelta)
% 			
% 			if ~isfinite(logg)
% 				gIndex
% 				lsDelta
% 				mu
% 				sigma
% 				
% 				error('died here');
% 			end
			
% 			LogLikelihoodSums(end+1) = log(gIndex) - log(currDayVal*lsDelta)
		
		else
			error(['Error and Die: Undetected asset estimation method detected']);
		end
		
		% Have to perform some error checking, since sometimes the log of
		% zero causes errors because it returns infinite values etc. We
		% catch this scenario, and instead, just set the likelihood to
		% zero...is the best we can do to work around the situation.
		elementalSum = log(gIndex) - log(currDayVal*optionDelta);
		if isinf(elementalSum) || isnan(elementalSum)
			elementalSum = 0;
		end
		LogLikelihoodSums(end+1) = elementalSum;
		
		% Don't forget to reenable the warnings
		warning on MATLAB:log:logOfZero;
	end
	
	% Sum all the daily transitional values ready for return
	LogLikelihoodSum	= sum(LogLikelihoodSums);
	
	%%%
	%%% End log-likelihood summation main logic
	%%% 
	
	
	
	
	%%%
	%%% Begin private method logic
	%%%
		
	%----------------------------------------------------------------------
	% @description:	Li&Wong2008 Section 2.4.2 Equation 3
	% @params:
	%	H			- default boundary
	%	
	%----------------------------------------------------------------------
	function [bg] = BarrierG(H,mu,sigma,tDiffInYrs,vi,viM1,bb,bnu)
		
		% By default, the transitional density value is zero, unless the 
		% value of the underlying asset is larger than the barrier. In 
		% that case we must explicitly calculate the density.
		bg = 0;
		
		if viM1 > log(H)
			bg = BarrierVarPhi(mu,sigma,tDiffInYrs,(vi-viM1)) - ...
				exp(2*(bnu-1)*(bb-viM1))*BarrierVarPhi(mu,sigma,tDiffInYrs,(vi+viM1-2*bb));
		end
	end
	
	
	%----------------------------------------------------------------------
	% @description:	Li&Wong2008 Section 2.4.2 Equation 3
	%----------------------------------------------------------------------
	function [bVarPhi] = BarrierVarPhi(mu,sigma,tDiffInYrs,x)
		bVarPhi = 1/(sigma*sqrt(2*pi*(tDiffInYrs))) * ...
			exp(-((x-((mu-0.5*sigma^2)*(tDiffInYrs)))^2)/...
			(2*sigma^2*(tDiffInYrs)));
		
% 		if bVarPhi == 0
% 			x = x
% 			aa = 1/(sigma*sqrt(2*pi*(tDiffInYrs)))
% 			sigma^2
% 			tDiffInYrs
% 			
% 			inner = -((x-((mu-0.5*sigma^2)*(tDiffInYrs)))^2)/(2*sigma^2*(tDiffInYrs))
% 			bb = exp(-((x-((mu-0.5*sigma^2)*(tDiffInYrs)))^2)/(2*sigma^2*(tDiffInYrs)))
% 			
% 			error('it was zero')
% 		end
	end
	
	%----------------------------------------------------------------------
	% @description:	Li&Wong2008 Section 2.4.2 Equation 3
	%----------------------------------------------------------------------
	function [bb] = BarrierB(H)
		bb = log(H);
	end
	
		
	%----------------------------------------------------------------------
	% @description:	The density function of log(Vt) given under the
	%				physical probability measure. See Li&Wong2008, Appendix
	%				B for notation.
	%----------------------------------------------------------------------
	function [mg] = MertonG(mu,sigma,tDiffInYrs,vi,viM1)
		mg = 1/(sigma*sqrt(2*pi*(tDiffInYrs))) * ...
			exp(-((vi-viM1-((mu-0.5*sigma^2)*(tDiffInYrs)))^2)/...
			(2*sigma^2*(tDiffInYrs)));
	end


	%--------------------------------------------------------------------------
	% @description: Corresponds to LiWong2008 Appendix B definition of 
	%				Black-Scholes standard call option model parameter d1
	% @params:
	%	K			- Book value of corporate liabilities
	%--------------------------------------------------------------------------
	function [md1] = MertonD1(K,r0,sigma,tau,V)
		md1 = (log(V/K) + (r0+0.5*sigma^2)*tau)/(sigma*sqrt(tau));
	end
	
end













