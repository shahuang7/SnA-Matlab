addpath('/home/sna/release/2.1/validation')
for test_num=1:100
  n = randi(1000,1);
  nN = randi(n,1);
  for isdiagonal=[true,false]
    if test_dSq_sparse_read_write(n,nN,isdiagonal)
      disp(['Test# ' num2str(test_num) ': PASSED'])
    else
      disp(['Test# ' num2str(test_num) ': FAILED'])
    end
  end
end
