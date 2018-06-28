function [PredictedBondPrice ImpliedYield] = PredictCouponBondPriceAndYield(estimMode,priceDtNum,firm,vasParams,rr_c,rr_p)
%--------------------------------------------------------------------------
% @description:	Predicts bond as though it were issued with a unit face
%				value?????
% @params:
%	
%--------------------------------------------------------------------------

	
	const		= Constants();
	
	% Make sure we aren't trying to price a bond before it was issued, or
	% after it matures!!
	if firm.Bond.IssueDateNum > priceDtNum || firm.Bond.MatDateNum <= priceDtNum
		error(['Processing halted: Cannot price a bond outside its lifetime!']);
	end
	
	% Variables to store total price of coupons and price of face value
	% payment
	cPrices	= [];
	fvPrice	= [];
	

	% Get total liabilities as best we know them for the year when we are
	% pricing the bond. Note: When we are pricing the bond on 
	% issue, we take the book value from financial
	% statement of previous year and add the liability of the new bond, 
	% otherwise, bond is already absorbed into previous year liability 
	% value. 
	prevYr			= year(priceDtNum)-1;
	prevYrFinObs	= get(firm.Financials, prevYr);
	
	
	% MUST calculate maturities IN YEARS, because all our volatility and
	% drift params are specified on a yearly basis!! Decide how many
	% days are in this year that we are using to price the bond:
	daysInEstimYear = DaysInYear(year(priceDtNum));
	
	% Establish the start and end dates of the year we intend to analyse
	estimYrStartNum	= datenum(['01/01/' num2str(year(priceDtNum))], const.DateStringAU);
	estimYrEndNum	= datenum(['31/12/' num2str(year(priceDtNum))], const.DateStringAU);
	
	% Calculate the implied value of the assets on the date that we are
	% pricing the bond. To do this, use the asset dynamics estimated as of
	% end of last year, the share price observations, the interest rate
	% observations, etc:
	% Time to maturity (i.e. time till end of year)
	tau					= (estimYrEndNum - priceDtNum)/daysInEstimYear;
	
	% Get the params for the Vasicek interest rate on that same date as the
	% asset observation
	vParamsAtObsDt		= get(vasParams, priceDtNum);
	
	% Get the share price observation data for that day
	priceDtEqtyObs		= get(firm.Equity, priceDtNum);
	priceDtEquityVal	= priceDtEqtyObs.AdjClose *  prevYrFinObs.OutStShares;
	
	
	% Depending on which pricing model we wish to test, retrieve the
	% appropriate asset parameters before performing the pricing now.
	% Parameters of asset dynamics for the previous year before when we
	% price the 
	% bond, since those params are as good and as close as we can get,
	% given that we don't know the current year's parameters because the
	% year has not finished!
	% Calculate the implied asset value on the date that we are pricing our
	% bond:
	if strcmp(estimMode, const.ModeVasicek)
		
		% We are pricing a risk free bond, don't need to calculate any
		% implied asset valuations etc... 
		priceDtImplAssetVal = NaN;
		
	elseif strcmp(estimMode, const.ModePureProxyM)
		
		priceDtPrevYrAssetParams = get(firm.Assets.PureProxyAssetParams, prevYr);
		priceDtImplAssetVal	= ImpliedAssetValueBlackScholes(...
			prevYrFinObs.TotLiab, ...
			priceDtPrevYrAssetParams.mu, ...
			vParamsAtObsDt.r0, ...
			priceDtPrevYrAssetParams.sigma, ...
			priceDtEquityVal, ...
			tau);
		
	elseif strcmp(estimMode, const.ModeMerton)
		
		priceDtPrevYrAssetParams = get(firm.Assets.MertonAssetParams, prevYr);		
		priceDtImplAssetVal	= ImpliedAssetValueBlackScholes(...
			prevYrFinObs.TotLiab, ...
			priceDtPrevYrAssetParams.mu, ...
			vParamsAtObsDt.r0, ...
			priceDtPrevYrAssetParams.sigma, ...
			priceDtEquityVal, ...
			tau);
	
	elseif strcmp(estimMode, const.ModePureProxyLS)
		
		priceDtPrevYrAssetParams = get(firm.Assets.PureProxyAssetParams, prevYr);
		priceDtImplAssetVal	= ImpliedAssetValueDownAndOutCall(...
			prevYrFinObs.TotLiab, ...
			priceDtPrevYrAssetParams.mu, ...
			vParamsAtObsDt.r0, ...
			priceDtPrevYrAssetParams.sigma, ...
			priceDtEquityVal, ...
			tau);
		
	elseif strcmp(estimMode, const.ModeLS)
		
% 		tmptau = tau
		
		priceDtPrevYrAssetParams = get(firm.Assets.LSAssetParams, prevYr);		
		priceDtImplAssetVal	= ImpliedAssetValueDownAndOutCall(...
			prevYrFinObs.TotLiab, ...
			priceDtPrevYrAssetParams.mu, ...
			vParamsAtObsDt.r0, ...
			priceDtPrevYrAssetParams.sigma, ...
			priceDtEquityVal, ...
			tau);
		
	else
		die(['Died: Invalid pricing mode specified: ' estimMode]);
	end

	
	
	% Now, we MUST test to see if the bond pricing is occuring within the
	% same year that the bond was issued. If this IS the case, then the
	% face value of the bond IS NOT included in the firm's balance sheet
	% yet, so we must manually add the face value of the bond to the debt
	% and asset values. 
	% If the bond is being priced some year AFTER it was issued, then the
	% book value will have absorbed the bond issue, so we do NOT have to
	% add it in manually!
% 	aa = year(firm.Bond.IssueDateNum)
% 	bb = year(priceDtNum)
	if year(firm.Bond.IssueDateNum) < year(priceDtNum)
		
% 		datestr(firm.Bond.IssueDateNum)
		
		defBoundValue	= prevYrFinObs.TotLiab;
		assetValue		= priceDtImplAssetVal;
% 		disp('priced bond according as though an existing issue');
		
	else
		
% 		datestr(priceDtNum)
		
		% When calculating the default boundary K, we assume that the bond
		% defaults when the assets are less than the total liabilities. For a
		% firm that is issuing its first bond, we can take this to be the total
		% liabilities reported at the end of last year, and the face value of
		% the total amount of bond being issued, that is:
		% [Default boundary = totalLiabsBeforeIssue + FaceValueOfIssue]
		defBoundValue	= prevYrFinObs.TotLiab + firm.Bond.FaceValue;
	
		% In a similar vein to the default boundary, the issuance of new debt
		% also increases the market value of the assets. We add the face value
		% of the debt to the market value of assets. This has the effect of
		% increasing the value of both our debt and total asset valuations by the 
		% same amount, but of course, will actually increase the leverage
		% ratio. E.g.:
		% At time t=0, V=1, K=0.5. We issue a bond with FV=0.1 at time t=1.
		% Leverage is then 0.5.
		% At time t=1, V=1+0.1, K=0.5+0.1, but leverage has increased to
		% 0.5455, thus representing increased risk of the firm.
		assetValue	= priceDtImplAssetVal + firm.Bond.FaceValue;
		
% 		disp('priced bond according as though a new issue');	
	end
	
	% For any coupons which were still outstanding after the
	% observation start date at which time we are trying to price the
	% bond, price them according to Merton now:
	remMrktTaus	= CalcRemainingCouponTausInYrs(priceDtNum, firm.Bond.CouponDateNums);
	
	
	% Predict the price of all the coupons
	for coup_i = 1 : 1 : length(remMrktTaus)
		tau		= remMrktTaus(coup_i);

		% Only bother processing coupons if there were coupons to be
		% processed at some payout rate above zero
		if firm.Bond.CouponRate ~= 0
			
			if strcmp(estimMode, const.ModeVasicek)
				
				predictedFullCouponPrice = UnitDiscBondVasicek(tau,vParamsAtObsDt);
				
			elseif strcmp(estimMode, const.ModeMerton) || strcmp(estimMode, const.ModePureProxyM)
				
				predictedFullCouponPrice = UnitDiscBondMerton(...
					tau, ...
					assetValue,...
					defBoundValue,...
					vParamsAtObsDt,...
					priceDtPrevYrAssetParams.sigma,...
					rr_c);
				
			elseif strcmp(estimMode, const.ModeLS) || strcmp(estimMode, const.ModePureProxyLS)
				
				predictedFullCouponPrice = UnitDiscBondLongSchwartz(...
					tau,...
					assetValue,...
					defBoundValue,...
					vParamsAtObsDt,...
					rr_c,...
					priceDtPrevYrAssetParams.rho,...
					priceDtPrevYrAssetParams.sigma);
				
			end

			% Assuming semiannual coupon payments)
			cPrices(length(cPrices)+1) = (0.5 * firm.Bond.CouponRate * predictedFullCouponPrice);
		end
	end

	% Predict the price of the face value payment
	faceTau	= remMrktTaus(end);
	
	if strcmp(estimMode, const.ModeVasicek)
				
		fvPrice = UnitDiscBondVasicek(faceTau,vParamsAtObsDt);
				
	elseif strcmp(estimMode, const.ModeMerton) || strcmp(estimMode, const.ModePureProxyM)
		
		fvPrice = UnitDiscBondMerton(...
			faceTau, ...
			assetValue,...
			defBoundValue,...
			vParamsAtObsDt,...
			priceDtPrevYrAssetParams.sigma,...
			rr_p);
		
	elseif strcmp(estimMode, const.ModeLS) || strcmp(estimMode, const.ModePureProxyLS)
		
		fvPrice = UnitDiscBondLongSchwartz(...
			faceTau,...
			assetValue,...
			defBoundValue,...
			vParamsAtObsDt,...
			rr_p,...
			priceDtPrevYrAssetParams.rho,...
			priceDtPrevYrAssetParams.sigma);
				
	else
		die(['Died: Invalid pricing mode specified: ' estimMode]);
	end
	
	
	% Tally the total predicted price of the bond (as a portfolio-of-zeros)
	PredictedBondPrice = sum(cPrices) + fvPrice;
	
	% Calculate the implied yield that would generate a bond with this
	% price
	% Since for testing purposes, all
	% bonds are priced as though they have a unit payoff, and our close
	% closes are stored similarly, we set the face value of the bond to
	% equal 1 when calculating yields.
	faceVal = 1;
	ImpliedYield = CalcImpliedYield(faceVal,firm.Bond.CouponRate,remMrktTaus,PredictedBondPrice);
	
end










