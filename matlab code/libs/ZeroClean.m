%--------------------------------------------------------------------------
% @description:	Generic library function to offer us a standard way of
%				checking critical values. Should some value HAVE to be
%				NON-ZERO to avoid Divide-By-Zero errors, we can clean it
%				using this function.
%				Note that we set the alternative value to be 'EXTREMELY'
%				small to try to avoid DBZ errors, but have the outcome of our 
%				modelling significantly affected either!
% @params:		
%	x			- Matrix of values to perform our cleansing of zero values
%				on. [n*m or m*n vector]
% @example:
%				dirtyVals	= [0,1,2,3,4,0]
%				cleanVals	= ZeroClean(dirtyVals)
%--------------------------------------------------------------------------
function [x] = ZeroClean(x)
	x(find (x == 0)) = 0.000000000001;
end
