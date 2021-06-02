function ChangeInlineStruct_Data(filenameinput,filenameoutput,...
    Outflow_array_main_dams, Outflow_array_last_line_dams, ...
    Inflow_array_main_UPSTREAM_ENDS,Inflow_array_last_line_UPSTREAM_ENDS, ...
    Lateral_inflow_array_main_wetlands,Lateral_inflow_array_last_line_wetlands);

global Number_dams
global Inflow_points_UPSTREAM_ENDS
global NLines_Out_wetlands
global Inflow_points_WETLANDS_to_WriteinFile
global NLines_Out_dam
global Station_lateral_flows_for_Wetlands
global NumberWetlands_managed
global ID_downst_Wetlands_entering_RAS

%This is to update outflows and hydrographs at dams 
fid = fopen (filenameinput, 'rt'); %Open file for reading  
if fid == -1
  error('Author:Function:OpenFile', 'Cannot open file: %s', filenameinput);
end
fout = fopen (filenameoutput, 'wt'); %Open file for writing
if fout == -1
  error('Author:Function:OpenFile', 'Cannot open file: %s', filenameoutput);
end

i = 0; %initialize pointer for dams
m = 0; %initialize pointer for inflow hydrographs at UPSTREAM_ENDS
%li = 0; %initialize pointer for lateral inflow hydrographs from wetlands
kk = 1;


copy_completed = 0;% 0 is not completed, 1 is completed    
while ~feof(fid);     
        strTextLine = fgetl(fid); %To read one additional line
%         if strfind(strTextLine,'Flow Hydrograph=') & Number_inflow_hydrograph_UPSTREAM_ENDS_that_change>0;  
%                 m = m+1;
%                 StrID = num2str(Inflow_points_UPSTREAM_ENDS);
%                 hydrostring = ['Flow Hydrograph= ' StrID];
%                 fprintf(fout,'%s\n',hydrostring);        
%                  for k = 1:NLines_inflow_UPSTREAM_ENDS-1; %All lines except last one 
%                         %convert to real + char + reshape + transpose            
%                         array1 = Inflow_array_main_UPSTREAM_ENDS(k,:,m);
%                         B1string=reshape(sprintf('%8.1f',array1),8,[])';  
%                         B1string=[cellstr(B1string)]';
%                         B1string = strjoin(B1string,''); 
%                         fprintf(fout,'%s\n',B1string);
%                 end  
%                 array2 = Inflow_array_last_line_UPSTREAM_ENDS(1,:,m);
%                 B1string = reshape(sprintf('%8.1f',array2), 8, [])';   
%                 B1string=[cellstr(B1string)]';
%                 B1string = strjoin(B1string,''); 
%                 fprintf(fout,'%s\n',B1string);
%                 r = 1;
%                 while r < 1000;
%                         strTextLine = fgetl(fid); %To read one additional line
%                         if strfind(strTextLine,'Flow Hydrograph QMult=') | strfind(strTextLine,'DSS Path='); 
%                                 if strfind(strTextLine,'Flow Hydrograph QMult='); 
%                                     fprintf(fout,'%s\n',strTextLine);
%                                     strTextLine = fgetl(fid); %To read one additional line
%                                     fprintf(fout,'%s\n',strTextLine);
%                                     r = 2000;
%                                 elseif strfind(strTextLine,'DSS Path=');
%                                     fprintf(fout,'%s\n',strTextLine);
%                                     r = 2000;
%                                 else
%                                     msg = 'Error occurred in routine ChangeInlineStruct_Data';
%                                     error(msg)
%                                 end  
%                         end 
%                         r = r+1;
%                 end  
        if strfind(strTextLine,'Rule Table=') & Number_dams > 0;
                i = i+1;
                fprintf(fout,'%s\n',strTextLine);
                for k = 1:NLines_Out_dam;            
                        strTextLine = fgetl(fid);         
                        fprintf(fout,'%s\n',strTextLine);
                end
                for k = 1:NLines_Out_dam-1; %All lines except last one
                        array3 = Outflow_array_main_dams(k,:,i);
                        A1string=reshape(sprintf('%8.0f',array3),8,[])';        
                        A1string=[cellstr(A1string)]';
                        A1string = strjoin(A1string,''); 
                        fprintf(fout,'%s\n',A1string);
                end  
                array4 = Outflow_array_last_line_dams(1,:,i);
                A1string = reshape(sprintf('%8.0f',array4), 8, [])';                
                A1string=[cellstr(A1string)]';
                A1string = strjoin(A1string,''); 
                fprintf(fout,'%s\n',A1string);
                r = 1;
                while r < 1000;
                        strTextLine = fgetl(fid); %To read one additional line
                        if strfind(strTextLine,'Rule Operation='); 
                                fprintf(fout,'%s\n',strTextLine);
                                r = 2000;
                        end  
                        r = r+1;
                end 
        elseif strfind(strTextLine,'Boundary Location='); 
                strTextLine_1 = fgetl(fid); %To read one additional line
                if strfind(strTextLine_1,'Friction Slope='); 
                        %to print friction slope
                        fprintf(fout,'%s\n',strTextLine); 
                        fprintf(fout,'%s\n',strTextLine_1);                         
                else 
                        strTextLine_2 = fgetl(fid); %To read one additional line   
                        if strfind(strTextLine_2,'Flow Hydrograph='); 
                                        fprintf(fout,'%s\n',strTextLine); 
                                        fprintf(fout,'%s\n',strTextLine_1); 
                                        fprintf(fout,'%s\n',strTextLine_2); 
                        elseif  strfind(strTextLine_2,'Lateral Inflow Hydrograph='); 
                                if copy_completed <= NumberWetlands_managed
                                        FOUND_MATCH = 0; %0 No match found, 1 match found 
                                        for kk = 1:NumberWetlands_managed;
                                                        if strfind(strTextLine,Station_lateral_flows_for_Wetlands(kk,:));                                                    
                                                                        copy_completed = copy_completed + 1;
                                                                        FOUND_MATCH = 1;

                                                                        li = ID_downst_Wetlands_entering_RAS(kk);
                                                                        StrID = num2str(Inflow_points_WETLANDS_to_WriteinFile);
                                                                        hydrostring = ['Lateral Inflow Hydrograph= ' StrID];
                                                                        fprintf(fout,'%s\n',strTextLine); 
                                                                        fprintf(fout,'%s\n',strTextLine_1); 
                                                                        fprintf(fout,'%s\n',hydrostring);        
                                                                        for k = 1:NLines_Out_wetlands-1; %All lines except last one 
                                                                                %convert to real + char + reshape + transpose            
                                                                                array1 = Lateral_inflow_array_main_wetlands(k,:,li);
                                                                                B1string=reshape(sprintf('%8.0f',array1),8,[])';  
                                                                                B1string=[cellstr(B1string)]';

                                                                                B1string = strjoin(B1string,''); 
                                                                                fprintf(fout,'%s\n',B1string);
                                                                        end  
                                                                        array2 = Lateral_inflow_array_last_line_wetlands(1,:,li);
                                                                        B1string = reshape(sprintf('%8.0f',array2), 8, [])';   
                                                                        B1string=[cellstr(B1string)]';
                                                                        B1string = strjoin(B1string,''); 
                                                                        fprintf(fout,'%s\n',B1string);

                                                                        

                                                        
                                                                        %fprintf(fout,'%s\n',strTextLine); %This will print the "Flow Hydrograph QMult= 0.01" 
                                                                        r = 1;
                                                                        %strTextLine = strTextLine_2
                                                                        while r < 10000;      
                                                                                        strTextLine = fgetl(fid); %To read one additional line
                                                                                        if strfind(strTextLine,'Flow Hydrograph QMult='); 
                                                                                            fprintf(fout,'%s\n',strTextLine);
                                                                                            strTextLine = fgetl(fid); %To read one additional line
                                                                                            fprintf(fout,'%s\n',strTextLine);
                                                                                            r = 20000;
                                                                                        elseif strfind(strTextLine,'DSS Path=');
                                                                                            fprintf(fout,'%s\n',strTextLine);
                                                                                            r = 20000;
                                                                                        end  
                                                                                        
                                                                                        
                                                                                %strTextLine = fgetl(fid); %To read one additional line
                                                                                r = r+1;
                                                                        end
                                                                        if r<19999;
                                                                                msg = 'Error inlne';
                                                                                error(msg)
                                                                        end
                                                        end
                                        end  

                                        if FOUND_MATCH == 0; %if match is not found
                                                fprintf(fout,'%s\n',strTextLine); 
                                                fprintf(fout,'%s\n',strTextLine_1); 
                                                fprintf(fout,'%s\n',strTextLine_2); 
                                        end                        
                                else    
                                        fprintf(fout,'%s\n',strTextLine); 
                                        fprintf(fout,'%s\n',strTextLine_1); 
                                        fprintf(fout,'%s\n',strTextLine_2); 
                                end
                        else
                                % there may be other types of boundary such as friction
                                % slope for normal flow. We should only print one, to
                                % check other possible boundaries
                                  msg = 'Error occurred in routine ChangeInlineStruct_Data -Boundary does not exist';
                                  error(msg)
                        end
                end 
        else   
                fprintf(fout,'%s\n',strTextLine);  
        end
end
fclose (fid); %Close the text file
fclose (fout); %Close the text file



