% function this = merge(this, srcHashtable)
% 
% 
% % Takes in a second hashtable, and one by one, adds its elements to the
% % current hashtable, overwriting them if they exist. 
% % 
% 
% 	[keys vals]	= dump(srcHashtable);
% 	for index = 1 : 1 : length(keys)
% 		this = put(this, keys(index), vals(index))
% 	end