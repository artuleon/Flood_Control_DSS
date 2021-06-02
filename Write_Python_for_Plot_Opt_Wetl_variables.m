function Write_Python_for_Plot_Opt_Wetl_variables(filenameinput, filenameoutput, ElevTemp, Total_outflow, ...
           InflowTemp, StorTemp, Opti_ReleaseTemp, SpillFlowTemp, Name_Wetland_plot, Text_Open_File, Text_Save_File);
%This is to chnage the Pytho code for performing mass balance in all
%wetlands

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
                fprintf(fout,'%s\n', ElevTemp);
        elseif strfind(strTextLine,'stora = dssFile.get('); 
                fprintf(fout,'%s\n', StorTemp);
        elseif strfind(strTextLine,'inflow = dssFile.get('); 
                fprintf(fout,'%s\n', InflowTemp);
        elseif strfind(strTextLine,'TotalOutflow = dssFile.get('); 
                fprintf(fout,'%s\n', Total_outflow);   
        elseif strfind(strTextLine,'OptimRelease = dssFile.get('); 
                fprintf(fout,'%s\n', Opti_ReleaseTemp);   
        elseif strfind(strTextLine,' Spill = dssFile.get('); 
                fprintf(fout,'%s\n', SpillFlowTemp);   
        elseif strfind(strTextLine,'plot.setPlotTitleText('); 
                fprintf(fout,'%s\n', Name_Wetland_plot);  
        elseif strfind(strTextLine,'plot.save'); 
                fprintf(fout,'%s\n', Text_Save_File);  
        else   
            fprintf(fout,'%s\n',strTextLine);
        end
end
fclose (fid); %Close the text file
fclose (fout); %Close the text file




