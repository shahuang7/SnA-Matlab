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
jm = parcluster;
job = createJob(jm);
job.AttachedFiles = {'/home/sna/release/2.0/core'};

for nn=1:numTasks
%%%%%%%%%%%%%%%%%%%%%%%%%
% user section #2 BEGIN %
%%%%%%%%%%%%%%%%%%%%%%%%%
  createTask(job,@elementwise_normalize,1,{param,numTasks,nn-1});
%%%%%%%%%%%%%%%%%%%%%%%
% user section #2 END %
%%%%%%%%%%%%%%%%%%%%%%%
%  disp([datestr(now) sprintf('  task#%d submitted',nn)])
end
submit(job);
%%%%%%%%%%
parallel_job_ticket = ['.parallel_job_' date '_' num2str(randi(9999,1))];
system(['touch ' parallel_job_ticket]);
%%%%%%%%%%

%toc
%%%%%%%%%%
% submit the job and wait
msg = sprintf('\n\nsubmit the jobs, work on the jobs ...\n\n');
%disp(msg)
%tic

results = cell(numTasks,1);
InProgress = [1:numTasks];
t_query_max = 5;
skip_progress_loop = false;
t_start_progress_loop = tic;
while ~isempty(InProgress)
%%%%%%%%%%
  InProgress = check_job_ticket_progress(job,parallel_job_ticket,InProgress);
%%%%%%%%%%
  if (skip_progress_loop), continue, end
  for id = InProgress
    t_start_query = tic;
    if strcmp(job.Tasks(id).State,'finished')
%      disp([datestr(now) sprintf('  task#%d completed',id)])
%      disp([datestr(now) sprintf('  task#%d results downloaded',id)])
%%%%%%%%%%%%%%%%%%%%%%%%%
% user section #3 BEGIN %
%%%%%%%%%%%%%%%%%%%%%%%%%
      Error = job.Tasks(id).Error;
      if (isempty(Error))
        disp([datestr(now) sprintf('  task#%d returns 1',id)])
      else
        disp([datestr(now) sprintf('  task#%d failed:\n    %s',id,Error.message)])
      end
%%%%%%%%%%%%%%%%%%%%%%%
% user section #3 END %
%%%%%%%%%%%%%%%%%%%%%%%
      InProgress = setxor(InProgress,id);
    end
    t_query = toc(t_start_query);
    if (t_query>t_query_max)
      disp(' ')
      disp(' ')
      disp(' ')
      disp('>>>>> job-status checking is very slow, will stop checking <<<<<')
      disp(' ')
      disp(' ')
      disp(' ')
      disp('>>>>>   delete job ticket to break out of progress loop    <<<<<')
      disp(' ')
      disp(' ')
      disp(' ')
      skip_progress_loop = true;
      break
    end
  end
end
t_progress_loop = toc(t_start_progress_loop)

%toc

command = ['scp -pq ' param.username '@' param.remote_hostname ':' param.share_directory param.fileName_wildcard ' ' param.local_destination];
system(command);

%%%%%%%%%%
if ~exist(parallel_job_ticket,'file')
  toc
  return
end
system(['rm -f ' parallel_job_ticket]);
%%%%%%%%%%
%%%%%%%%%%
% clean up
msg = sprintf('\n\ncleaning up ...\n\n');
%disp(msg)
%tic

destroy(job)
try
  matlabpool close
catch
end

toc
%%%%%%%%%%
