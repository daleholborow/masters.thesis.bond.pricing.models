
function outDOCC = DownOutCallC(H,r0,sigma,tau,V)
%--------------------------------------------------------------------------
% @description:	Corresponds to Li&Wong2008 Appendix C definition of model
%				parameter c
%--------------------------------------------------------------------------

	outDOCC = DownOutCallGeneric((H/V),r0,sigma,tau);
end