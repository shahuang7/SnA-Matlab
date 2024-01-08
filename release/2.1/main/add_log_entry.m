function add_log_entry(param,workerID,log_entry)
%
% add_log_entry(param,workerID,log_entry)
%
% writes log_entry into the log file for worker# workerID.
%
% copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  logFile = [param.share_directory 'logfile_' num2str(workerID) '.dat'];
  fid = fopen(logFile,'a');
  fprintf(fid,'%s\n',log_entry);
  fclose(fid);
% end function add_log_entry
