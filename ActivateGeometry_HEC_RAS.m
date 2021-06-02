function ActivateGeometry_HEC_RAS(filenameinput, filenameoutput, TextTemp, FlowsTemp);
%This is to activate the geometry processor 
%and avoid errors when running HEC-RAS

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
        if strfind(strTextLine,'Run HTab') 
            TextTemp= 'Run HTab=-1';
            fprintf(fout,'%s\n', TextTemp);
        else   
            fprintf(fout,'%s\n',strTextLine);
        end
end
fclose (fid); %Close the text file
fclose (fout); %Close the text file