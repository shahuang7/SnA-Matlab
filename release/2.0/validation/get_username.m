function userID=get_username()
  SnA_user_identity_file = '.SnA_user_identity';
  system(['whoami > ' SnA_user_identity_file]);
  fid = fopen(SnA_user_identity_file,'r');
  userID = fscanf(fid,'%s');
  fclose(fid);
  delete(SnA_user_identity_file);
% function get_username
