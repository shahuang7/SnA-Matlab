function progress=check_job_ticket_progress(job,ticket,progress)
  if ~exist(ticket,'file')
    disp([datestr(now) sprintf('  job ticket missing ...')])
    for id=progress
      disp([datestr(now) sprintf('  task#%d recalled',id)])
    end
    progress = [];
    numTasks = length(job);
    for nn=1:numTasks
      destroy(job{nn});
    end
    try
      matlabpool close
    catch
    end
  end
