function compareResults(dSq_direct,dSq_collect,a,b)
  disp(' ')
  if (a+b==1)
    disp(['Unconcatenated'])
    disp('  Distance matrix calculated versus stored')
  else
    disp(['Concatenation Order = ' num2str(a+b) ...
      '  [' num2str(a) '+' num2str(b) ']'])
    disp('  Distance matrix from supervectors versus from shift-and-add')
  end
  disp(['  Max. Error = ' ...
    num2str(max(abs(dSq_direct(:)-dSq_collect(:))))])
  dSq_direct(1:5,1:5)
  dSq_collect(1:5,1:5)
% end function compareResults
