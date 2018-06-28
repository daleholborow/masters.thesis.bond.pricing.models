% function [vasicekParams] = LoadPreCalcVasicekParams()
% %--------------------------------------------------------------------------
% % @description:	LoadPreCalcVasicekParams
% %				Retrieves a collection of precalculated Vasicek interest
% %				rate model parameters and stores them indexed by
% %				market observation date.
% %				Result is a hashtable with each stored key-value pair
% %				storing the date of the market observation against a
% %				structure with the parameters inside, that would have most
% %				closely matched that particular day's term structure.
% %--------------------------------------------------------------------------
% 	tic
% 	disp([' ']);
% 	disp(['Loading precalculated historic Vasicek interest rate parameters.']);
% 	
% 	constants		= Constants();
% 	paths			= PathInfo();
% 	
% 	% If values already exist stored as a matlab binary file
% 	if 2 == exist(paths.PreCalVasicekPredictFile)
% 		
% 		load(paths.PreCalVasicekPredictFile, paths.PreCalVasicekPredictVar);
% 		disp('Retrieved Vasicek parameter data from binary file');
% 		
% 	% Else load up the values from precalculated csv source files.
% 	else
% 		
% 		sourceFile		= [paths.VasicekPredictions];
% 		[dataIn, result]= readtext(sourceFile, ...
% 			'[,]', '', '"', 'textual');
% 		[dataInRows dataInCols]	= size(dataIn);
% 
% 		% Create a hashtable to store all the vasicek parameter estimates
% 		vasicekParams = hashtable('size', dataInRows-1);
% 
% 		% For each day's Vasicek interest rate model parameter estimates, load
% 		% the values into a struct and store that struct in a hashtable keyed
% 		% on the datenum of the market observation date.
% 		r0Col		= find(strcmpi(dataIn(1,:), 'r0'));
% 		thetaCol	= find(strcmpi(dataIn(1,:), 'theta'));
% 		kappaCol	= find(strcmpi(dataIn(1,:), 'kappa'));
% 		nuCol		= find(strcmpi(dataIn(1,:), 'nu'));
% 		dateCol		= find(strcmpi(dataIn(1,:), 'Date'));
% 		for index = 2 : 1 : dataInRows
% 			params.ObsDateNum	= datenum(dataIn(index,dateCol), constants.DateStringAU);
% 			params.r0			= str2num(cell2mat(dataIn(index,r0Col)));
% 			params.theta		= str2num(cell2mat(dataIn(index,thetaCol)));
% 			params.kappa		= str2num(cell2mat(dataIn(index,kappaCol)));
% 			params.nu			= str2num(cell2mat(dataIn(index,nuCol)));
% 
% 			vasicekParams = put(vasicekParams, params.ObsDateNum, params);
% 		end
% 		
% 		% Save the values so they can be retrieved again later more quickly
% 		save(paths.PreCalVasicekPredictFile, paths.PreCalVasicekPredictVar);
% 		
% 		disp('Retrieved Vasicek parameter data from csv file.');
% 	end
% 	
% 	disp(['Successfully loaded Vasicek rate data, # observations found: ' num2str(count(vasicekParams))]);
%  	disp(['Total Vasicek processing time: ' num2str(toc)]);
% end
% 
% 
% 
% 
