function [daysInYear] = DaysInYear(year)
%----------------------------------------------------------------------
% @description: DaysInYear
%				Calculate how many days there are in any given year.
%----------------------------------------------------------------------
	daysInYear = 365;
	if isleapyear(year)
		daysInYear = 366;
	end
end