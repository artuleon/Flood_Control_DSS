function Write_Python_for_Weland_Mass_balance(filenameinput, filenameoutput, Text_Open_File, Text_Save_File);
%This is to chnage the Pytho code for performing mass balance in all
%wetlands
global NumberWetlands_managed
global Name_of_Wetlands_with_active_control
global Timing_for_WritingDatatoExcel_from_HMS

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
                for kk = 1:NumberWetlands_managed  
                        StrID = num2str(kk); 
                        text_temp = ['  elev' StrID '= dssFile.get("//' Name_of_Wetlands_with_active_control{kk} '/ELEVATION' Timing_for_WritingDatatoExcel_from_HMS '")'];
                        fprintf(fout,'%s\n', text_temp);
                end
        elseif strfind(strTextLine,'inflow = dssFile.get('); 
                for kk = 1:NumberWetlands_managed  
                        StrID = num2str(kk);
                        text_temp = ['  inflow' StrID '= dssFile.get("//' Name_of_Wetlands_with_active_control{kk} '/FLOW-COMBINE' Timing_for_WritingDatatoExcel_from_HMS '")'];
                        fprintf(fout,'%s\n', text_temp);
                end
        elseif strfind(strTextLine,'stor = dssFile.get('); 
                for kk = 1:NumberWetlands_managed  
                        StrID = num2str(kk);
                        text_temp = ['  stor' StrID '= dssFile.get("//' Name_of_Wetlands_with_active_control{kk} '/STORAGE' Timing_for_WritingDatatoExcel_from_HMS '")'];
                        fprintf(fout,'%s\n', text_temp);
                end
        elseif strfind(strTextLine,'totalOutflow = dssFile.get('); 
                for kk = 1:NumberWetlands_managed 
                        StrID = num2str(kk);
                        text_temp = ['  totalOutflow' StrID '= dssFile.get("//' Name_of_Wetlands_with_active_control{kk} '/FLOW' Timing_for_WritingDatatoExcel_from_HMS '")'];
                        fprintf(fout,'%s\n', text_temp);
                end
         elseif strfind(strTextLine,'releaseMain = dssFile.get('); 
                for kk = 1:NumberWetlands_managed  
                        StrID = num2str(kk);
                        text_temp = ['  releaseMain' StrID '= dssFile.get("//' Name_of_Wetlands_with_active_control{kk} '-RELEASE/FLOW' Timing_for_WritingDatatoExcel_from_HMS '")'];
                        fprintf(fout,'%s\n', text_temp);
                end
        elseif strfind(strTextLine,'spillOvertopping = dssFile.get('); 
                for kk = 1:NumberWetlands_managed  
                        StrID = num2str(kk);
                        text_temp = ['  spillOvertopping' StrID '= dssFile.get("//' Name_of_Wetlands_with_active_control{kk} '-RELEASE/FLOW' Timing_for_WritingDatatoExcel_from_HMS '")'];
                        fprintf(fout,'%s\n', text_temp);
                end 
                
        elseif strfind(strTextLine,'datasets.add(elev)'); 
                for kk = 1:NumberWetlands_managed 
                    StrID = num2str(kk);
                    text_temp = ['datasets.add(elev' StrID ')'];
                    fprintf(fout,'%s\n', text_temp);
                end 
        elseif strfind(strTextLine,'datasets.add(inflow)'); 
                for kk = 1:NumberWetlands_managed 
                    StrID = num2str(kk);
                    text_temp = ['datasets.add(inflow' StrID ')'];
                    fprintf(fout,'%s\n', text_temp);
                end 
        elseif strfind(strTextLine,'datasets.add(stor)'); 
                for kk = 1:NumberWetlands_managed 
                    StrID = num2str(kk);
                    text_temp = ['datasets.add(stor' StrID ')'];
                    fprintf(fout,'%s\n', text_temp);
                end 
        elseif strfind(strTextLine,'datasets.add(totalOutflow)'); 
                for kk = 1:NumberWetlands_managed 
                    StrID = num2str(kk);
                    text_temp = ['datasets.add(totalOutflow' StrID ')'];
                    fprintf(fout,'%s\n', text_temp);
                end
        elseif strfind(strTextLine,'datasets.add(releaseMain)'); 
                for kk = 1:NumberWetlands_managed 
                    StrID = num2str(kk);
                    text_temp = ['datasets.add(releaseMain' StrID ')'];
                    fprintf(fout,'%s\n', text_temp);
                end 
        elseif strfind(strTextLine,'datasets.add(spillOvertopping)'); 
                for kk = 1:NumberWetlands_managed 
                    StrID = num2str(kk);
                    text_temp = ['datasets.add(spillOvertopping' StrID ')'];
                    fprintf(fout,'%s\n', text_temp);
                end 
        elseif strfind(strTextLine,'table.createExcelFile'); 
                fprintf(fout,'%s\n', Text_Save_File);
        else   
            fprintf(fout,'%s\n',strTextLine);
        end
end
fclose (fid); %Close the text file
fclose (fout); %Close the text file




