function ReadInitialWetlandElev(j,filenameinput, TextTemp);
global h_wetland_initial_BASIN_file
%This is to update outflows and hydrographs at dams 

%This is to update outflows and hydrographs at dams 
fid = fopen (filenameinput, 'rt'); %Open file for reading  
if fid == -1
  error('Author:Function:OpenFile', 'Cannot open file: %s', filenameinput);
end

ii = 1;
while ~feof(fid);     
        strTextLine = fgetl(fid); %To read one additional line 
        if strfind(strTextLine,TextTemp)                
                while ii < 50
                    ii = ii + 1;
                    strTextLine = fgetl(fid); %To read one additional line
                    if strfind(strTextLine,'Initial Elevation: ')
                        str = 'Initial Elevation:';
                        str = [str ' '];                                            
                        temp_value = extractAfter(strTextLine, str); 
                        h_wetland_initial_BASIN_file(j) = str2double(temp_value);
                    end  
                end        
        end
end
fclose (fid); %Close the text file




