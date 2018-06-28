function [ImpliedValue] = ImpliedAssetValueDownAndOutCall(K,mu,r0,sigma,S,tau)
%----------------------------------------------------------------------
% @description:	ImpliedAssetValueDownAndOutCall
%				Calculate the implied asset value given all other
%				relevant option pricing paramters for a down-and-out call
%				option (also known as a barrier option).
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
	% that asset value is no more than 75 times the strike price, when setting
	% a test range. Can't evaluate at zero, because NaN errors occur.
	% Note that we can also use the knowledge that for our implied pricing,
	% the firm obviously hasn't gone broke, so asset value guess should be
	% above the strike price. We set equity strike to a minimum of 3/4 of
	% total liabilities, just for the sake of being accomodating.
	range		= [K*0.75, K*75];
	
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
	ImpliedValue = fzero(@(V) ZeroDOCCall(V,K,r0,S,sigma,tau),range,options);
	
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
	%				Down-and-Out call option model with some estimated 
	%				asset value... 
	%				We aim to minimise the difference!
	% @params:
	%	
	%----------------------------------------------------------------------
	function zero = ZeroDOCCall(V,K,r0,S,sigma,tau)
		
		% In the event of default, we assume equity holders receive zero
		% rebate:
		R		= 0;
		
		% When calculating implied asset values, we take the default 
		% boundary to equal the total liabilities. Declare this for
		% explicitness!
		H		= K;
		
		zero = S - DownOutCall(H,r0,R,sigma,tau,V,K);
	end
end



