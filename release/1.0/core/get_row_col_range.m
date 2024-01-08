function range=get_row_col_range(param,numWorker,workerID,row)
  c = param.c;
  n = param.n;
  N = param.N;
  c_by_n = ceil(c/n);
  a = param.a;
  b = param.b;
  if (numWorker==1)
    numRow = ceil((N-a-b)/n);
    if (nargin==3)
      range = 1:numRow;
    else
      range = row:numRow;
    end
    return
  end
  if (a+b==c)
    c_by_n = 0;
  end
  halfway = floor(numWorker/2);
  maxRange = ceil((N-a-b)/n);
  if (nargin==3)
  % calculate and return row range
    if (workerID<halfway)
      r0 = workerID+1;
      r1 = r0+c_by_n;
      r1 = min(r1,maxRange);
      s0 = numWorker+1-r0;
      s1 = s0+c_by_n;
      s1 = min(s1,maxRange);
      range = unique([r0:r1,s0:s1]);
    else
      r0 = numWorker-workerID;
      r1 = r0+c_by_n;
      r1 = min(r1,maxRange);
      range = [r0:r1];
    end
  else
  % calculate and return column range
    if (workerID<halfway)
      c0 = row;
      if (row>halfway)
        c1 = maxRange;
      else
        c1 = min(halfway+c_by_n,maxRange);
      end
    else
      c0 = max(halfway+1,row);
      c1 = maxRange;
    end
    range = [c0:c1];
  end
