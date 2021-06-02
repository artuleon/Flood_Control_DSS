function Write_Stage_Storage_Curve(kk, filenameinput, filenameoutput, Text_Open_File, Text_Save_File);
%This is to chnage the Pytho code for performing mass balance in all
%wetlands
global NumberWetlands_managed
global Name_of_Elev_Storage

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
        if strfind(strTextLine,'dssFile = HecDss.open("')
            fprintf(fout,'%s\n', Text_Open_File);
        elseif strfind(strTextLine,'elev = dssFile.get(');                                          
            text_temp = ['  elev = dssFile.get("//'  Name_of_Elev_Storage{kk} '/ELEVATION-STORAGE///TABLE/")'];
            fprintf(fout,'%s\n', text_temp);
        elseif strfind(strTextLine,'table.createExcelFile'); 
            fprintf(fout,'%s\n', Text_Save_File);
        else   
            fprintf(fout,'%s\n',strTextLine);
        end
end
fclose (fid); %Close the text file
fclose (fout); %Close the text file




