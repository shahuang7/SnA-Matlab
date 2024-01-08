% run_PYP_light_concat_38250_dp_no_normalize
% 
% copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  addpath('/home/sna/release/2.0/connecting',...
          '/home/sna/release/2.0/core',...
          '/home/sna/release/2.0/validation',...
          '/home/sna/release/2.0/variations')
  D = 21556;
  N = 152677;
  n = 7152;
  concatOrder = 38250;
  numTasks = 16;
%%%%%
% data parameters
%
  param.rawDataFile = ['/state/partition1/PYP_152677_21556.mat'];
  %
  % data must first be uploaded onto the worker nodes
  %
  param.rawDataVar = 'T';
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
  parallel_SnA_dp

  directory = ['dp_N' num2str(N) '_n' num2str(n) '_c' num2str(concatOrder) '/'];
  fileName_wildcard = ['dp_N' num2str(N) '_n' num2str(n) '_c' num2str(concatOrder) '_row*_col*.dat'];
  system(['mkdir ' directory]);
  system(['mv ' fileName_wildcard ' ' directory]);

% end run_PYP_light_concat_38250_dp_no_normalize
