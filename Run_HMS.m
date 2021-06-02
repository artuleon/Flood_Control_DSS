function Run_HMS(filenameinput, filenameoutput, TextTemp);
%This is to Run HMS at all directories
fid = fopen (filenameinput, 'rt'); %Open file for reading  
if fid == -1
  error('Author:Function:OpenFile', 'Cannot open file: %s', filenameinput);
end
fout = fopen (filenameoutput, 'wt'); %Open file for writing
if fout == -1
  error('Author:Function:OpenFile', 'Cannot open file: %s', filenameoutput);
end

while ~feof(fid);     
        strTextLine = fgetl(fid); %To read one additional line 
        if strfind(strTextLine,'OpenProject') 
            fprintf(fout,'%s\n', TextTemp);        
        else   
            fprintf(fout,'%s\n',strTextLine);
        end
end
fclose (fid); %Close the text file
fclose (fout); %Close the text file




