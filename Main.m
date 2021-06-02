clear all 
close all
%close all offecho Setting
!taskkill /im ras.exe  
%This will kill all RAS running models
global Pop_Opt 
global rasID_funct
global Number_combined_wetlands
global Inflow_points_LATERAL_FROM_WETLANDS
global Number_of_decision_variables
global string_Home_folder_RAS
global h
global Max_water_level_check_constraint
global number_of_cross_sections_constraints %This is the number of cross-sections at which constraints must be checked
global River_ID_target
global Reach_ID_target
global Node_ID_target
global Pattern_search_Optimization
global UseVectorized
global Number_hours_simu_HECHMS
global h_wet_init_depth
global h_wetland_initial_BASIN_file
global hspillwayAtOverflowLevel
global hmin_ecological_depth
global Number_of_RAS_folders_to_create
global Name_of_RAS_project 
global NumberWetlands_managed
global path_HMS_executable
global path_general
global Name_of_Wetlands_with_active_control
global Name_of_Elev_Storage
global Name_of_DSSFile_for_Outflows_of_Wetland_with_active_control
global string_Home_folder_HMS
global string_Home_folder_HMS_RAS
global InputWriteDSS 
global OutputWriteDSS 
global InputRUN_HMS
global OutputRUN_HMS
%global Python_running_HMS

global path_DSSVue_executable
global Name_of_HMS_project
global General_Name_of_Project
global PenaltyConstraintWaterLevelExceeded
global penalty_function_below_threshold
global Best_population_index
global Timing_for_WritingDatatoExcel_from_HMS
global g_number
global coeff_dry_wetland
global Number_hours_simu_RAS
global Inflow_wetlands_for_constraint 
global Ecologicaldepth_storage
global h_End_optimization
global Initial_storage
global End_storage
global StorageAtOverflowLevel
global AllocatedInteger
global HecHMSTime
global InputRUN_HMSPy
global OutputRUN_HMSPy
global Utilitaries_directory


%global Python_running_HMS

%persistent_variables()
g_number = 0;
AllocatedInteger = 0;
pyenv('Version','2.7') %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%please don't touch the block here
home_dir = pwd; 
path_general = home_dir;
path_DSSVue_executable = 'C:\Program Files (x86)\HEC\HEC-DSSVue';


%path_DSSVue_executable3 = 'C:\Program Files (x86)\HEC\HEC-DSSVue\HECDSSVue3';
path_HMS_executable = 'C:\Program Files (x86)\HEC\HEC-HMS\4.3';
InputWriteDSS = [path_general '\utilitaries\WriteDss_doNOTdelete.py'];
OutputWriteDSS = [path_general '\utilitaries\WriteDss.py']; 
InputRUN_HMS = [path_general '\utilitaries\Running_HMS_doNOTdelete.script'];
OutputRUN_HMS = [path_general '\utilitaries\Running_HMS.script']; 
InputRUN_HMSPy = [path_general '\utilitaries\HMScompute_current_doNOTdelete.py'];
OutputRUN_HMSPy = [path_general '\utilitaries\HMScompute_current.py']; 
Utilitaries_directory = [path_general '\utilitaries']; 
%To run HMS we need to install Jython For HEC-HMS. Check our information in
%the course Optimization


%command_for_running_HMS = ['hec-hms.cmd -s ' home_dir '\utilitaries\Running_HMS.script'];
%Python_running_HMS = ['hec-hms.cmd -script ' home_dir '/utilitaries/HMScompute_current.py']
%hec-hms.cmd -script C:/Projects/castro/scripts/compute_current.py
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Enter Start Date of simulation in HEC-HMS (Format: "two digits day/three first digits
%of Month/Four digits of Year, example: '01JAN2018')
EnterDateofsimulationHECHMS = '15APR2016';
Timing_for_WritingDatatoExcel_from_HMS = ['/' EnterDateofsimulationHECHMS '/1HOUR/RUN:RUN 1/'];

%Enter Data of HEC-RAS
%Stations to check constraints (maximum water surface elevations); If there
%are 10 cross sections, enter 10 river names, 10 reach IDs and 10 Node IDs
General_Name_of_Project = 'Cypress'; %This name should not contain HMS or RAS in its name
Name_of_RAS_project = 'Cypress'; %This is the name of the RAS Project inside the CypressRAS folder
Name_of_HMS_project = 'CypressHMS'; %This is the name of the HMS Project inside the CypressHMS folder
string_Home_folder_RAS = 'CypressRAS'; %RAS AND HMS Folders must be within the same folder
string_Home_folder_HMS = 'CypressHMS';
string_Home_folder_HMS_RAS = 'CypressHMS_RAS'; %This is for the combined HMR_RAS folder

% data_River_ID_objective = ['Cypress Creek';'Cypress Creek';'Cypress Creek'];
% data_Reach_ID_objective = ['Lower Reach';'Lower Reach';'Lower Reach'];   
% data_Node_ID_objective = ['42006.23';'36901.44';'16128.68'];

data_River_ID_objective = ['Cypress Creek'];
data_Reach_ID_objective = ['Lower Reach'];   
data_Node_ID_objective = ['42006.23'];

%This is the number of the wetlands.  These names are the same as the names of the reservoirs in HEC-HMS
Name_of_Wetlands_with_active_control = {'WL-300', 'WL-310', 'WL-330', 'WL-380', 'WL-390', ...
                                        'WL-400', 'WL-410', 'WL-420'};
NumberWetlands_managed = numel(Name_of_Wetlands_with_active_control); %This is the number of wetlands with active control

%Enter the name of the Tables for the stage-storage curves. These names NEED to be in the SAME ORDER as
%Name_of_Wetlands_with_active_control (see above)
Name_of_Elev_Storage = {'Table 300', 'Table 310', 'Table 330', 'Table 380', ... 
                        'Table 390', 'Table 400', 'Table 410', 'Table 420'};

%Names of DSS files at wetland outflows (e.g., reservoirs in HEC-HMS). These names NEED to be in the SAME ORDER as
%Name_of_Wetlands_with_active_control (see above)
Name_of_DSSFile_for_Outflows_of_Wetland_with_active_control = {'WetlandOutflow300', 'WetlandOutflow310', ...
    'WetlandOutflow330', 'WetlandOutflow380', 'WetlandOutflow390', 'WetlandOutflow400', ...
    'WetlandOutflow410', 'WetlandOutflow420'}; 
%these names will be used for automatically sending data to HEC-HMS. The names of these DSS files NEED to be in the SAME ORDER as the
%file WetlCharactSiphonDownw_Drain.XLS

sizeDSS = numel(Name_of_DSSFile_for_Outflows_of_Wetland_with_active_control);
River_ID_target = cellstr(data_River_ID_objective); %To convert cell to string
Reach_ID_target = cellstr(data_Reach_ID_objective);
Node_ID_target = cellstr(data_Node_ID_objective);
number_of_cross_sections_constraints = numel(River_ID_target);

%Enter below the maximum water surface elevation for the cross-sections where the water level constraint is schecked. 
%The order must be according to the data entered above e.g.,data_River_ID_objective, data_Node_ID_objective, data_Reach_ID_objective 
Max_water_level_check_constraint = zeros(number_of_cross_sections_constraints,1); %This is very important as we need the info for maximum flow realeases for each wetland
Max_water_level_check_constraint(1) = 37.50 %This elevation is in meters;
Inflow_points_LATERAL_FROM_WETLANDS = 336; %Currently the time step is in hours, so these inflows are the number of hours of the entire HEC-HMS simulation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Check size of specified wetland DSS files
if numel(Name_of_DSSFile_for_Outflows_of_Wetland_with_active_control) ~= NumberWetlands_managed
    error('The number of managed wetlands with active control is not equal to the specified number of DSS files');
end

%Check size of data of River, reaches and Nodes
if numel(River_ID_target) ~= number_of_cross_sections_constraints
    error('the number of river elements for checking the constraints is not equal to the number of specified constraints.');
end
if numel(Reach_ID_target) ~= number_of_cross_sections_constraints
    error('the number of reach elements for checking the constraints is not equal to the number of specified constraints.');
end
if numel(Node_ID_target) ~= number_of_cross_sections_constraints
    error('the number of node elements for checking the constraints is not equal to the number of specified constraints.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%IMPORTANT. You cannot simultaneously use vectorized and parallel computations. 
%If you set 'UseParallel' to true and 'UseVectorized' to true, ga evaluates your fitness and constraint functions in a vectorized manner, not in parallel.
%Data for optimization
UseVectorized = 1 %Enter 1 if you will use a vectorized approach for the calculation of the objective fucntions and constraints. For Serial Enter 2 and for Parallel Enter 3 
Pattern_search_Optimization = 2  %Enter 1 for pattern search and 2 for GA 
Parallel_computing = 1  %Enter 1 if you will use parallel computing. Otherwise enter any other number
%(Try multi-start optimization) (Try multi-start optimization) (Try multi-start optimization) (Try multi-start optimization)
Number_of_processors_to_use_parallel_computing = 8 %Number of processors to be used in parallel computing
Pop_Opt = 0; %Initialization
if Pattern_search_Optimization == 2 %Genetic Algorithm
    Pop_Opt = 64; %original 24,Population of optmization for GA
    MaxGenerations_GA = 20; %original 15,Maximum Number of generations for GA
    MaxStallGenerations_SET_HERE = 0.5*MaxGenerations_GA;  %original 50, Maximum number of stalls
end

PenaltyConstraintWaterLevelExceeded = 10^2; %Penalty function when water level 
%at cross-section exceeds the maximum specified water level
penalty_function_below_threshold = 10; %Penalty function when water level 
%is below the specified water constraint level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Number_combined_wetlands = NumberWetlands_managed; %Number of combined wetlands with active control
Inflow_wetlands_for_constraint = zeros(NumberWetlands_managed,Inflow_points_LATERAL_FROM_WETLANDS);
MaxFlowRelease_Wetland = zeros(NumberWetlands_managed,1); %This is very important as we need the info for maximum flow realeases for each wetland 
Initial_storage = zeros(NumberWetlands_managed,1);
End_storage = zeros(NumberWetlands_managed,1);
hspillwayAtOverflowLevel = zeros(NumberWetlands_managed,1);
StorageAtOverflowLevel = zeros(NumberWetlands_managed,1);
Ecologicaldepth_storage = zeros(NumberWetlands_managed,1);
hmin_ecological_depth = zeros(NumberWetlands_managed,1);  
h_End_optimization = zeros(NumberWetlands_managed,1);  
h_wet_init_depth = zeros(NumberWetlands_managed,1);
h_wetland_initial_BASIN_file = zeros(NumberWetlands_managed,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Read data of Wetland Characteristics
cd(path_general);
filenameinput = [path_general '\RAS_HMS_Original_project\WetlCharactSiphonDownw_Drain.xlsx'];
sheet = 'Wetland_characteristics';
xlRange = ['B5:D' num2str(NumberWetlands_managed + 4)];
Wet_data= xlsread(filenameinput,sheet,xlRange); %Wet_data reads "numeric" data,string_wetlands reads "text" data

xlRange = ['A5:A' num2str(NumberWetlands_managed + 4)];
[temp_NO_USE_data,string_wetlands] = xlsread(filenameinput,sheet,xlRange); %Wet_data reads "numeric" data,string_wetlands reads "text" data
string_wetlands = string_wetlands';
tempdir = [path_general '\RAS_HMS_Original_project\' Name_of_HMS_project];
cd(tempdir)

%Make sure that DSS files in HEC-HMS exist and are the same as those
%indicated in MATLAB (main.m file)
for j = 1:NumberWetlands_managed;  
    file_to_check = [Name_of_DSSFile_for_Outflows_of_Wetland_with_active_control{j}  '.dss'];
    assert( exist(file_to_check, 'file' ) == 2, 'DSS files in HEC-HMS are not the same as those indicated in the Matlab file (Name_of_Wetlands_with_active_control)' );        
end

%Make sure that DSS files in HEC-HMS have the same names as the Wetland file 
for j = 1:NumberWetlands_managed;      
        if strcmp(string_wetlands(j),Name_of_Wetlands_with_active_control(j)) == 0 %1 means that they are equal, 0 means that they are not equal
             error('The names of wetlands specified in MATLAB are not in the same order as those indicated in WetlCharactSiphonDownw_Drain.xlsx file OR the names are different');
        end
end

for j = 1:NumberWetlands_managed;                  
        h_wet_init_depth(j) = Wet_data(j,1)+0.00000001; %Initial water depths at wetland 
        hmin_ecological_depth(j) = Wet_data(j,2)+0.00000001; %Minimum water depth for ecological purposes        
        h_End_optimization(j) = Wet_data(j,3)+0.00000001; %Maximum water depth in wetland
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This is to read the Initial month/year of the simulation  
%This is also to read the day and starting hour of the simulation  

filenameinput = [path_general '\RAS_HMS_Original_project\' Name_of_HMS_project '\Control_1.control'];   
TextTemp = 'Start Date:'; 
fid = fopen (filenameinput, 'rt'); %Open file for reading  
if fid == -1
  error('Author:Function:OpenFile', 'Cannot open file: %s', filenameinput);
end
while ~feof(fid);     
        strTextLine = fgetl(fid); %To read one additional line 
        if strfind(strTextLine,TextTemp)              
            str = extractAfter(strTextLine,"Start Date: ");
            Month_simulation = str(double(str) > 64);
            day_simulation = extractBefore(str, Month_simulation);            
            day_simulation = day_simulation(find(~isspace(day_simulation)));
            str = [Month_simulation ' '];
            Year_simulation = extractAfter(strTextLine, str);
        elseif strfind(strTextLine,"Start Time:")      
            str = extractAfter(strTextLine,"Start Time: ");
            str2 = ":";
            hour_simulation1 = extractBefore(str, str2);
            hour_simulation2 = extractAfter(str, str2);
            hour_simulation = [hour_simulation1 hour_simulation2]; 
        end
end

fclose (fid); %Close the text file  
month_temp = extractBetween(Month_simulation,1,3);
month_temp = [month_temp{:}];

day_1 = extractBetween(EnterDateofsimulationHECHMS,1,2);
month_1 = extractBetween(EnterDateofsimulationHECHMS,3,5);
year_1 = extractBetween(EnterDateofsimulationHECHMS,6,9);
day_1 = [day_1{:}];
month_1 = [month_1{:}];
year_1 = [year_1{:}];

HecHMSTime = ['    start = HecTime("' day_simulation month_1 ...
                    Year_simulation '", "' hour_simulation '")'];


%%Do checks here   
if strcmpi(month_temp, month_1) == 0 
    msg = 'Month in HEC-HMS (Control file) and MATLAB are not the same. Modify data in EnterDateofsimulationHECHMS'; 
    error(msg)
    pause
end

if not(str2double(day_simulation) == str2double(day_1))
    msg = 'Day in HEC-HMS (Control file) and MATLAB are not the same. Modify data in EnterDateofsimulationHECHMS'; 
    error(msg)
    pause
end
if not(str2double(Year_simulation) == str2double(year_1))
    msg = 'Day in HEC-HMS (Control file) and MATLAB are not the same. Modify data in EnterDateofsimulationHECHMS'; 
    error(msg)
    pause
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(path_general);
%This is to read the initial water elevations for the managed wetlands
% in the HEC-HMS BASIN file. Then we compare this elevations with the user-supplied 
%initial water elevations for the managed wetlands 
for j = 1:NumberWetlands_managed;    
    filenameinput = [path_general '\RAS_HMS_Original_project\' Name_of_HMS_project '\Basin_1.basin'];   
    string_wetland = string({cellstr(Name_of_Wetlands_with_active_control(j))});
    string_wetland2 = "Reservoir: ";
    TextTemp = append(string_wetland2, string_wetland);        
    ReadInitialWetlandElev(j, filenameinput, TextTemp);
end  
%Check if initial water elevations for the managed wetlands is the same in
%the BASIN file and the Excel file
for j = 1:NumberWetlands_managed;    
    if abs(h_wetland_initial_BASIN_file(j)-h_wet_init_depth(j)) > 0.01        
        error('Initial water elev. for wetland is not the same in BASIN and Excel file.');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This is to read the Spillway Crest Elevation: 
for j = 1:NumberWetlands_managed;    
    filenameinput = [path_general '\RAS_HMS_Original_project\' Name_of_HMS_project '\Basin_1.basin'];       
    string_wetland = string({cellstr(Name_of_Wetlands_with_active_control(j))});
    string_wetland2 = "Reservoir: ";
    TextTemp = append(string_wetland2, string_wetland); 
    ReadSpillCrestElev(j,filenameinput, TextTemp);    
end   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Create text files with stage storage curve for interpolation
Input_temp = [path_general '\utilitaries\SaveStage_Storage_doNOTdelete.py'];
Output_temp = [path_general '\utilitaries\SaveStage_Storage.py']; 
Text_Open_File = ['  dssFile = HecDss.open("' path_general '\RAS_HMS_Original_project\' ...
    string_Home_folder_HMS '\CypressHMS.dss")'];
  
for j = 1:NumberWetlands_managed;    
    cd(path_general);
    string_wetland_Table = string({cellstr(Name_of_Elev_Storage(j))});
    string_temp = '.xls")';
    Text_Save_File = ['table.createExcelFile(list, "' path_general '\RAS_HMS_Original_project\' ...
    string_Home_folder_HMS '\'];   
    Text_Save_File = append(Text_Save_File, string_wetland_Table,string_temp); 
    Write_Stage_Storage_Curve(j,Input_temp, Output_temp, Text_Open_File, Text_Save_File);
    
    cd(path_DSSVue_executable); 
    string_temp = ['HEC-DSSVue.exe ' path_general '\utilitaries\SaveStage_Storage.py'];
    [status,cmdout] = system(string_temp);
    if status ~= 0
        disp('Error HEC-DSSVue.exe. Main.m')
        error('Error using HEC-DSSVue.exe')
        pause
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%These values are interpolated from Elevation-Storage Curves
for j = 1:NumberWetlands_managed;         
        filenameinput = [path_general '\RAS_HMS_Original_project\' ...
        string_Home_folder_HMS '\' Name_of_Elev_Storage{j} '.xls'];
        sheet = 'Sheet1';
        StaStorData = xlsread(filenameinput,sheet); %Wet_data reads "numeric" data,string_wetlands reads "text" data
        
        %%Do checks here        
        if (hspillwayAtOverflowLevel(j) < h_wet_init_depth(j))
            msg = 'Initial depth in reservoir cannot be above than spillway level in wetland. '; 
            error(msg)
            pause
        end
        
        if (hspillwayAtOverflowLevel(j) < hmin_ecological_depth(j))
            msg = 'Ecological depth in reservoir cannot be above than spillway level in wetland. '; 
            error(msg)
            pause
        end
        if (hspillwayAtOverflowLevel(j) < h_End_optimization(j))
            msg = 'Depth at the end of the optimization cannot be above than spillway level in wetland. '; 
            error(msg)
            pause
        end        
        
        %Interpolation to find storage at a given wetland level  
        %This the initial storage 
        Initial_storage(j) = interp1(StaStorData(:,2), StaStorData(:,3), h_wet_init_depth(j)); 
        Initial_storage(j) = Initial_storage(j)*1000; %Conversion because Storage Data is in thousands of m3 
        
        %This the storage of the wetland at the ecological depth          
        Ecologicaldepth_storage(j) = interp1(StaStorData(:,2), StaStorData(:,3), hmin_ecological_depth(j)); 
        Ecologicaldepth_storage(j) = Ecologicaldepth_storage(j)*1000; %Conversion because Storage Data is in thousands of m3 
        
        %This the desired storage for each wetland at the end of the simulation        
        End_storage(j) = interp1(StaStorData(:,2), StaStorData(:,3), h_End_optimization(j)); 
        End_storage(j) = End_storage(j)*1000; %Conversion because Storage Data is in thousands of m3 
        
        %This the wetland storage at overflow level 
        StorageAtOverflowLevel(j) = interp1(StaStorData(:,2), StaStorData(:,3), hspillwayAtOverflowLevel(j)); 
        StorageAtOverflowLevel(j) = StorageAtOverflowLevel(j)*1000; %Conversion because Storage Data is in thousands of m3         
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Delete ALL Excel files
to_delete_direct = [path_general '\RAS_HMS_Original_project\' string_Home_folder_HMS '\']; 
cd(to_delete_direct);
delete *.xls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Delete Optimal_results_folder
 cd(path_general);
 !taskkill /im ras.exe  
 %This will kill all RAS running models
 to_delete_direct = [path_general '\Optimal_results'];
if( exist(to_delete_direct, 'dir')) 
    [status, message, messageid] = rmdir(to_delete_direct, 's');    
    if status == 0
        msg = 'Folder named ---Optimal_results---- cannot be deleted. Try to run again the matlab code. If you still have an error, please close matlab and delete the folder manually'; 
        error(msg)
    end
end

%mkdir('Optimal_results')% create folder named Optimal_results in current directory
if ~exist(to_delete_direct,'dir') mkdir('Optimal_results'); end
RAS_simul_ID = 1; %rasID_funct;  
%Delete RAS_HMS_folders
to_delete_direct = [path_general '\RAS_HMS_folders'];
if( exist(to_delete_direct, 'dir') )  
    [status, message, messageid] = rmdir(to_delete_direct, 's');    
    if status == 0
        msg = 'Folder named ---RAS_HMS_folders---- cannot be deleted. Try to run again the matlab code. If you still have an error, please close matlab and delete the RAS_folder manually'; 
        error(msg)
    end
end


%Copy file to the general file in RAS_HMS_folders
copyfile1 = [path_general '\RAS_HMS_Original_project'];
copyfile2 =  [path_general '\RAS_HMS_folders\' General_Name_of_Project];
status = copyfile(copyfile1, copyfile2);
if status == 0; %0 means copy was unsuccesful
    msg = 'Error occurred copying folders 0';
    error(msg)
    pause
end

%Here copy the Python files to the general HEC-HMS folder
temp_dir = [path_general '\utilitaries'];
cd(temp_dir); 
temp_string = [path_general '\RAS_HMS_folders\' General_Name_of_Project '\' string_Home_folder_HMS '\'];
status = copyfile('WetlandsDSSSaveExcel.py',temp_string);
if status == 0; %0 means copy was unsuccesful
    msg = 'Error occurred copying folders 2';
    error(msg)
    pause
end


%Change JAVA version to 11.0.6, version used in HEC-HMS 4.7.1
%[status,cmdout] = system('Java11.BAT') 

status = copyfile('WriteDss.py',temp_string);
if status == 0; %0 means copy was unsuccesful
    msg = 'Error occurred copying folders 33';
    error(msg)
    pause
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now we need to delete the Run_1.dss file from the main folder in \RAS_HMS_folders\ because this is for the original file. 
%Otherwise it will create problems 
temp_file = [path_general '\RAS_HMS_folders\' General_Name_of_Project '\' string_Home_folder_HMS '\Run_1.dss'];
if exist(temp_file, 'file')==2
    delete(temp_file); %Delete the file if it exists
    temp_file = [path_general '\RAS_HMS_folders\' General_Name_of_Project '\' string_Home_folder_HMS '\Run_1.log'];
    delete(temp_file);
    temp_file = [path_general '\RAS_HMS_folders\' General_Name_of_Project '\' string_Home_folder_HMS '\Run_1.dsc'];
    delete(temp_file);
    temp_file = [path_general '\RAS_HMS_folders\' General_Name_of_Project '\' string_Home_folder_HMS '\Run_1.out'];
    delete(temp_file);
end

%Delete wetland_mass_balance.xls
temp_file = [path_general '\RAS_HMS_folders\' General_Name_of_Project '\' string_Home_folder_HMS '\wetland_mass_balance.xls'];
if exist(temp_file, 'file')==2
    delete(temp_file); %Delete the file if it exists
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Check if HEC-HMS simulation is the same as Inflow_points_LATERAL_FROM_WETLANDS
cd(path_general)
filenameinput = [path_general '\RAS_HMS_Original_project\' ...
    string_Home_folder_HMS '\Control_1.control'];
BetweenTimes_HMS(filenameinput, 1)
if abs(Number_hours_simu_HECHMS -Inflow_points_LATERAL_FROM_WETLANDS) > 2
    msg = 'Simulation time of HEC-HMS is different from the number of optimization hours (e.g., Inflow_points_LATERAL_FROM_WETLANDS)' 
    error(msg) 
end

%Check if HEC-RAS simulation is the same as Inflow_points_LATERAL_FROM_WETLANDS
filenameinput = [path_general '\RAS_HMS_Original_project\' ...
    string_Home_folder_RAS '\' Name_of_RAS_project '.p01'];
BetweenTimes_HMS(filenameinput, 2)
if abs(Number_hours_simu_RAS -Inflow_points_LATERAL_FROM_WETLANDS) > 2
    msg = 'Simulation time of HEC-RAS is different from the number of optimization hours (e.g., Inflow_points_LATERAL_FROM_WETLANDS)' 
    error(msg) 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1 : number_of_cross_sections_constraints
  if Max_water_level_check_constraint(k) == 0; 
      msg = 'There is an error in the maximum water surface elevation for the cross-sections where the water level constraints are checked. Make sure that you are entering the water surface elevation at all cross-sections indicated for constraint check' 
    error(msg) 
  end
end  

%Enter below the maximum water surface elevation for the cross-sections
%where the water level constraint is checked. The order must be according
%to the data enetered above (e.g.,data_River_ID_objective,
%data_Node_ID_objective)
%data_Reach_ID_objective and 

%This is to delete existing DSS files in the Home folder
% Specify the folder where the files live.
newDirectoryName = [path_general '\RAS_HMS_folders\'];
myFolder = newDirectoryName;
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end

%This is to create the file Baxter_temp.u01
unsteady_input_temp = [Name_of_RAS_project '_temp.u01'];   
unsteady_input = [Name_of_RAS_project '.u01'];  
filenameinput = [path_general '\RAS_HMS_folders\' General_Name_of_Project '\' string_Home_folder_RAS '\' unsteady_input_temp];   
filenameoutput = [path_general '\RAS_HMS_folders\' General_Name_of_Project '\' string_Home_folder_RAS '\' unsteady_input];
status = copyfile (filenameoutput, filenameinput);
if status == 0; %0 means copy was unsuccesful
    msg = 'Error occurred copying folders 0';
    error(msg)
    pause
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Parallel computation
if UseVectorized == 1 | UseVectorized ==3         
        if Parallel_computing == 1
           delete(gcp('nocreate'));%To avoid interactive session error
           parpool('local',Number_of_processors_to_use_parallel_computing); %Parallel computationn
        end
end

%Enter 1 if you will use the pattern search approach for the optimization. If you will use GA enter any other number. 
Pop_Opt = max(Pop_Opt, Number_of_processors_to_use_parallel_computing);
if Pattern_search_Optimization == 1  %Pattern search approach
    Pop_Opt = max(Pop_Opt, 128);
    Number_of_RAS_folders_to_create = Pop_Opt;    
elseif Pattern_search_Optimization == 2  %Genetic algorithm
    Number_of_RAS_folders_to_create = Pop_Opt;
else
   msg = 'Optimization type not recognized.';
   error(msg);
   pause
end


cd(path_general); 
for j=1:Number_of_RAS_folders_to_create;
    StrID = num2str(j);  
    folderName = strcat(General_Name_of_Project,StrID); 
    newDirectoryName = [path_general '\RAS_HMS_folders\' folderName];
    %copy_Original_FolderName = ['RAS_HMS_folders\' General_Name_of_Project '\' string_Home_folder_RAS];    
    copy_Original_FolderName = ['RAS_HMS_folders\' General_Name_of_Project];    
    status = copyfile(copy_Original_FolderName,newDirectoryName);
    if status == 0; %0 means copy was unsuccesful
        msg = 'Error occurred copying folders 1';
        error(msg)
        pause
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Create Running_HMS.script in all RAS folders 
%for j = 1:Number_of_RAS_folders_to_create;       
%     StrID = num2str(j);
%     InputDSS_HMS=[path_general '\RAS_HMS_folders\' General_Name_of_Project ...
%         StrID '\' string_Home_folder_HMS ];
%     TextTemp = [ 'OpenProject ("' Name_of_HMS_project '", "' InputDSS_HMS '")'];   
%     %OutputRUN_HMS_temp = [InputDSS_HMS '\Running_HMS.script'];
%     Run_HMS(InputRUN_HMS, OutputRUN_HMS, TextTemp); 
%end

% for j = 1:Number_of_RAS_folders_to_create;       
%     StrID = num2str(j);
%     InputDSS_HMS=[path_general '\RAS_HMS_folders\' General_Name_of_Project ...
%         StrID '\' string_Home_folder_HMS ];
%     TextTemp = [ 'myProject = Project.open(' '''' InputDSS_HMS '\' Name_of_HMS_project '.hms' '''' ')'];   
%     
%     TextTemp = [ 'myProject = Project.open("' InputDSS_HMS '\' Name_of_HMS_project '.hms")'];   
%     OutputRUN_HMS_temp = [InputDSS_HMS '\HMScompute_current.py'];    
%     Run_HMS_Python(InputRUN_HMSPy, OutputRUN_HMS_temp, TextTemp); 
% end

%Copy HEC-HMS python script
filenameinput = InputRUN_HMSPy;   
filenameoutput = OutputRUN_HMSPy;
status = copyfile (filenameinput, filenameoutput);
if status == 0; %0 means copy was unsuccesful
    msg = 'Error occurred copying folders 0';
    error(msg)
    pause
end


%This is to copy the BAT file 
% for j = 1:Number_of_RAS_folders_to_create;       
%     StrID = num2str(j);        
%     filenameinput = [path_general '\utilitaries\compute_current_doNOTdelete.bat'];   
%     filenameoutput = [path_general '\RAS_HMS_folders\' General_Name_of_Project ...
%         StrID '\' string_Home_folder_HMS '\compute_current.bat'];
%     status = copyfile (filenameinput, filenameoutput);
%     if status == 0; %0 means copy was unsuccesful
%         msg = 'Error occurred copying folders 0';
%         error(msg)
%         pause
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(path_general);
%Wetland mass balance in original project
Input_temp = [path_general '\utilitaries\WetlandsDSSSaveExcel_doNOTdelete.py'];
Output_temp = [path_general '\RAS_HMS_Original_project\' string_Home_folder_HMS '\WetlandsDSSSaveExcel.py']; 
Text_Open_File = ['  dssFile = HecDss.open("' path_general '\RAS_HMS_Original_project\' ...
    string_Home_folder_HMS '\Run_1.dss")'];
Text_Save_File = ['table.createExcelFile(list, "' path_general '\RAS_HMS_Original_project\' ...
    string_Home_folder_HMS '\wetland_mass_balance.xls")'];
Write_Python_for_Weland_Mass_balance(Input_temp, Output_temp, Text_Open_File, Text_Save_File);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%genetic algorithm
Best_population_index = 0; %This is to know which population is the best one
%Maximum Numbers of simulations for hec-ras
for j=1:Number_of_RAS_folders_to_create;
     StrID_2 = num2str(j); 
     h{j} = StrID_2; 
end

rasID_funct = 1; %Genetic_Algorithm_file
gaAvailable = false;
nvar = NumberWetlands_managed*Inflow_points_LATERAL_FROM_WETLANDS;
Number_of_decision_variables = nvar;
nvar_RAS = sizeDSS*Inflow_points_LATERAL_FROM_WETLANDS;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%0 <= x1 <= 1, and          (bound)
%0 <= x2 <= 13              (bound)
%Change the limits of lower bound and upper bound
coeff_dry_wetland = zeros(Number_of_RAS_folders_to_create,nvar); % Coefficient for dry wetlands
initial_population_GA = zeros(1,nvar); %Initial population GA


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
StrID = num2str(1);
cd(path_DSSVue_executable); 
InputDSS = ['HEC-DSSVue.exe ' path_general '\RAS_HMS_Original_project\' string_Home_folder_HMS  '\WetlandsDSSSaveExcel.py'];
[status,cmdout] = system(InputDSS);
%Read data of Wetland Characteristics
filenameinput = [path_general '\RAS_HMS_Original_project\' string_Home_folder_HMS '\wetland_mass_balance.xls'];
sheet = 'sheet1';
Wet_data= xlsread(filenameinput,sheet); %Wet_data reads "numeric" data,string_wetlands reads "text" data

for kk = 1:NumberWetlands_managed          
        CumulativeInflow_temp = Wet_data(:, 2 + 1*NumberWetlands_managed + kk); %sum of total inflows
        Inflow_wetlands_for_constraint(kk,:) = CumulativeInflow_temp(1:Inflow_points_LATERAL_FROM_WETLANDS);  %sum of inflows before hydrograph starts
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Linear constraints
cd(path_general); 
%Linear_Constraints_Flood specifies LB, UB, Aeq and Beq
%Linear_Constraints_Flood;
Linear_Constraints_INITIAL_EMPTYING;
%pause
%initial_population_GA_final = rand*UB;

if Pattern_search_Optimization == 1 %use Pattern search optimization Method
    %Pattern Search SOLVER        
    x0 = zeros(1,nvar);
    x0 = 0.1*(UB-LB).*rand(1,nvar);

    iterlim = 1;
    level = Pop_Opt; %Check this later
    %Choose mesh size depending on the flow rate. In our case, the maxium
    %flow rate is about 5 m3/s. Thus, 'InitialMeshSize' is set to lower than 5, also, 
    %mesh tolerancem has to be much lower than maximum flow. ,
    
%     options = optimoptions(@patternsearch,'UseVectorized',true, ...
%         'UseParallel',false, 'UseCompletePoll',true, ...
%         'UseCompleteSearch',true, 'Display','iter', ...
%         'InitialMeshSize',20, ...
%         'MaxIterations', 100, ...
%         'MeshTolerance',0.10, 'FunctionTolerance',1e-4, ...
%         'PlotFcn',{@psplotbestf, @psplotfuncount,@psplotmeshsize,@psplotbestx});
    options = optimoptions(@patternsearch,'UseVectorized',true, ...
        'UseParallel',false, 'Display','iter', ...
        'InitialMeshSize',1, ...
        'MaxIterations', 100, ...
        'MeshTolerance',0.010, 'FunctionTolerance',1e-4, ...
        'PlotFcn',{@psplotbestf, @psplotfuncount,@psplotmeshsize,@psplotbestx});
    tic
    [x,fval] = patternsearch(@Fitness_vectorized_Pareto,x0,A,b,Aeq,beq,LB,UB,[],options);
    %[x,fval] = patternsearch(@Fitness_vectorized_Pareto,x0,[],[],[],[],LB,UB,[],options);
    toc  
elseif Pattern_search_Optimization == 2  %Genetic algorithm    
    gaoptions = optimoptions('ga', 'OutputFcn',@gaoutfun, ...
    'UseVectorized',true, 'PopulationSize',Pop_Opt, ...
    'MaxGenerations', MaxGenerations_GA, ...
    'MaxStallGenerations',MaxStallGenerations_SET_HERE, ...
    'FunctionTolerance',1e-3);                 
    gaoptions = optimoptions(gaoptions, 'PlotFcn',{@gaplotstopping, @gaplotbestindiv, @gaplotbestf},'Display','iter');  %This plots the mean and the best value of the objective function 
    %gaoptions.InitialPopulationMatrix = initial_population_GA_final; %Assigning initial_population_GA
    %do not setup any initial population
    tic
    [x fval, exitflag,output] = ga(@Fitness_vectorized_Pareto,nvar,A,b,Aeq,beq,LB,UB,[],gaoptions);
    %[x fval, exitflag,output] = ga(@Fitness_vectorized_Pareto,nvar,[],[],[],[],LB,UB,[],gaoptions);
    set(gca, 'YScale', 'log')
    toc
else 
    msg = 'Pattern_search_Optimization variable is not defined. Routine Main.m';
    error(msg)
    pause
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1 Without nonlinear constraints — The magnitude of the mesh size is less than the specified tolerance, and the constraint violation is less than ConstraintTolerance.
%With nonlinear constraints — The magnitude of the complementarity measure (defined after this table) is less than sqrt(ConstraintTolerance), 
%the subproblem is solved using a mesh finer than MeshTolerance, and the constraint violation is less than ConstraintTolerance.
%2 The change in x and the mesh size are both less than the specified tolerance, and the constraint violation is less than ConstraintTolerance.
%3 The change in fval and the mesh size are both less than the specified tolerance, and the constraint violation is less than ConstraintTolerance.
%4 The magnitude of the step is smaller than machine precision, and the constraint violation is less than ConstraintTolerance.
%0 The maximum number of function evaluations or iterations is reached.
%-1 Optimization terminated by an output function or plot function.
%-2 No feasible point found.

%Decision variables for populations with Best objective function and Best Objective Function
%Best_Decision_variables_for_pop_with_Best_Objective = x';
Best_objective_function = fval;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
!taskkill /im ras.exe
%Plot inflow, and optimized outflows and storage at managed wetlands for
% Plot best solution data
%The best solution is stored in file "1". If we need high quality plots, we
%can plot using HEC-DSSVue (Folder Cypress1). Here you can use Landscape
%plot to have a vector plot that can be 1200 or 2400 dpi.
%Best_population_index is found in routine Fitness_vectorized not in Main.
%When the simulation has problems, matlab gives the incorrect index. Thus.
%it is better to selct the correct solution in Fitness_vectorized. 
%Copy folder with optimized solution to "optimal solution" folder
cd(path_general);
StrID = num2str(Best_population_index);  
folderName = strcat(General_Name_of_Project,StrID); 
copy_Original_FolderName = [path_general '\RAS_HMS_folders\' folderName];
newDirectoryName = [path_general '\Optimal_results' ];    
status = copyfile(copy_Original_FolderName,newDirectoryName);
if status == 0; %0 means copy was unsuccesful
    msg = 'Error occurred copying folders 3';
    error(msg)
    pause
end
best_popu_index = Best_population_index
%size_col = size(x,2)
%x = zeros (1,size_col) %delete this
Best_Solution_Plot(x);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Match_decision_variables_and_plot_state_flow (x);
%hold off
time_hours_plot = 1:Number_of_decision_variables;

to_save_direct = [path_general '\Optimal_results'];
cd(to_save_direct)
saveas(gcf,'Optimzation_convergence.jpg')

figure;
plot(time_hours_plot,x)