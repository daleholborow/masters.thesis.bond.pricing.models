function [path] = pathbi(d,cash,pistar)
%  function [path] = pathbi(d,cash,pistar)
%  Generates price path for asset in binomial tree, starting at end
%  and working backwards
%  Parameters:
%	d        discount factor tree
% 	cash     cash flow tree
% 	pistar   risk-neutral prob of "up"
%	path 	 price tree for asset with given cash flows
%  Backus and Zin, March 1999 and after.
[maxmat,n] = size(d);
%  add checks on dimensions??

path = zeros(maxmat,maxmat);
%for s = 1:maxmat
path(:,maxmat) = cash(:,maxmat);    % start with terminal cash flow
%end

for t = maxmat-1:-1:1
    for s = 1:t
        path(s,t) = cash(s,t) + (1-pistar)*d(s,t)*path(s,t+1) ...
		+ pistar*d(s,t)*path(s+1,t+1);
    end
end
