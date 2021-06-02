function ChangeDSS_files(filenameinput, filenameoutput, TextTemp, FlowsTemp);
global HecHMSTime
%This is to update outflows and hydrographs at dams 

%This is to update outflows and hydrographs at dams 
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
        if strfind(strTextLine,'myDss = HecDss.open') 
            fprintf(fout,'%s\n', TextTemp);            
        elseif strfind(strTextLine,'start = HecTime('); 
            fprintf(fout,'%s\n',HecHMSTime);
        elseif strfind(strTextLine,'flows = ['); 
            fprintf(fout,'%s\n',FlowsTemp);  
        else   
            fprintf(fout,'%s\n',strTextLine);
        end
end
fclose (fid); %Close the text file
fclose (fout); %Close the text file




