function [ImpliedValue] = ImpliedAssetValueBlackScholes(K,mu,r0,sigma,S,tau)
%----------------------------------------------------------------------
% @description:	ImpliedAssetValueBlackScholes
%				Calculate the implied asset value given all other
%				relevant option pricing paramters for a standard
%				Black-Scholes European call option.
% @params:
%	K			- Strike price
%	mu			- 
%	r0			- 
%	sigma		- 
%	S			- 
%	tau			- 
% @example:
%				
%----------------------------------------------------------------------
	
	%%% Begin the logic to find optimal bond price %%%
	
	% We assume that the asset value is strictly non-negative when
	% searching for its implied value. Make the (not too bold) assumption
	% that asset value is no more than 100 times the strikes price, when setting
	% a test range.
	range		= [0, K*100];
	
	% Specify some optimisation options:
	options				= optimset('fzero');
	options.TolFun		= 10^-5;
	options.MaxIter		= 1*200;
	options.MaxFunEvals	= 1*200;
	options.Display		= 'notify';	% Notify only if it did NOT converge.
% 	options.Display		= 'iter';	
	options.FunValCheck	= 'on';
	
	
	% Search for the implied value of the asset, based on the current value
	% of the option and its defining parameters:
	ImpliedValue = fzero(@(V) ZeroBSCallEuro(S,K,r0,sigma,tau,V),range,options);
	
	%%%
	%%% End logic to find optimal bond price 
	%%%
	
	
	%%%
	%%% Begin private methods
	%%%
	
	%----------------------------------------------------------------------
	% @description: Implied asset value objective function.
	%				The objective function simply calculates the difference 
	%				between observed market value, or price, of the option 
	%				and the theoretical value derived from the 
	%				Black-Scholes model with some estimated asset value... 
	%				We aim to minimise the difference!
	% @notes:		Based on the bsimplv.m functionality included by
	%				default in MatLab.
	%----------------------------------------------------------------------
	function zero = ZeroBSCallEuro(S,K,r0,sigma,tau,V)
		
		% Inbuilt Matlab library for BS options... is SLOW!! :(
 		%[call put]	= blsprice(V, K, r0, tau, sigma, 0);
	  	%zero	= S - call;
		
		% Use my Black-Scholes call function, NOT the default Matlab one...
		% The default has some nice error checking etc, but it is VASTLY
		% slower than my version when we are forced to do the checks one by
		% one, such as when searching for optimum parameters.
		zero = S - BlackScholesEuroCall(K,r0,sigma,tau,V);
	end
end



