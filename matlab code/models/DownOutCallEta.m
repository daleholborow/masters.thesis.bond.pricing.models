
function outDOCEta = DownOutCallEta(drift, stddev)
%--------------------------------------------------------------------------
% @description:	Corresponds to Li&Wong2008 Appendix C definition of model
%				parameter eta.
% @alert:		LiWong2008 paper contains a typo, their formula is missing
%				the 'equals' sign that indicates the definition of their
%				parameter 'eta'. I referred to an older version of their
%				paper to clarify this.
%----------------------------------------------------------------------
	
	outDOCEta = drift / stddev^2 + 1/2;
end