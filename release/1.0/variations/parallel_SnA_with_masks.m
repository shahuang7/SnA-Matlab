% parallel_SnA_with_masks
% 
% copyright (c) Russell Fung 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
% user section #1 BEGIN %
%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % parameters provided by calling subroutine
  %
  if ~exist(param.local_destination,'dir')
    mkdir(param.local_destination);
  end
%%%%%%%%%%%%%%%%%%%%%%%
% user section #1 END %
%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%
% setup
msg = sprintf('\n\nset up the cluster, create the jobs ...\n\n');
%disp(msg)
tic

try
  matlabpool close
catch
end
currentDirectory = pwd;
config = pctconfig('hostname',param.local_hostname);
jm = findResource('scheduler','configuration',param.config);
job = cell(numTasks,1);

for nn=1:numTasks
  job{nn} = createJob(jm);
  set(job{nn},'PathDependencies',{currentDirectory});
%%%%%%%%%%%%%%%%%%%%%%%%%
% user section #2 BEGIN %
%%%%%%%%%%%%%%%%%%%%%%%%%
  set(job{nn},'FileDependencies',{'add_log_entry.m',...
                                  'calc_sqDist_blocks_with_masks.m',...
                                  'dmat_with_masks.m',...
                                  'get_row_col_range.m',...
                                  'read_dSq.m',...
                                  'remove_files.m',...
                                  'shift_and_add_squared_distances.m',...
                                  'SnA_with_masks.m',...
                                  'take_turns_to_execute.m',...
                                  'write_dSq.m'});
  fileName_directory = [param.worker_directory_prefix num2str(nn-1)];
  fileName_prefix = [fileName_directory '/dSq_N' num2str(param.N) '_n' num2str(param.n)];
  fileName_template = [fileName_prefix '_c%d_row%d_col%d.dat'];
  param.fileName_directory = fileName_directory;
  param.fileName_prefix = fileName_prefix;
  param.fileName_template = fileName_template;
  createTask(job{nn},@SnA_with_masks,1,{param,numTasks,nn-1});
%%%%%%%%%%%%%%%%%%%%%%%
% user section #2 END %
%%%%%%%%%%%%%%%%%%%%%%%
  submit(job{nn});
%  disp([datestr(now) sprintf('  task#%d submitted',nn)])
end

%toc
%%%%%%%%%%
% submit the job and wait
msg = sprintf('\n\nsubmit the jobs, work on the jobs ...\n\n');
%disp(msg)
%tic

results = cell(numTasks,1);
InProgress = [1:numTasks];
while ~isempty(InProgress)
  for id = InProgress
    if strcmp(job{id}.State,'finished')
%      disp([datestr(now) sprintf('  task#%d completed',id)])
      results{id} = getAllOutputArguments(job{id});
%      disp([datestr(now) sprintf('  task#%d results downloaded',id)])
%%%%%%%%%%%%%%%%%%%%%%%%%
% user section #3 BEGIN %
%%%%%%%%%%%%%%%%%%%%%%%%%

      if (~isempty(results{id}))
        status = results{id}{1};
        disp([datestr(now) sprintf('  task#%d returns %d',id,status)])
      else
        disp([datestr(now) sprintf('  task#%d failed',id)])
      end

%%%%%%%%%%%%%%%%%%%%%%%
% user section #3 END %
%%%%%%%%%%%%%%%%%%%%%%%
      InProgress = setxor(InProgress,id);
    end
  end
end

%toc

fileName_wildcard = ['dSq_N' num2str(param.N) '_n' num2str(param.n) '_c' num2str(param.c) '*.dat'];
command = ['scp -pq ' param.username '@' param.remote_hostname ':' param.share_directory fileName_wildcard ' ' param.local_destination];
system(command);

%%%%%%%%%%
% clean up
msg = sprintf('\n\ncleaning up ...\n\n');
%disp(msg)
%tic

for nn=1:numTasks
  destroy(job{nn});
end
try
  matlabpool close
catch
end

toc
%%%%%%%%%%
