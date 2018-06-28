
function outDOCG = DownOutCallGeneric(logInput,r0,sigma,tau)
%----------------------------------------------------------------------
% @description:	DownOutCallGeneric
%				Generic function to generate Li&Wong2008 Appendix C DOC
%				option pricing formula internal parameters a, b and c.
%----------------------------------------------------------------------
% 	if (sigma == 0)
% 		disp('should have died here');
% 		error('died here');
% 	elseif (tau == 0)
% 		disp('should have died here insetad');
% 		error('died thereerere');
% 	end
	outDOCG = (log(logInput) + (r0 + 0.5*sigma^2)*tau) / (sigma*sqrt(tau));
end