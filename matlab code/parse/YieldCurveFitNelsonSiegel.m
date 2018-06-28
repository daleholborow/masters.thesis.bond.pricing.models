function params = NelsonSiegelCurveFit(mrktTaus, mrktYields)
%--------------------------------------------------------------------------
% @description:	Attempt to estimate the parameters of the Nelson-Spiegel 
%				1987 short-term risk-free interest rate 
%				term structure model of yields, from their paper
%				'Parsimonious modelling of Yield Curves'. We do this by
%				using least-squares for a cross-sectional data set, that
%				is, a structural yield-to-maturity curve for zero-coupon 
% 				treasury instruments.
% @note:		This optimisation hinges on the choice of zeta, because
%				the subsequent values of the betaX's can be explicitly
%				backed out of the market observations. Hence, this should
%				be a very precise method of parameter estimation, and is
%				in fact about 8 times faster than when estimating all four
%				parameters using "lsqnonlin", for example. 
%				I made slight tweaks to the code and prevented it from
%				erroring when encountering a zero tau, but full credit to
%				Dimitri.
% @params:
%	mrktTaus	- Matrix of times to maturity for which we are calculating 
%				the yield-to-maturity under Nelson-Siegel model. Must be a 
%				1*n or an n*1 matrix... m*n will cause irregular results.
%	mrktYields	- Matrix of observed yields-to-maturity that correspond to
%				the matching index in mrktTaus. Yields should be passed in
%				represented as percentage values, e.g. 4.5% should be
%				passed in as 0.045, NOT 4.5, so that initial guesses
%				for the optimisation for pars(2) and pars(4) are in
%				proportion to the rest.
% @example:
%				mrktTaus		= [.125,.25,.5,1,2,3,5,7,10,20,30];
%				mrktYields	=
%				[2.57,3.18,3.45,3.34,3.12,3.13,3.52,3.77,4.11,4.56,4.51];
%				mrktYields	= mrktYields/100;
%				params = NelsonSiegelCurveFit(mrktTaus, mrktYields)
% @author:		Dale Holborow, daleholborow@hotmail.com, August 7, 2008
% @acknowledge:	Dimitri Shvorob, dimitri.shvorob@vanderbilt.edu, 12/30/07
%				http://www.mathworks.com/matlabcentral/fileexchange/loadFil
%				e.do?objectId=18160&objectType=file
%--------------------------------------------------------------------------
	
	% Perform data cleaning. For example, many parameters cannot be set to
	% be exactly zero lest we get Divide-By-Zero errors, so before we begin
	% any calculations, clean those values now:
	mrktTaus	= ZeroClean(mrktTaus);
	mrktYields	= ZeroClean(mrktYields);
	
	params.zeta	= fminbnd(@(tmpZeta) NelsonSiegelSumErrors(tmpZeta),0,15);
	tmpBetas	= LeastSqrBetas(params.zeta);
	params.beta1= tmpBetas(1);
	params.beta2= tmpBetas(2);
	params.beta3= tmpBetas(3);
	
	
	%----------------------------------------------------------------------
	% @description:	Function to get optimisation value for the fminbnd
	%				procedure when trying to predict optimum zeta value.
	function[f] = NelsonSiegelSumErrors(tmpZeta)
		[b,f] = LeastSqrBetas(tmpZeta);
	end
	
	%----------------------------------------------------------------------
	% @description:	For some potential optimal zeta value, calculate the 
	%				corresponding values of the betas, given that they can
	%				be calculated explicitly as a set of linear factors.
	%				This method subsequently appears to be far more precice
	%				than output from 'lsqcurvefit' and other such
	%				optimisation procedures, and vastly quicker as well!
	function[b,varargout] = LeastSqrBetas(tmpZeta)
		i = mrktTaus(:)/tmpZeta;
		j = 1-exp(-i);
		n = length(mrktTaus);
		z = [ones(n,1) j./i (j./i)+j-1];
		b = (z'*z)\(z'*mrktYields(:)); 
		e = mrktYields(:) - z*b;
		varargout(1) = {e'*e};
	end
end
