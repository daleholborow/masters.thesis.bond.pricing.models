function outBdVBP = UnitDiscBondBriysDeVarenne(tau,V,F,vParams,f1,f2,gamma,rho,sigma)
%--------------------------------------------------------------------------
% @description:	Briys and de Varenne model for Risky Discount Bond Pricing.
%				Calculates bond price as outlined in original BdV1997 paper,
%				but also refers to Li and Wong 2008 paper, Appendix D.3.
%				Utilises the Vasicek 1977 model to calculate the value of a
%				'risk-free' bond, before subtracting the risk premium from
%				that value.
% @notes:		
% @params:	
%	tau			- Time until maturity. (i.e. bond has tau=T-t life
%				remaining).
%	V			- Firm asset value. [expressed as a multiple of the 
%				unit-value equivalent risk-free bond?]
%	F			- Face value of the bond to be paid out at maturity,
%				[expressed as a multiple of the unit-value equivalent
%				risk-free bond?]
%	vParams		- Structure containing vasicek interest rate parameters.
%	f1			- 
%	f2			- 
%	gamma		- Ratio factor applied to the intended face value payment,
%				in order to specify the discounted default barrier. If
%				firm assets fall below [gamma*F*rfDBP] at any time, default
%				occurs. [0<=gamma<=1], where gamma=0 corresponds to the
%				original Merton pricing model. The closer that gamma gets
%				to zero, the less protection the default-boundary safety
%				coventant offers the bondholders.
%	rho			- Correlation between asset value and short-term risk free 
%				interest rate r.
%	sigma		- Volatility (as std. deviation) of asset process. Constant
%				throughout time.
% @example:		
%				tau						= 1;			% 1 year
%				params.r0			= 0.09;		% params for nested vasicek riskless bond
% 			params.eta		= 0.03;
% 			params.theta	= 0.06;
% 			params.kappa	= 0.2;
%				V							= 100;		% Company value at time t=0
%				F							= 80;			% Default boundary
%				sigma					= 0.3;		
%				rho						= 0.85;
%				gamma					= 0.8;
%				rr						= 0.5131;
%				f1						= rr; % Early and maturity default both set to same
%				f2						= rr; 
%				UnitDiscBondBriysDeVarenne(tau,V,F,params,f1,f2,gamma,rho,sigma)
%--------------------------------------------------------------------------
	
	% Perform data cleaning. For example, many parameters cannot be set to
	% be exactly zero lest we get Divide-By-Zero errors, so before we begin
	% any calculations, clean those values now:
	gamma	= ZeroClean(gamma);
	
	% The price of a riskless discount 0-coupon bond of equivalent maturity 
	% according to Vasicek, priced with a unit face value.
 	rfDBP	= UnitDiscBondVasicek(tau,vParams);
	
	% Now, we first calculate the values of all the individual sections of
	% the BdV model and then compile them once at the end. We do this so
	% that we can make as few computations as possible.
	L0 = L_0(V, F, rfDBP);
	Q0 = Q_0(V, F, rfDBP, gamma);
% 	LoOverQo = L0/Q0
	sumT = Sum_T(tau,rho,sigma,vParams.eta,vParams.kappa);
	D1 = D(L0, sumT);
	D2 = D1 - sqrt(sumT);
	D3 = D(Q0, sumT);
	D4 = D3 - sqrt(sumT);
	D5 = D((Q0^2/L0), sumT);
	D6 = D5 - sqrt(sumT);
	PEL01 = P_E_L0_1(L0, D1, D2);
	PEQ0L0Q0 = P_E_Q0_L0_Q0(L0, Q0, D5, D6);
	
	% Finally, return the price for the risky BdV discount bond
	partA = (1 - PEL01 + PEQ0L0Q0);
	partB = ((1-f1) * L0 * (N(-D3) + N(-D4)/Q0));
	partC = ((1-f2) * L0 * (N(D3)-N(D1) + (N(D4)-N(D6))/Q0));
	
	outBdVBP = F*rfDBP*(partA - partB - partC);
	
	%%% End Bond Pricing Logic %%%
	
	
	
	
	%%% Begin Private BdV Bond Pricing Methods %%% 
	
	%--------------------------------------------------------------------------
	% @description:	See Appendix D.3 from Li&Wong2008 or Equation 11
	%				from BdV1997.
	% @params:	
	%	x			- The specific input value to log, depending on which 'd'
	%				parameter is being calculated (i.e. d1,d3,d5).
	%	sumT		- Output from the Sum_T method
	% @usage:		PRIVATE METHOD - NOT TO BE USED PUBLICLY!!! Should ONLY
	%				EVER call this function from the BdVUnitDiscBond function.
	%--------------------------------------------------------------------------
	function outD = D(x, sumT)
		outD = (log(x) + 0.5*sumT)/sqrt(sumT);
	end


	%--------------------------------------------------------------------------
	% @description:	Calculate a ratio of company asset value at time zero over 
	%				the comparitive value of the riskless discount bond at
	%				maturity.
	%				See Appendix D.3 from Li and Wong2008.
	% @usage:		PRIVATE METHOD - NOT TO BE USED PUBLICLY!!! Should ONLY
	%				EVER call this function from the BdVUnitDiscBond function.
	%--------------------------------------------------------------------------
	function out = L_0(V, F, rfBP)
		out = V/(F*rfBP);
	end


	%--------------------------------------------------------------------------
	% @description:	Calculate a ratio of company asset value at time zero over 
	%				the comparitive value of the riskless discount bond at
	%				maturity divided by H.
	% @usage:		PRIVATE METHOD - NOT TO BE USED PUBLICLY!!! Should ONLY
	%				EVER call this function from the BdVUnitDiscBond function.
	%--------------------------------------------------------------------------
	function out = Q_0(V, F, rfBP, gamma)
		out = V/(gamma*F*rfBP);
	end


	%--------------------------------------------------------------------------
	% @description:	See Appendix D.3 from Li and Wong (2006)
	% @params:	
	%	L_0			- output from the L_0() method
	%	D_1			- output from the D_1() method
	%	D_2			- output from the D_2() method
	% @usage:		PRIVATE METHOD - NOT TO BE USED PUBLICLY!!! Should ONLY
	%				EVER call this function from the BdVUnitDiscBond function.
	%--------------------------------------------------------------------------
	function out = P_E_L0_1(L_0, D_1, D_2)
		out = -L_0*N(-D_1) + N(-D_2);
	end


	%--------------------------------------------------------------------------
	% @description:	See Appendix D.3 from Li and Wong (2006)
	% @params:	
	%	L_0			- output from the L_0() method
	%	Q_0			- output from the Q_0() method
	%	D_5			- output from the D_5() method
	%	D_6			- output from the D_6() method
	% @usage:		PRIVATE METHOD - NOT TO BE USED PUBLICLY!!! Should ONLY
	%				EVER call this function from the BdVUnitDiscBond function.
	%--------------------------------------------------------------------------
	function out = P_E_Q0_L0_Q0(L_0, Q_0, D_5, D_6)
		out = -Q_0*N(-D_5) + (L_0/Q_0)*N(-D_6);
	end


	%--------------------------------------------------------------------------
	% @description:	All integrals evaluated at leftmost point of rectangle.
	%--------------------------------------------------------------------------
	function outSumT = Sum_T(tau,rho,sigma,eta,kappa)

		% Experiment to trade off speed and accuracy.
		numIncr	= 200;
		dt		= tau/numIncr;

		% Store the total value of the sumT paramater in the BdV bond pricing
		% formula
		outSumT = 0;
		for t_i = 0 : dt : (tau-dt)
			vasBondDynamics = VasicekBondDynamics(0,t_i,kappa,eta);

			outSumT = outSumT + ((rho*sigma + vasBondDynamics)^2 + ...
				(1-rho^2)*sigma^2)*dt;
		end
	end


	%--------------------------------------------------------------------------
	% @description:	See BdV1997 paper, Section 2, Equation 3.
	%				Describes the volatility dynamics of a risk-free zero
	%				coupon bond, which matures at time=T, described at some
	%				time=t under the risk-neutral probability measure, when
	%				that risk-free bond is priced according to Vasicek interest
	%				rate model.
	%--------------------------------------------------------------------------
	function out = VasicekBondDynamics(t_lower,t_upper,kappa,eta)

		% Experiment to trade off speed and accuracy.
		numIncr	= 100;
		du		= (t_upper - t_lower) / numIncr;

		out_sum = 0;
		for out_i = t_lower : du : (t_upper-du)
			% Calculate the inner integral, which is easy because intergrand is
			% deterministic and constant. We make use of that fact to
			% perform the
			% exact integral instead of the Riemann approximation which appears
			% in the BdV equation, since we can thus avoid a computationally
			% expensive operation.
			in_sum = -kappa*(out_i - t_lower);

			% Raise e to the power of the inner integral and add to the outer
			% summation:
			out_sum = out_sum + exp(in_sum)*du;
		end

		% Finally, multiply the integral by the volatility of the risk-free
		% rate
		out = eta*out_sum;
	end
	
end


	









