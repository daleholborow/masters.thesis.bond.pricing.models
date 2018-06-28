
function outDOCA = DownOutCallA(H,r0,sigma,tau,V,X)
%--------------------------------------------------------------------------
% @description:	Corresponds to Li&Wong2008 Appendix C definition of model
%				parameter a
%--------------------------------------------------------------------------

	if X >= H
		outDOCA = DownOutCallGeneric((V/X),r0,sigma,tau);
	else
		outDOCA = DownOutCallGeneric((V/H),r0,sigma,tau);
	end
end