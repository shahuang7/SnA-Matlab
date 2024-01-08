function run_parallel_SnA_quick_tests()
% run_parallel_SnA_quick_tests
% 
% copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  addpath('/home/sna/release/2.0/core','/home/sna/release/2.0/validation')
  diary(['parallel_SnA_quick_tests_' date '.dat'])
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
% end function run_parallel_SnA_quick_tests

function [err_max,err_rms]=run_test(testName,D,N,n,concatOrder,numTasks)
  for jj=1:10, disp(' '), end
  disp(['>>>>>>>>>> ' testName ' <<<<<<<<<<'])
  for jj=1:10, disp(' '), end
%%%%%
% data parameters
%
  param.rawDataFile = ['/state/partition1/test_data.mat'];
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
  param.config = 'jobmanagerconfig1';
  userID = get_username();
  param.username = userID;
  param.share_directory = ['/share/apps/data/' userID '/TempFiles/'];
  param.worker_directory_prefix = ['/state/partition1/worker_' userID '_']; % on worker nodes
%%%%%
  parallel_SnA
  
  fileName_prefix = [param.local_destination 'dSq_N' num2str(N) '_n' num2str(n)];
  dSq_collect = collect_dSq([fileName_prefix '_c%d_row%d_col%d.dat'],param.io_format,N,n,concatOrder);
  
  load(['test_data.mat'],'T')
  T = T(1:N,1:D)';
  tStart_direct = tic;
  dSq_direct = dmat(concat(T,concatOrder));
  tEnd_direct = toc(tStart_direct)
  compareResults(dSq_direct,dSq_collect,concatOrder,0)
  err = dSq_direct-dSq_collect;
  diag_element = speye(N-concatOrder);
  err(find(diag_element)) = [];
  err = err(:);
  err_max = max(abs(err));
  err_rms = sqrt(mean(err.*err));
% end function run_test
