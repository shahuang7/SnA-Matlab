dataset=test_data
#dataset=PYP_152677_21556
#dataset=T_ordered
N=1000
n=100
c=200
numTask=8
test_task=workerID
#test_task=4

cat /home/sna/release/2.0/core/SnA.m \
  | sed 's/calc_sqDist_blocks(param,numWorker,workerID)/calc_sqDist_blocks(param,numWorker,'"$test_task"')/g' \
  | sed 's/shift_and_add_squared_distances(param,numWorker,workerID)/shift_and_add_squared_distances(param,numWorker,'"$test_task"')/g' \
  > ./SnA_tt.m
cat /home/sna/release/2.0/core/parallel_SnA.m \
  | sed 's/@SnA/@SnA_tt/g' \
  > ./parallel_SnA_tt.m
cat /home/sna/release/2.0/validation/run_parallel_SnA_quick_tests.m \
  | sed 's/\ \ parallel_SnA/\ \ parallel_SnA_tt/g' \
  | sed 's/diary/\%diary/g' \
  | sed 's/\ \ run_test/\ \ \%run_test/g' \
  | sed 's/\%run_test('\''A2'\'',1000,\ 1000,\ 100,\ 200,\ 8);/run_test('\''Timing Test'\'',1,\ '"$N"',\ '"$n"',\ '"$c"',\ '"$numTask"');/g' \
  | sed 's/test_data/'"$dataset"'/g' \
  > ./run_parallel_SnA_timing_tests.m
