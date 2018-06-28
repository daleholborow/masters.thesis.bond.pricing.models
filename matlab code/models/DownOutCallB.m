
function outDOCB = DownOutCallB(H,r0,sig,tau,V,X)
%--------------------------------------------------------------------------
% @description:	Corresponds to Li&Wong2008 Appendix C definition of model
%				parameter b
%--------------------------------------------------------------------------

	if X >= H
		outDOCB = DownOutCallGeneric((H^2/(V*X)),r0,sig,tau);
	else
		outDOCB = DownOutCallGeneric((H/V),r0,sig,tau);
	end
end