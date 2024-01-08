% myParallel_reconstruct
% 
% copyright (c) Russell Fung 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%
% user section #1 BEGIN %
%%%%%%%%%%%%%%%%%%%%%%%%%
D = 2000;
concatOrder = 580;
c0 = 56001;
kOfInterest = [1:6];
tOfInterest = c0+concatOrder-1+[1:12000];
copyOfInterest = [1:49];
numTasks = 10;
shareDir = '/share/apps/data/russell/T_ordered_100k.1.watson/sBeltrami.1/dataY/';
localDir = '/state/partition1/tmp/';
logfile_template = [shareDir 'reconstruct_%d_of_' num2str(numTasks) '.log'];
dataSVD = [localDir 'SVD_chronosVer0_overlap.mat'];
reconstructedData_template = [shareDir 'reconstructedData_%d_of_' ...
  num2str(numTasks) '.mat'];

param.D = D;
param.concatOrder = concatOrder;
param.c0 = c0;
param.kOfInterest = kOfInterest;
param.copyOfInterest = copyOfInterest;
param.dataSVD = dataSVD;
%%%%%%%%%%%%%%%%%%%%%%%
% user section #1 END %
%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%
% setup
msg = sprintf('\n\nset up the cluster, create the jobs ...\n\n');
disp(msg)
tic

try
  matlabpool close
catch
end
currentDirectory = pwd;
hostName = 'photon.phys.uwm.edu';
config = pctconfig('hostname',hostName);
jm = findResource('scheduler','configuration','jobmanagerconfig1');
job = cell(numTasks,1);

for nn=1:numTasks
  job{nn} = createJob(jm);
  set(job{nn},'PathDependencies',{currentDirectory});
%%%%%%%%%%%%%%%%%%%%%%%%%
% user section #2 BEGIN %
%%%%%%%%%%%%%%%%%%%%%%%%%
  num_t = numel(tOfInterest);
  num_t_per_task = ceil(num_t/numTasks);
  i0 = (nn-1)*num_t_per_task+1;
  i1 = min(i0+num_t_per_task-1,num_t);
  param.tOfInterest = tOfInterest(i0:i1);
  set(job{nn},'FileDependencies',{'reconstruct.m'});
  param.logfile = sprintf(logfile_template,nn);
  param.reconstructedData = sprintf(reconstructedData_template,nn);
  createTask(job{nn},@reconstruct,1,{param});
%%%%%%%%%%%%%%%%%%%%%%%
% user section #2 END %
%%%%%%%%%%%%%%%%%%%%%%%
  submit(job{nn});
  disp([datestr(now) sprintf('  task#%d submitted',nn)])
end

toc
%%%%%%%%%%
% submit the job and wait
msg = sprintf('\n\nsubmit the jobs, work on the jobs ...\n\n');
disp(msg)
tic

results = cell(numTasks,1);
InProgress = [1:numTasks];
while ~isempty(InProgress)
  for id = InProgress
    if strcmp(job{id}.State,'finished')
      disp([datestr(now) sprintf('  task#%d completed',id)])
      results{id} = getAllOutputArguments(job{id});
      disp([datestr(now) sprintf('  task#%d results downloaded',id)])
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

toc
%%%%%%%%%%
% clean up
msg = sprintf('\n\ncleaning up ...\n\n');
disp(msg)
tic

for nn=1:numTasks
  destroy(job{nn});
end
try
  matlabpool close
catch
end

toc
%%%%%%%%%%
