%Convert precipitation forevass tp DSS files to be read by HEC-HMS
%Written by Arturo Leon, June 02, 2019


home_dir = pwd; %This returns the working directory.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
Path_executable = ['C:\Python27\ArcGIS10.6\']
cd(Path_executable) 
string_temp6 = ['python2.exe ' home_dir '\utilitaries\ASCToDSS_Create_Names.py']
[status,cmdout] = system(string_temp6)
disp('time for creating names')
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Delete Persian Raster folder
to_delete_direct = [home_dir '\RainAcquire\Persiann\Raster']
if( exist(to_delete_direct, 'dir')) 
    [status, message, messageid] = rmdir(to_delete_direct, 's')   
    if status == 0
        msg = 'Folder named ---Raster---- cannot be deleted. Try to run again the matlab code. If you still have an error, please close matlab and delete the folder manually' 
        error(msg)
    else
        cd ([home_dir '\RainAcquire\Persiann'])
        mkdir('Raster') 
    end
else 
        cd ([home_dir '\RainAcquire\Persiann'])
        mkdir('Raster')
end

%Delete Persian UTM folder
to_delete_direct = [home_dir '\RainAcquire\Persiann\UTM']
if( exist(to_delete_direct, 'dir')) 
    [status, message, messageid] = rmdir(to_delete_direct, 's')  
    if status == 0
        msg = 'Folder named ---UTM---- cannot be deleted. Try to run again the matlab code. If you still have an error, please close matlab and delete the folder manually' 
        error(msg)
    else
        cd ([home_dir '\RainAcquire\Persiann'])
        mkdir('UTM') 
    end
else 
        cd ([home_dir '\RainAcquire\Persiann'])
        mkdir('UTM')
end

%Delete Persian UTMASCII folder
to_delete_direct = [home_dir '\RainAcquire\Persiann\UTMASCII']
if( exist(to_delete_direct, 'dir')) 
    [status, message, messageid] = rmdir(to_delete_direct, 's')   
    if status == 0
        msg = 'Folder named ---UTMASCII---- cannot be deleted. Try to run again the matlab code. If you still have an error, please close matlab and delete the folder manually' 
        error(msg)
    else
        cd ([home_dir '\RainAcquire\Persiann'])
        mkdir('UTMASCII') 
    end
else 
        cd ([home_dir '\RainAcquire\Persiann'])
        mkdir('UTMASCII')
end

Path_executable = ['C:\Python27\ArcGIS10.6\']
cd(Path_executable) 
tic
string_temp = ['python2.exe ' home_dir '\utilitaries\ASCIIToRasterFinal.py']
[status,cmdout] = system(string_temp)
disp('time for ASCIIToRaster')
toc

%pause()




tic
string_temp2 = ['python2.exe ' home_dir '\utilitaries\Projection.py']
[status,cmdout] = system(string_temp2)
disp('time for Projection')
toc


tic
string_temp3 = ['python2.exe ' home_dir '\utilitaries\WGSToUTM_Resample.py']
[status,cmdout] = system(string_temp3)
disp('time for WGSToUTM_Resample')
toc


tic
string_temp4 = ['python2.exe ' home_dir '\utilitaries\UTMToASCII.py']
[status,cmdout] = system(string_temp4)
disp('time for UTMToASCII')
toc



tic
path_asc2dssGrid_executable = [home_dir '\RainAcquire\Persiann\UTMASCII\']
cd(path_asc2dssGrid_executable)
string_temp5 = [path_asc2dssGrid_executable 'Batch_ASCIIToDSS.BAT']
[status,cmdout] = system(string_temp5)
disp('time for converting to DSS')
toc






