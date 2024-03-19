addpath(pwd, ...
    '~/Data/huang229/SnA-Matlab/release/2.0/connecting/', ...
    '~/Data/huang229/SnA-Matlab/release/2.0/core/', ...
    '~/Data/huang229/SnA-Matlab/release/2.0/validation/', ...
    '~/Data/huang229/SnA-Matlab/release/2.0/variations/')
% New libraries on mortimer

D = 21556;
N = 152677;
numTasks = 16;
concatOrder = 32768;
n = ceil((N-concatOrder)/numTasks);

param.rawDataFile = '~/Data/huang229/PYP_fs_nS152677/dataPYP_femto_int_sortdelay_unifdelay_DRL_SCL_BST_nS152677_nBrg21556.mat';
param.maskFile = '~/Data/huang229/PYP_fs_nS152677/dataPYP_femto_int_sortdelay_unifdelay_DRL_SCL_BST_nS152677_nBrg21556.mat';
param.rawDataVar = 'T_drl_scl_bst';
param.maskVar = 'M_drl_scl';
param.io_format = 'double';
param.D = D;
param.N = N;
param.n = n;
param.c = concatOrder;

%param.local_hostname = 'vis-1.mortimer.hpc.uwm.edu';
%param.local_destination = 'test_results/';
%param.remote_hostname = 'execute-4003.mortimer.hpc.uwm.edu';
userID = get_username();
param.username = userID;
param.share_directory = '~/Data/huang229/PYP_fs_nS152677/matlab_dSq/cn/dSq_chunks/';
param.worker_directory_prefix = ['~/Data/huang229/matlab-job-storage/pyp-fs-cn/worker_' userID '_'];

msg = sprintf('\n\nsetup the cluster, create the jobs ...\n\n');
tic

% Begin parallel_SnA_with_masks_no_norm

%if ~exist(param.local_destination,'dir')
%    mkdir(param.local_destination);
%end

try
    matlabpool close
catch
end

currentDirectory = pwd;
jm = parcluster;
job = createJob(jm);
job.AttachedFiles = {'/home/uwm/huang229/Data/huang229/SnA-Matlab/release/2.0/core'};

disp('Ready to Create Jobs')

for nn = 1:numTasks
  fileName_directory = [param.worker_directory_prefix num2str(nn-1)];
  fileName_prefix = [fileName_directory '/dSq_N' num2str(param.N) '_n' num2str(param.n)];
  fileName_template = [fileName_prefix '_c%d_row%d_col%d.dat'];
  param.fileName_directory = fileName_directory;
  param.fileName_prefix = fileName_prefix;
  param.fileName_template = fileName_template;
  createTask(job,@SnA_with_masks_no_norm,1,{param,numTasks,nn-1});
end

disp('Submit')
submit(job);
parallel_job_ticket = ['.parallel_job_' date '_' num2str(randi(9999,1))];
system(['touch ' parallel_job_ticket]);

msg = sprintf('\n\nsubmit the jobs, work on the jobs ...\n\n');
disp(msg)

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
       disp('finished')
       disp(' ')
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

fileName_wildcard = ['dSq_N' num2str(param.N) '_n' num2str(param.n) '_c' num2str(param.c) '*.dat'];
%command = ['scp -pq ' param.username '@' param.remote_hostname ':' param.share_directory fileName_wildcard ' ' param.local_destination];
%system(command);

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
disp(msg)

destroy(job)
try
  matlabpool close
catch
end
toc

param.rawDataVar = 'M_drl_scl';

% Begin parallel SnA_dp to calculate mask
%  if ~exist(param.local_destination,'dir')
%    mkdir(param.local_destination);
%  end

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
job.AttachedFiles = {'/home/uwm/huang229/Data/huang229/SnA-Matlab/release/2.0/core'};

for nn=1:numTasks
%%%%%%%%%%%%%%%%%%%%%%%%%
% user section #2 BEGIN %
%%%%%%%%%%%%%%%%%%%%%%%%%
  fileName_directory = [param.worker_directory_prefix num2str(nn-1)];
  fileName_prefix = [fileName_directory '/dp_N' num2str(param.N) '_n' num2str(param.n)];
  fileName_template = [fileName_prefix '_c%d_row%d_col%d.dat'];
  param.fileName_directory = fileName_directory;
  param.fileName_prefix = fileName_prefix;
  param.fileName_template = fileName_template;
  createTask(job,@SnA_dp,1,{param,numTasks,nn-1});
%%%%%%%%%%%%%%%%%%%%%%%
% user section #2 END %
%%%%%%%%%%%%%%%%%%%%%%%
%  disp([datestr(now) sprintf('  task#%d submitted',nn)])
end
submit(job);
%%%%%%%%%%
parallel_job_ticket = ['.parallel_job_' date '_' num2str(randi(9999,1))];
system(['touch ' parallel_job_ticket]);
msg = sprintf('\n\nsubmit the jobs, work on the jobs ...\n\n');
%%%%%%%%%%

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

fileName_wildcard = ['dp_N' num2str(param.N) '_n' num2str(param.n) '_c' num2str(param.c) '*.dat'];
if ~exist(parallel_job_ticket,'file')
  toc
  return
end
system(['rm -f ' parallel_job_ticket]);
msg = sprintf('\n\ncleaning up ...\n\n');
destroy(job)
try
  matlabpool close
catch
end

toc
% End parallel_SnA_dp

% elementwise division done on the cluster
  fileName_prefix = [param.share_directory 'dSq_N' num2str(N) '_n' num2str(n)];
  param.fileName_template_num = [fileName_prefix '_c%d_row%d_col%d.dat'];
  fileName_prefix = [param.share_directory 'dp_N' num2str(N) '_n' num2str(n)];
  param.fileName_template_denom = [fileName_prefix '_c%d_row%d_col%d.dat'];
  param.fileName_template_corrected = param.fileName_template_num;
  param.fileName_wildcard = ['dSq_N' num2str(param.N) '_n' num2str(param.n) '_c' num2str(param.c) '*.dat'];
  
msg = sprintf('\n\nset up the cluster, create the jobs for normalization ...\n\n')
tic

try
  matlabpool close
catch
end
currentDirectory = pwd;
jm = parcluster;
job = createJob(jm);
job.AttachedFiles = {'/home/uwm/huang229/Data/huang229/SnA-Matlab/release/2.0/core'};

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


%%%%%%%%%%
% submit the job and wait
msg = sprintf('\n\nsubmit the jobs, work on the jobs ...\n\n');

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

if ~exist(parallel_job_ticket,'file')
  toc
  return
end
system(['rm -f ' parallel_job_ticket]);
%%%%%%%%%%
%%%%%%%%%%
% clean up
msg = sprintf('\n\ncleaning up ...\n\n');

destroy(job)
try
  matlabpool close
catch
end

toc

nN = 15000;
nB = N - concatOrder;
numFile = 1;
io_format = param.io_format;
directory = param.share_directory;
fileName_template = ['dSq_N' num2str(N) '_n' num2str(n) '_c%d_row%d_col%d.dat'];

make_dataY_files
scriptDisanceSymmetrization

%system(['rm -rf ' directory]);
system('rm -f dataY*iB*');

