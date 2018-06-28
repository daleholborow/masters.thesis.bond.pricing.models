function [cash] = plusop(cash)
%  function [cash] = plusop(cash)
%  Applies the plus operator to a matrix:  negative values set to zero
%  Backus and Zin, March 1999 and after.

cash = cash.*(cash >= 0);

end
