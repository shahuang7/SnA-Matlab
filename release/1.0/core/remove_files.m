function remove_files(param,a)
%
% remove_files(param,a)
%
% removes all files with names of the form
% [param.fileName_prefix '_c' num2str(a) '_row*_col*.dat']
%
% Programmed August 2015
% Comments and code last modified March 2016
% Copyright (c) Russell Fung 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fileName_prefix = param.fileName_prefix;
  delete([fileName_prefix '_c' num2str(a) '_row*_col*.dat'])
% end function remove_files
