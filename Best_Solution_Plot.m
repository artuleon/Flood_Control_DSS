%function f = expensive_objfun(x,rasID_funct);
function Best_Solution_Plot(x);
global string_Home_folder_RAS
global h
global Inflow_points_LATERAL_FROM_WETLANDS
global Name_of_RAS_project 
global path_HMS_executable
global command_for_running_HMS
global path_general
global NumberWetlands_managed
global string_Home_folder_HMS
global InputWriteDSS 
global OutputWriteDSS 
global InputRUN_HMS
global OutputRUN_HMS
global path_DSSVue_executable
global Name_of_HMS_project
global General_Name_of_Project
global Name_of_DSSFile_for_Outflows_of_Wetland_with_active_control
global Name_of_Wetlands_with_active_control
global Timing_for_WritingDatatoExcel_from_HMS
global Best_population_index

%aa125 = x
!taskkill /im ras.exe 
RAS_simul_ID = Best_population_index;
StrID = num2str(RAS_simul_ID);       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Writing HEC-DSS files
 for kk = 1:NumberWetlands_managed
        cd(path_general); 
        InputDSS = [path_general '\RAS_HMS_folders\' General_Name_of_Project StrID '\' ...
            string_Home_folder_HMS  '\' Name_of_DSSFile_for_Outflows_of_Wetland_with_active_control{kk} '.dss'];
        TextTemp = [ '    myDss = HecDss.open("' InputDSS '")'];
        posit_temp3 = Inflow_points_LATERAL_FROM_WETLANDS*(kk-1)+1;
        posit_temp4 = Inflow_points_LATERAL_FROM_WETLANDS*kk;                 
        flow_data = [0 x(posit_temp3:posit_temp4)];    %we are adding a zero flow release for actual time 
        flow_data =  movmean(flow_data,6); %Moving average of flow_data (6 hours)
        allOneString = sprintf('%.1f,' , flow_data);
        allOneString = allOneString(1:end-1); % strip final comma
        FlowsTemp = [ '    flows = [' allOneString ']'];
        ChangeDSS_files(InputWriteDSS, OutputWriteDSS, TextTemp, FlowsTemp);                       
        cd(path_DSSVue_executable);        
        string_temp = ['HEC-DSSVue.exe ' path_general '\utilitaries\WriteDss.py'];
        [status,cmdout] = system(string_temp);
 end
%  
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Hydrological Modeling
cd(path_general);
InputDSS = [path_general '\RAS_HMS_folders\' General_Name_of_Project StrID '\' string_Home_folder_HMS ];
TextTemp = [ 'OpenProject ("' Name_of_HMS_project '", "' InputDSS '")'];    
Run_HMS(InputRUN_HMS, OutputRUN_HMS, TextTemp);    
cd(path_HMS_executable);  %Path of HMS execuable 
command_for_running_HMS = ['hec-hms.cmd -s ' OutputRUN_HMS];
[status,cmdout] = system(command_for_running_HMS);  

if  status == 0; %Status = 0 (successful run), status = 1 (aborted run). If aborted, don't run HEC-RAS
        disp('Writing results for Best Solution');
else
        msg = 'HEC-HMS was not succesful in Best_Solution_Plot. ';  
        error(msg)
        pause   
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot optimal solutions for wetlands
for kk = 1:NumberWetlands_managed
        Input_temp = [path_general '\utilitaries\Plot_optim_flow_storage_wetlands_doNOTdelete.py'];
        Output_temp = [path_general '\utilitaries\Plot_optim_flow_storage_wetlands.py'];         
       
        Text_Open_File = [path_general '\RAS_HMS_folders\' General_Name_of_Project StrID '\' ...
            string_Home_folder_HMS  '\Run_1.dss'];
        Text_Open_File = [ '    dssFile = HecDss.open("' Text_Open_File '")'];
        
        
        Text_Save_FileJPEG = [ 'plot.saveToJpeg("' path_general '\Optimal_results\' Name_of_Wetlands_with_active_control{kk} '", 100)'];  
        %Text_Save_FilePS = [ 'plot.saveToPostscript("' path_general '\Optimal_results\' Name_of_Wetlands_with_active_control{kk} '")'];  
        %Text_Save_FileWMF = [ 'plot.saveToMetafile("' path_general '\Optimal_results\' Name_of_Wetlands_with_active_control{kk} '")'];  
        %Text_Save_File = [ 'plot.saveToPostscript("' path_general '\Optimal_results\' Name_of_Wetlands_with_active_control{kk} '")'];  
        %The range is from 0 to 100. The higher the value, the better quality. Not adding a number is equivalent to 75
                
        ElevTemp = [ '    elev = dssFile.get("//' Name_of_Wetlands_with_active_control{kk} ...
            '/ELEVATION' Timing_for_WritingDatatoExcel_from_HMS '")'];    
        
        Total_outflow = [ '    TotalOutflow = dssFile.get("//' Name_of_Wetlands_with_active_control{kk} ...
            '/FLOW' Timing_for_WritingDatatoExcel_from_HMS '")'];           
        
        InflowTemp = [ '    inflow = dssFile.get("//' Name_of_Wetlands_with_active_control{kk} ...
            '/FLOW-COMBINE' Timing_for_WritingDatatoExcel_from_HMS '")'];   
        
        StorTemp = [ '    stora = dssFile.get("//' Name_of_Wetlands_with_active_control{kk} ...
            '/STORAGE' Timing_for_WritingDatatoExcel_from_HMS '")'];    
        
        Opti_ReleaseTemp = [ '    OptimRelease = dssFile.get("//' Name_of_Wetlands_with_active_control{kk} ...
            '-RELEASE/FLOW' Timing_for_WritingDatatoExcel_from_HMS '")'];    
        
        SpillFlowTemp = [ '    Spill = dssFile.get("//' Name_of_Wetlands_with_active_control{kk} ...
            '-SPILL-1/FLOW' Timing_for_WritingDatatoExcel_from_HMS '")'];    
        
        Name_Wetland_plot = [ 'plot.setPlotTitleText("Wetland ' Name_of_Wetlands_with_active_control{kk} '")'];  
        
        %Write JPEG files
        cd(path_general)
        Write_Python_for_Plot_Opt_Wetl_variables(Input_temp, Output_temp, ElevTemp, Total_outflow, ...
           InflowTemp, StorTemp, Opti_ReleaseTemp,  SpillFlowTemp, Name_Wetland_plot, Text_Open_File, Text_Save_FileJPEG);
        cd(path_DSSVue_executable);     
        string_temp = ['HEC-DSSVue.exe ' path_general '\utilitaries\Plot_optim_flow_storage_wetlands.py'];
        [status,cmdout] = system(string_temp);
        
        %Write PS files
%         cd(path_general)
%         Write_Python_for_Plot_Opt_Wetl_variables(Input_temp, Output_temp, ElevTemp, Total_outflow, ...
%            InflowTemp, StorTemp, Opti_ReleaseTemp,  SpillFlowTemp, Name_Wetland_plot, Text_Open_File, Text_Save_FilePS);
%                 cd(path_DSSVue_executable);     
%         string_temp = ['HEC-DSSVue.exe ' path_general '\utilitaries\Plot_optim_flow_storage_wetlands.py'];
%         [status,cmdout] = system(string_temp);
        
        %Write Windows metafile
%         cd(path_general)
%         Write_Python_for_Plot_Opt_Wetl_variables(Input_temp, Output_temp, ElevTemp, Total_outflow, ...
%            InflowTemp, StorTemp, Opti_ReleaseTemp,  SpillFlowTemp, Name_Wetland_plot, Text_Open_File, Text_Save_FileWMF);
%         cd(path_DSSVue_executable);     
%         string_temp = ['HEC-DSSVue.exe ' path_general '\utilitaries\Plot_optim_flow_storage_wetlands.py'];
%         [status,cmdout] = system(string_temp);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Convert PS to PDF
%InputDSS = [path_general '\Optimal_results'];
%cd(path_general);
% for kk = 1:NumberWetlands_managed
%     Name_Wetland_plotPS = [ path_general '\Optimal_results\' Name_of_Wetlands_with_active_control{kk} '.ps'];  
%     Name_Wetland_plotPDF = [ path_general '\Optimal_results\' Name_of_Wetlands_with_active_control{kk} '.pdf'];  
%     ps2pdf('psfile', Name_Wetland_plotPS, 'pdffile', Name_Wetland_plotPDF, 'gspapersize', 'letter', 'deletepsfile', 1)
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This is to create a copy of the plan file .p01
cd(path_general);
folderName = strcat(General_Name_of_Project,StrID); 
newDirectoryName = [path_general '\RAS_HMS_folders\' folderName '\' string_Home_folder_RAS];
unsteady_input_temp = [Name_of_RAS_project '_temp.p01'];   
unsteady_input = [Name_of_RAS_project '.p01'];  
filenameinput = [newDirectoryName '\' unsteady_input_temp];   
filenameoutput = [newDirectoryName '\' unsteady_input];
copyfile (filenameoutput, filenameinput);
ActivateGeometry_HEC_RAS(filenameinput,filenameoutput)    
ras_file{RAS_simul_ID} = [newDirectoryName '\' Name_of_RAS_project '.prj'];   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%h{RAS_simul_ID}=actxserver('RAS505.HECRASController');
h{RAS_simul_ID}=actxserver('RAS507.HECRASController');
h{RAS_simul_ID}.Project_Open(ras_file{RAS_simul_ID}); %Open ras file
%h{RAS_simul_ID}.Compute_HideComputationWindow; %Hide Comput. Window
h{RAS_simul_ID}.Compute_ShowComputationWindow; %Show Comput. Window     
h{RAS_simul_ID}.ShowRas; %Open ras file
h{RAS_simul_ID}.CurrentPlanFile;
%h{RAS_simul_ID}.PlanOutput_SetCurrent(0); 
h{RAS_simul_ID}.Compute_CurrentPlan(0,0); %Run current plan  
%wascomputationcompleted =  h{RAS_simul_ID}.Compute_Complete;
h{RAS_simul_ID}.Project_Save; %Saves the project

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

%!taskkill /im ras.exe 
%To kill all hec-ras
