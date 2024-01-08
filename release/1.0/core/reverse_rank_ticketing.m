function take_turns_to_execute(commands,param,numWorker,workerID)
%
% take_turns_to_execute(commands,param,numWorker,workerID)
%
% uses a ticketing scheme to control system I/O operations to avoid
% congestions and time-outs.
%
% Currently using reverse-rank ticketing, where worker# numWorker-1 goes first,
% then worker# numWorker-2, and so on, with worker# 0 going last.
%
% copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if (workerID==numWorker-1)
    create_ticket_for_worker(param,numWorker,workerID)
  end
  ticket = ticket_for_worker(param,numWorker,workerID);
  while ~exist(ticket,'file')
    pause(1)
  end
  for jj=1:numel(commands)
    command = commands{jj};
    system(command);
  end
  delete_ticket_for_worker(param,numWorker,workerID)
  if (workerID>0)
    create_ticket_for_worker(param,numWorker,workerID-1)
  end
% end function take_turns_to_execute

function create(some_file)
%
% create(some_file)
%
% creates a blank file with name some_file.
%
% copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  system(['touch ' some_file]);
% end function create

function create_ticket_for_worker(param,numWorker,workerID)
%
% create_ticket_for_worker(param,numWorker,workerID)
%
% creates the I/O permission ticket for worker with workerID.
%
% copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  create(ticket_for_worker(param,numWorker,workerID));
% end function create_ticket_for_worker

function delete_ticket_for_worker(param,numWorker,workerID)
%
% delete_ticket_for_worker(param,numWorker,workerID)
%
% deletes the I/O permission ticket for worker with workerID.
%
% copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  delete(ticket_for_worker(param,numWorker,workerID));
% end function delete_ticket_for_worker

function ticket=ticket_for_worker(param,numWorker,workerID)
%
% ticket=ticket_for_worker(param,numWorker,workerID)
%
% returns the I/O permission ticket for worker with workerID.
%
% copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ticket = [param.share_directory '.permission_TT2E_' num2str(workerID)];
% end function ticket_for_worker

