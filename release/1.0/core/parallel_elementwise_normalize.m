% parallel_elementwise_normalize
% 
% copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%
% user section #1 BEGIN %
%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % parameters provided by calling subroutine
  %
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
  set(job{nn},'FileDependencies',{'elementwise_normalize.m',...
                                  'get_row_col_range.m',...
                                  'read_dSq.m',...
                                  'write_dSq.m'});
  createTask(job{nn},@elementwise_normalize,1,{param,numTasks,nn-1});
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

command = ['scp -pq ' param.username '@' param.remote_hostname ':' param.share_directory param.fileName_wildcard ' ' param.local_destination];
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
