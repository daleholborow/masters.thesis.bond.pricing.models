function [Q] = d2qbi(d,pistar)
%  function [Q] = d2qbi(d,pistar)
%  Generates state prices from discount factor tree (Duffie's formula) 
%  Parameters:
%       d        discount factor tree  
%       pistar   risk-neutral prob of "up"
%       Q        state prices 
%  Backus and Zin, March 1999 and after.
[maxmat,n] = size(d);
if n ~= maxmat
    disp('Warning: d matrix not square in d2qbi')
    return 
end

Q = zeros(maxmat,maxmat);
Q(1,1) = 1.0;
Q(1,2) = (1-pistar)*Q(1,1)*d(1,1);
Q(2,2) = pistar*Q(1,1)*d(1,1);
for t = 3:maxmat		% edges first, then internal nodes 
        Q(1,t) = (1-pistar)*Q(1,t-1)*d(1,t-1);
        Q(t,t) = pistar*Q(t-1,t-1)*d(t-1,t-1);
    for i = 2:t-1
        Q(i,t) = (1-pistar)*Q(i,t-1)*d(i,t-1) ...
		 + pistar*Q(i-1,t-1)*d(i-1,t-1);
    end
end

