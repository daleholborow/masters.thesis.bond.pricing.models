function [firms] = ParseCompanyList()
%--------------------------------------------------------------------------
% @description:	Load up a collection of all the companies whose debt issues
%				we will be examining.
% @history:
%	2008/08/22	Cannot seem to find company records in Datastream to match
%				the bond issues we find. Instead, we will have to manually
%				trawl through CompuStat looking for matching companies.
%				What this means is that we no longer retrieve financial
%				data of any kind about a company from Datastream. Compustat
%				becomes the source of our power...
%--------------------------------------------------------------------------
	disp([' ']);
	disp(['Loading firm-bond pairs:']);
	
	paths	= PathInfo();
	const	= Constants();
	[dataIn, result]= readtext(paths.BondInfoFile, '[,]', '', '"', 'textual');
	[dataInRows dataInCols]	= size(dataIn);

	% For our collection of bonds that we will be performing experiments
	% on, find and store enough information so we can find their relevant
	% details in linked files later on.
	% Which columns the various items of interest are to be found in:
	bondDsCodeCol	= find(strcmpi(dataIn(1,:), 'Type'));
	issuerNameCol	= find(strcmpi(dataIn(1,:), 'CompName'));
	coupCol			= find(strcmpi(dataIn(1,:), 'C'));
	issDtCol		= find(strcmpi(dataIn(1,:), 'ID'));
	matDtCol		= find(strcmpi(dataIn(1,:), 'RD'));
	coupDtCol		= find(strcmpi(dataIn(1,:), 'CD'));
	amountOutCol	= find(strcmpi(dataIn(1,:), 'AOS'));
	moodyRateCol	= find(strcmpi(dataIn(1,:), 'MRT'));
	
% 	faceValCol		= find(strcmpi(dataIn(1,:), 'FV'));
	
	% Store all the firms and their bond details now
	firms = [];
	for rowInd = 2 : 1 : dataInRows
		
		placeAt	= length(firms)+1;
		
		% Load up the basic information about each bond, enough that we can
		% then go and process their various linked files later on one by
		% one.
		firms(placeAt).CompName	= cell2mat(dataIn(rowInd,issuerNameCol));
		firms(placeAt).Bond.DSBondCode		= cell2mat(dataIn(rowInd,bondDsCodeCol));
		firms(placeAt).Bond.IssueDateNum	= datenum(cell2mat(dataIn(rowInd,issDtCol)), const.DateStringAU);
		firms(placeAt).Bond.MatDateNum		= datenum(cell2mat(dataIn(rowInd,matDtCol)), const.DateStringAUCompressed);
		firms(placeAt).Bond.CouponRate		= str2num(cell2mat(dataIn(rowInd,coupCol)))/100;
		
		% Total amount to be repaid at maturity, in effect, book value of
		% the liability that the firm takes on as a result of this debt:
		firms(placeAt).Bond.FaceValue		= str2num(cell2mat(dataIn(rowInd,amountOutCol)))*const.DSAmountOutStMult;
		firms(placeAt).Bond.MoodysRating	= cell2mat(dataIn(rowInd,moodyRateCol));
		
		
		% Calculates all the coupon dates
		firms(placeAt).Bond.CouponDateNums	= CalculateCouponDates(...
			firms(placeAt).Bond.IssueDateNum, ...
			firms(placeAt).Bond.MatDateNum, ...
			cell2mat(dataIn(rowInd,coupDtCol)));
	end
	
	disp(['Successfully loaded collection of companies for param estimation.']);
	disp(['Total # companies found: ' num2str(length(firms))]);


	%%%
	%%% End parsing of company list logic
	%%%
	
	
	%%%
	%%% Begin private methods
	%%%
	
	%----------------------------------------------------------------------
	% @description:	Based on a string containing two embedded coupon date
	%				day/month pairs, parse that string and extract the
	%				values so that we can calculate on which days the
	%				coupons land. Store a collection of all the dates that
	%				the bond will pay coupons.
	%----------------------------------------------------------------------
	function [couponDates] = CalculateCouponDates(issDateNum, matDateNum, couponDateStr)
		issDateVec		= datevec(issDateNum);
		matDateVec		= datevec(matDateNum);
		
		% Store all coupons calculated between the issue and maturity date
		% range.
		couponDates		= [];
		
		len				= length(couponDateStr);
		coup2MStr		= couponDateStr(1,len-1:len);
		coup2DStr		= couponDateStr(1,len-3:len-2);
		coup1MStr		= couponDateStr(1,len-5:len-4);
		% Some date strings are passed in as a 7 digit string instead of 8
		if 8 == len
			spacer = 2;
		else
			spacer = 1;
		end
		coup1DStr		= couponDateStr(1,(1:spacer));
		
		% For each year in the range of the bond life, calculate a first
		% and second coupon date, and if they are within the issue and
		% maturity date, add them to the collection.
		for yrInd = issDateVec(1) : 1 : matDateVec(1)
			yrStr	= num2str(yrInd);
			coupon1Num	= datenum([coup1DStr '/' coup1MStr '/' yrStr], const.DateStringAU);
			coupon2Num	= datenum([coup2DStr '/' coup2MStr '/' yrStr], const.DateStringAU);
			
			% If the calculated coupon dates are valid, (between issue date 
			% and maturity date, and making sure that first coupon is paid no
			% less than 6 months from issue), add them:
			if coupon1Num > issDateNum && coupon1Num <= matDateNum && ...
					(coupon1Num - issDateNum >= 180)
				couponDates(end+1) = coupon1Num;
			end
			if coupon2Num > issDateNum && coupon2Num <= matDateNum && ...
					(coupon2Num - issDateNum >= 180)
				couponDates(end+1) = coupon2Num;
			end
		end
	end
end







