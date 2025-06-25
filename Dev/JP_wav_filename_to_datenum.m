function wav_start_datenum = JP_wav_filename_to_datenum(wav_Filename)

%SCW1984_20210421_132000.wav
us_pos = strfind(wav_Filename,'_');
tmp_String1 = wav_Filename(us_pos(1)+1:us_pos(1)+8); 
tmp_String2 = wav_Filename(us_pos(2)+1:us_pos(2)+6);
tmp_String = strcat(tmp_String1,tmp_String2);
wav_start_datenum = datenum(tmp_String,'yyyymmddHHMMSS');  