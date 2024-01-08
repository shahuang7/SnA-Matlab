function status=reconstruct(param)
  D = param.D;
  concatOrder = param.concatOrder;
  kOfInterest = param.kOfInterest;
  tOfInterest = param.tOfInterest;
  copyOfInterest = param.copyOfInterest;
  dataSVD = param.dataSVD;
  logfile = param.logfile;
  reconstructedData = param.reconstructedData;
  
  fidLOG = fopen(logfile,'w');
  clk = clock;
  [status,nodename] = unix('hostname');
  fprintf(fidLOG,'reconstruct started at %i/%i/%i %i:%i:%2.1f \n',...
    clk(1),clk(2),clk(3),clk(4),clk(5),clk(6));
  fprintf(fidLOG,'Node name: %s \n',nodename);
  fprintf(fidLOG,'SVD results: %s \n',dataSVD);
  load(dataSVD,'U','S','V');
  num_k = length(kOfInterest);
  num_t = length(tOfInterest);
  X = zeros(num_k,D,num_t);
  for i3=1:num_t
    t = tOfInterest(i3);
    fprintf(fidLOG,'time point# %d of %d ... \n',i3,num_t);
    for i1=1:num_k
      k = kOfInterest(i1);
      Xk = zeros(D,1);
      for cc=copyOfInterest
        Xk = Xk+U((cc-1)*D+[1:D],k)*S(k,k)*V(t+cc,k);
      end
      X(i1,:,i3) = Xk/concatOrder;
    end
  end
  save(reconstructedData,'X','kOfInterest','tOfInterest');
  clk = clock;
  fprintf(fidLOG,'reconstruct ended at %i/%i/%i %i:%i:%2.1f \n',...
    clk(1),clk(2),clk(3),clk(4),clk(5),clk(6));
  fclose(fidLOG);
  status = 1;
  return
% end function reconstruct
