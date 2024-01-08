function run_parallel_SnA_norm_after_concat_remote_divide_quick_tests()
% run_parallel_SnA_norm_after_concat_remote_divide_quick_tests
% 
% copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  addpath('/home/sna/release/2.0/core',...
          '/home/sna/release/2.0/validation',...
          '/home/sna/release/2.0/variations')
  diary(['parallel_SnA_norm_after_concat_remote_divide_quick_tests_' date '.dat'])
  run_test('A2',1000, 1000, 100, 200, 8);
  run_test('B2',1000, 1000, 200, 200, 4);
  run_test('C2',1000, 1000, 500, 200, 2);
  run_test('E2',  10,10000,1000, 200,10);
  run_test('F2',  10,10000,1000,2000, 8);
  run_test('G2',  10,10000,1000,5000, 5);
  run_test('H2',   1,20000,2000,5000, 8);
  run_test('I2',   1,20000,5000,5000, 3);
  run_test('J2',  10,10000,2000,5800, 3);
  run_test('K2',   1,20000,2000,5800, 8);
  run_test('L2',1000, 2000,1000, 580, 2);
  diary off
% end function run_parallel_SnA_norm_after_concat_remote_divide_quick_tests

function [err_max,err_rms]=run_test(testName,D,N,n,concatOrder,numTasks)
  for jj=1:10, disp(' '), end
  disp(['>>>>>>>>>> ' testName ' <<<<<<<<<<'])
  for jj=1:10, disp(' '), end
%%%%%
% data parameters
%
  param.rawDataFile = ['/state/partition1/test_data_with_masks.mat'];
  param.maskFile = ['/state/partition1/test_data_with_masks.mat'];
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
  param.config = 'jobmanagerconfig1';
  userID = get_username();
  param.username = userID;
  param.share_directory = ['/share/apps/data/' userID '/TempFiles/'];
  param.worker_directory_prefix = ['/state/partition1/worker_' userID '_']; % on worker nodes
%%%%%
  parallel_SnA_with_masks_no_norm
%%%%%
% data parameters
%
  param.rawDataVar = 'M';
%%%%%
  parallel_SnA_dp
%%%%%
% elementwise division done on the cluster
%
  fileName_prefix = [param.share_directory 'dSq_N' num2str(N) '_n' num2str(n)];
  param.fileName_template_num = [fileName_prefix '_c%d_row%d_col%d.dat'];
  fileName_prefix = [param.share_directory 'dp_N' num2str(N) '_n' num2str(n)];
  param.fileName_template_denom = [fileName_prefix '_c%d_row%d_col%d.dat'];
  param.fileName_template_corrected = param.fileName_template_num;
  param.fileName_wildcard = ['dSq_N' num2str(param.N) '_n' num2str(param.n) '_c' num2str(param.c) '*.dat'];
  parallel_elementwise_normalize
  
  fileName_prefix = [param.local_destination 'dSq_N' num2str(N) '_n' num2str(n)];
  dSq_collect = collect_dSq([fileName_prefix '_c%d_row%d_col%d.dat'],param.io_format,N,n,concatOrder);
%%%%%
% rescale to a common number of pixels
%
  dSq_collect = dSq_collect*concatOrder*D;
%%%%%
% doing the same calculation by brute force
%
  load(['test_data_with_masks.mat'],'T')
  T = T(1:N,1:D)';
  load(['test_data_with_masks.mat'],'M')
  M = M(1:N,1:D)';
  tStart_direct = tic;
  Tc = concat(T,concatOrder);
  Mc = concat(M,concatOrder);
  dSq_direct = dmat_with_masks(Tc,Tc,Mc,Mc);
  tEnd_direct = toc(tStart_direct)
%%%%%
  compareResults(dSq_direct,dSq_collect,concatOrder,0)
  err = dSq_direct-dSq_collect;
  err = 2*err./(dSq_direct+dSq_collect); % relative error
  diag_element = speye(N-concatOrder);
  err(find(diag_element)) = [];
  err = err(:);
  err_max = max(abs(err));
  err_rms = sqrt(mean(err.*err));
% end function run_test
