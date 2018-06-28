function [drift volatility] = CalcActualYrlyDriftAndVolByObservations(assetObs)
	numDailyObsForYr	= length(assetObs);
	dailyAssValsLog		= log(assetObs);
	dailyAssValsLogDiff	= diff(dailyAssValsLog);
	drift				= mean(dailyAssValsLogDiff)*numDailyObsForYr;
	volatility			= std(dailyAssValsLogDiff)*sqrt(numDailyObsForYr);
end