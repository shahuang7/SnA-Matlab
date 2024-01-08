% run_BOSS_dr10_science_qso_0_no_concat
% 
% copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  addpath('/home/sna/release/2.0/connecting',...
          '/home/sna/release/2.0/core',...
          '/home/sna/release/2.0/validation',...
          '/home/sna/release/2.0/variations')
  D = 4527;
  N = 10000;
  n = 625;
  concatOrder = 1;
  numTasks = 16;
%%%%%
% data parameters
%
  param.rawDataFile = ['/state/partition1/dr10_science_qso_0.mat'];
  param.maskFile = ['/state/partition1/dr10_science_qso_0.mat'];
  %
  % data must first be uploaded onto the worker nodes
  %
  param.rawDataVar = 'T';
  param.maskVar = 'M';
  param.io_format = 'double';
  param.D = D;
  param.N = N;
  param.n = n;
  param.c = concatOrder;
%%%%%
% local machine parameters
%   local machine is where you are sending the jobs from
%
  param.local_hostname = 'femto.phys.uwm.edu';
  param.local_destination = 'test_results/';
%%%%%
% remote cluster parameters
%   remote cluster is where you are sending the jobs to
%
  param.remote_hostname = 'boltzmann.phys.uwm.edu';
  userID = get_username();
  param.username = userID;
  param.share_directory = ['/share/apps/data/' userID '/TempFiles/'];
  param.worker_directory_prefix = ['/state/partition1/worker_' userID '_']; % on worker nodes
%%%%%
  parallel_SnA_with_masks

  nN = 500;
  nB = 3333;      %
  numFile = 3;    % (N-concatOrder) = nB x numFile
  io_format = param.io_format;
  directory = param.local_destination;
  fileName_template = ['dSq_N' num2str(N) '_n' num2str(n) '_c%d_row%d_col%d.dat'];

  %%%%%%%%%%
  make_dataY_files
  scriptDistanceSymmetrization
  %%%%%%%%%%

  system(['rm -rf ' directory]);
  system('rm -f dataY*iB*');
% end run_BOSS_dr10_science_qso_0_no_concat
