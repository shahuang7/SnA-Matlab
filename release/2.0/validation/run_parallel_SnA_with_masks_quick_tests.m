function run_parallel_SnA_with_masks_quick_tests()
% run_parallel_SnA_with_masks_quick_tests
% 
% copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  addpath('/home/sna/release/2.0/core',...
          '/home/sna/release/2.0/export_fig',...
          '/home/sna/release/2.0/validation',...
          '/home/sna/release/2.0/variations')
  diary(['parallel_SnA_with_masks_quick_tests_' date '.dat'])
  err_max = nan(10,1);
  err_rms = nan(10,1);
  [err_max( 1),err_rms( 1)] = run_test('D0',20, 1000, 100,   1, 10);
  [err_max( 2),err_rms( 2)] = run_test('D1',20, 1000, 100,   2, 10);
  [err_max( 3),err_rms( 3)] = run_test('D2',20, 1000, 100,   4, 10);
  [err_max( 4),err_rms( 4)] = run_test('D3',20, 1000, 100,   8, 10);
  [err_max( 5),err_rms( 5)] = run_test('D4',20, 1000, 100,  16, 10);
  [err_max( 6),err_rms( 6)] = run_test('D5',20, 1000, 100,  32, 10);
  [err_max( 7),err_rms( 7)] = run_test('D6',20, 1000, 100,  64, 10);
  [err_max( 8),err_rms( 8)] = run_test('D7',20, 1000, 100, 128,  9);
  [err_max( 9),err_rms( 9)] = run_test('D8',20, 1000, 100, 256,  8);
  [err_max(10),err_rms(10)] = run_test('D9',20, 1000, 100, 512,  5);
  diary off
  
  x = 2.^[0:9];
  y = err_rms*100;
  [m,log_a] = regressionLine(log(x(2:10)),log(y(2:10)));
  a = exp(log_a);
  fitted = a*(x.^m);
  h = figure(1);
  set(h,'color','w')
  hsp = subplot(1,1,1);
  plotRF(hsp,x,y,'c','\epsilon_{rms} (%)','','b-x')
  addplotRF(hsp,x,fitted,'r-o')
  set(hsp,'xlim',[-10 520])
  legend({'Calculated',['y=' num2str(round(a*1000)/1000) 'x^{' num2str(round(m*1000)/1000) '}']})
  export_fig('-jpeg','-r200','rms_error.jpg')
  
  x = 2.^[0:9];
  y = err_max*100;
  [m,log_a] = regressionLine(log(x(2:10)),log(y(2:10)));
  a = exp(log_a);
  fitted = a*(x.^m);
  h = figure(2);
  set(h,'color','w')
  hsp = subplot(1,1,1);
  plotRF(hsp,x,y,'c','\epsilon_{max} (%)','','b-x')
  addplotRF(hsp,x,fitted,'r-o')
  set(hsp,'xlim',[-10 520])
  legend({'Calculated',['y=' num2str(round(a*1000)/1000) 'x^{' num2str(round(m*1000)/1000) '}']})
  export_fig('-jpeg','-r200','max_error.jpg')
  
% end function run_parallel_SnA_with_masks_quick_tests

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
  parallel_SnA_with_masks
  
  fileName_prefix = [param.local_destination 'dSq_N' num2str(N) '_n' num2str(n)];
  dSq_collect = collect_dSq([fileName_prefix '_c%d_row%d_col%d.dat'],param.io_format,N,n,concatOrder);
  num_nan = sum(isnan(dSq_collect(:)));
  if (num_nan>0)
    disp(' ')
    disp(['# undefined distance = ', num2str(num_nan)])
    disp(' ')
    return
  end
  load(['test_data_with_masks.mat'],'T')
  T = T(1:N,1:D)';
  load(['test_data_with_masks.mat'],'M')
  M = M(1:N,1:D)';
  tStart_direct = tic;
  Tc = concat(T,concatOrder);
  Mc = concat(M,concatOrder);
  dSq_direct = dmat_with_masks(Tc,Tc,Mc,Mc);
  tEnd_direct = toc(tStart_direct)
  compareResults(dSq_direct,dSq_collect,concatOrder,0)
  err = dSq_direct-dSq_collect;
  err = 2*err./(dSq_direct+dSq_collect); % relative error
  diag_element = speye(N-concatOrder);
  err(find(diag_element)) = [];
  err = err(:);
  err_max = max(abs(err));
  err_rms = sqrt(mean(err.*err));
% end function run_test
