function ReadSpillCrestElev(j, filenameinput, TextTemp);
global hspillwayAtOverflowLevel
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
                    if strfind(strTextLine,'Spillway Crest Elevation:') 
                        str = 'Spillway Crest Elevation:';
                        str = [str ' '];                                            
                        temp_value = extractAfter(strTextLine, str); 
                        hspillwayAtOverflowLevel(j) = str2double(temp_value);                        
                    end  
                end        
        end
end
fclose (fid); %Close the text file


