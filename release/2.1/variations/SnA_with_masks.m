function status=SnA_with_masks(param,numWorker,workerID)
%
% status=SnA_with_masks(param,numWorker,workerID)
%
% performs shift-and-add_with_masks
%
% copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [status,result] = unix('hostname');
  add_log_entry(param,workerID,result);
  add_log_entry(param,workerID,   sprintf('worker# %d\n',workerID)   );
  
  concatOrder = param.c;
%%%%%%%%%%
% calculate squared distances amongst unconcatenated vectors
%%%%%%%%%%
  param.a = 1;
  param.b = 0;
  command = ['mkdir ' param.fileName_directory];
  system(command);
  
  tic
  
  calc_sqDist_blocks_with_masks(param,numWorker,workerID);
  
  add_log_entry(param,workerID,   sprintf('%10d %10d %20.4f',param.a,param.b,toc)   ); tic
  
%%%%%%%%%%
% shift-and-add_with_masks
%%%%%%%%%%
  % concatOrder in binary gives the powers of 2 to be accumulated
  % fliplr so that iteration index corresponds to element index of keeper
  keeper = fliplr(dec2bin(concatOrder));
  % if concatOrder is a power of 2, no accumulation along the way
  % will just take the result from the last doubling
  numDoubling = length(keeper)-1;
  pureDoubling = (concatOrder==2^numDoubling);
  % storedOrder is where we are up to now
  % prevOrder is the power of 2 in the last iteration
  storedOrder = 0;
  for iter=1:numDoubling
    prevOrder = 2^(iter-1);
    if str2num(keeper(iter))
    % want the power of 2 in the last iteration (i.e. prevOrder)
      if (storedOrder>0)
      % add it to what we have accumulated so far
        param.a = storedOrder;
        param.b = prevOrder;
        shift_and_add_squared_distances(param,numWorker,workerID)
        
        add_log_entry(param,workerID,   sprintf('%10d %10d %20.4f',param.a,param.b,toc)   ); tic
        
      % files for the old storedOrder are not needed anymore
        remove_files(param,storedOrder)
        
        add_log_entry(param,workerID,   sprintf('%10d %10d %20.4f',-storedOrder,0,toc)   ); tic
        
      end
      % if we have not accumulated anything so far, then new storedOrder is
      % just the power of 2 in the last iteration (i.e. prevOrder)
      % either way the new storedOrder is given by ...
      storedOrder = storedOrder+prevOrder;
    end
    % double the power of 2 in the last iteration (i.e. prevOrder)
    param.a = prevOrder;
    param.b = prevOrder;
    shift_and_add_squared_distances(param,numWorker,workerID)
    
    add_log_entry(param,workerID,   sprintf('%10d %10d %20.4f',param.a,param.b,toc)   ); tic
    
    if (storedOrder==prevOrder)
    % if prevOrder is the same as storedOrder, then don't delete it
      continue
    end
    % otherwise, we are done with prevOrder
    remove_files(param,prevOrder)
    
    add_log_entry(param,workerID,   sprintf('%10d %10d %20.4f',-prevOrder,0,toc)   ); tic
    
  end
  
  prevOrder = 2^numDoubling;
  if (storedOrder>0)
    param.a = storedOrder;
    param.b = prevOrder;
    shift_and_add_squared_distances(param,numWorker,workerID)
    
    add_log_entry(param,workerID,   sprintf('%10d %10d %20.4f',param.a,param.b,toc)   ); tic
    
    remove_files(param,prevOrder)
    
    add_log_entry(param,workerID,   sprintf('%10d %10d %20.4f',-prevOrder,0,toc)   ); tic
    
    remove_files(param,storedOrder)
    
    add_log_entry(param,workerID,   sprintf('%10d %10d %20.4f',-storedOrder,0,toc)   ); tic
    
  end
  
  fileName_wildcard_with_full_path = strrep(param.fileName_template,'c%d',['c' num2str(concatOrder)]);
  fileName_wildcard_with_full_path = strrep(fileName_wildcard_with_full_path,'%d','*');
  fileName_wildcard_with_full_path = strrep(fileName_wildcard_with_full_path,'.dat','.[d,m]at');
  fileName_wildcard = fileName_wildcard_with_full_path(length(param.fileName_directory)+2:end);
  command1 = ['cp -p ' fileName_wildcard_with_full_path ' ' param.share_directory];
  command2 = ['chmod 644 ' param.share_directory fileName_wildcard];
  commands = {command1,command2};
  take_turns_to_execute(commands,param,numWorker,workerID)
  
  add_log_entry(param,workerID,   sprintf('%10d %10d %20.4f',-concatOrder,0,toc)   ); tic
  
  command = ['rm -rf ' param.fileName_directory];
%  system(command);
  
  if isfield(param,'nN')
    if (param.nN<param.n)
      fileName_template_full = param.fileName_template;
      fileName_template_sparse = strrep(fileName_template_full,'.dat','.mat');
      myRows = get_row_col_range(param,numWorker,workerID);
      for row=myRows
        for col=get_row_col_range(param,numWorker,workerID,row);
          dSq = read_dSq(fileName_template_full,'double',concatOrder,row,col,param.n);
          write_dSq_sparse(fileName_template_sparse,[],concatOrder,row,col,dSq,param.nN)
        end
      end
      remove_files(param,concatOrder)
    end
  end
  
  add_log_entry(param,workerID,   sprintf('%10d %10d %20.4f',-concatOrder-1,0,toc)   ); tic
  
  status = 1;

% end function SnA_with_masks
