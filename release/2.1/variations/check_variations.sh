diff /home/sna/release/2.0/core/calc_sqDist_blocks.m /home/sna/release/2.0/variations/calc_sqDist_blocks_with_masks.m \
| sed 's/sqDist/dotProduct/g' \
| sed 's/dmat/dpmat/g' > temp0
diff /home/sna/release/2.0/variations/calc_dotProduct_blocks.m ./calc_dotProduct_blocks_with_masks.m > temp1

diff temp0 temp1 | grep -v -e '< %' -e '> %'

rm temp0 temp1

################################################################################
# SnA --> SnA_with_masks

cat /home/sna/release/2.0/core/SnA.m \
| sed 's/SnA/SnA_with_masks/g' \
| sed 's/shift-and-add/shift-and-add_with_masks/g' \
| sed 's/calc_sqDist_blocks/calc_sqDist_blocks_with_masks/g' > temp.m
diff /home/sna/release/2.0/variations/SnA_with_masks.m temp.m

rm temp.m

################################################################################
# SnA --> SnA_dp

cat /home/sna/release/2.0/core/SnA.m \
| sed 's/SnA/SnA_dp/g' \
| sed 's/shift-and-add/shift-and-add_dp/g' \
| sed 's/calc_sqDist_blocks/calc_dotProduct_blocks/g' > temp.m
diff /home/sna/release/2.0/variations/SnA_dp.m temp.m

rm temp.m

################################################################################
# SnA_dp --> SnA_dp_with_masks

cat /home/sna/release/2.0/variations/SnA_dp.m \
| sed 's/SnA_dp/SnA_dp_with_masks/g' \
| sed 's/shift-and-add_dp/shift-and-add_dp_with_masks/g' \
| sed 's/calc_dotProduct_blocks/calc_dotProduct_blocks_with_masks/g' > temp.m
diff ./SnA_dp_with_masks.m temp.m

rm temp.m

################################################################################
# SnA_with_masks --> SnA_dp_with_masks

cat /home/sna/release/2.0/variations/SnA_with_masks.m \
| sed 's/SnA_with_masks/SnA_dp_with_masks/g' \
| sed 's/shift-and-add_with_masks/shift-and-add_dp_with_masks/g' \
| sed 's/calc_sqDist_blocks_with_masks/calc_dotProduct_blocks_with_masks/g' > temp.m
diff ./SnA_dp_with_masks.m temp.m

rm temp.m

################################################################################
# parallel_SnA --> parallel_SnA_with_masks

cat /home/sna/release/2.0/core/parallel_SnA.m \
| sed 's/SnA/SnA_with_masks/g' > temp.m
diff /home/sna/release/2.0/variations/parallel_SnA_with_masks.m temp.m

rm temp.m

################################################################################
# parallel_SnA --> parallel_SnA_dp

cat /home/sna/release/2.0/core/parallel_SnA.m \
| sed 's/SnA/SnA_dp/g' \
| sed 's/dSq_N/dp_N/g' > temp.m
diff /home/sna/release/2.0/variations/parallel_SnA_dp.m temp.m

rm temp.m

################################################################################
# parallel_SnA_dp --> parallel_SnA_dp_with_masks

cat /home/sna/release/2.0/variations/parallel_SnA_dp.m \
| sed 's/SnA_dp/SnA_dp_with_masks/g' > temp.m
diff ./parallel_SnA_dp_with_masks.m temp.m

rm temp.m

################################################################################
# parallel_SnA_with_masks --> parallel_SnA_dp_with_masks

cat /home/sna/release/2.0/variations/parallel_SnA_with_masks.m \
| sed 's/SnA_with_masks/SnA_dp_with_masks/g' \
| sed 's/dSq_N/dp_N/g' > temp.m
diff ./parallel_SnA_dp_with_masks.m temp.m

rm temp.m
