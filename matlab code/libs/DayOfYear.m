function dayOfYear = DayOfYear(theDateNum)
%------------------------------------------------------------------------
% @description:		
% @acknowledgement:	Peter J. Acklam, http://home.online.no/~pjacklam
%------------------------------------------------------------------------

	% Get the specific values of the date passed in for processing
	theDateVec	= datevec(theDateNum);
	day			= theDateVec(3);
	month		= theDateVec(2);
	year		= theDateVec(1);
	
	days_in_prev_months = [0 31 59 90 120 151 181 212 243 273 304 334];
	
	dayOfYear = days_in_prev_months(month) ...		% days in prev. months
		+ ( isleapyear(year) & ( month > 2 ) ) ...	% leap day
		+ day;										% day in month
end	
