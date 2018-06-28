%--------------------------------------------------------------------------
% @description:	Generic library function to shorten the notation for 
%				cumulative standard normal distribution function
%--------------------------------------------------------------------------
function out = N(x)
	out = normcdf(x,0,1);
end