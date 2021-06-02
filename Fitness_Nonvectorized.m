function f = Fitness_Nonvectorized(x,...
path_general,General_Name_of_Project,string_Home_folder_HMS,...
NumberWetlands_managed,string_Home_folder_RAS,...
number_of_cross_sections_constraints,River_ID_target,Reach_ID_target, ...
Node_ID_target,Inflow_points_LATERAL_FROM_WETLANDS, ...
Max_water_level_check_constraint,Name_of_RAS_project, ...
command_for_running_HMS,Name_of_HMS_project, ...
PenaltyConstraintWaterLevelExceeded, ...
Name_of_DSSFile_for_Outflows_of_Wetland_with_active_control, Pop_Opt)
%global string_Home_folder_RAS
%global h
%global RAS_simul_ID
%global number_of_cross_sections_constraints
%global River_ID_target
%global Reach_ID_target
%global Node_ID_target
%global Inflow_points_LATERAL_FROM_WETLANDS
%global number_rows_objective
%global Max_water_level_check_constraint
%global Name_of_RAS_project 
%global path_HMS_executable
%global command_for_running_HMS
%global path_general
%global NumberWetlands_managed
%global string_Home_folder_HMS
% global InputWriteDSS 
% global OutputWriteDSS 
% global InputRUN_HMS
% global OutputRUN_HMS
% global path_DSSVue_executable
%global Name_of_HMS_project
%global General_Name_of_Project
% global penalty_function_below_threshold
%global PenaltyConstraintWaterLevelExceeded
%global Best_population_index
%global Name_of_DSSFile_for_Outflows_of_Wetland_with_active_control
global g_number
global AllocatedInteger
%global Pop_Opt 

%persistent_variables()
%global Pattern_search_Optimization
%cd(path_general)
[number_rows_objective number_of_columns] = size(x);
N = Inflow_points_LATERAL_FROM_WETLANDS;
%number_rows_objective = size(x,1)
HMS_simu_crashed = zeros(number_rows_objective,1); 
%ID_RAS_simulations = zeros(number_rows_objective,1);%To check which simulations need to be run
f = zeros(number_rows_objective, 1); %There is one single objective
calculate_squares_differences_constraints = zeros(number_rows_objective, 1); %There is one single objective
Large_Value_when_Fail = 10^16;
f = f+Large_Value_when_Fail; %This is to assign a large value to the objective function
calculate_squares_differences_constraints = calculate_squares_differences_constraints + Large_Value_when_Fail;
%coeff_dry_wetland = coeff_dry_wetland + Large_Value_when_Fail;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
generation_number = g_number %This is the generation number obtained from my custom function "gaoutfun"
%fprintf('The current generation is : %d \n', g_number);

%AllocatedInteger = AllocatedInteger + 1
AllocatedInteger = randperm(Pop_Opt,1) 
if AllocatedInteger > Pop_Opt
    AllocatedInteger = 1;
end
DimAllocatedInteger = zeros(1,Pop_Opt);
StrID = num2str(AllocatedInteger);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Writing HEC-DSS files
x(x==NaN) = 0.0; %Replace all NaN values (e.g., errors) with 0
x(x<=0.0) = 0.0; 
number_rows_objective_modif = 0;
jj = 1;
%sum_obj = 0;
while jj <= number_rows_objective
%for jj = 1:number_rows_objective         
        kk = 1;
        while kk <= NumberWetlands_managed
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %HEC-DSS Vue
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %cd(path_general);         
                InputDSS = [path_general '\RAS_HMS_folders\' General_Name_of_Project StrID '\' ...
                    string_Home_folder_HMS  '\' Name_of_DSSFile_for_Outflows_of_Wetland_with_active_control{kk} '.dss'];
                TextTemp = [ '    myDss = HecDss.open("' InputDSS '")'];
                posit_temp3 = N*(kk-1)+1;
                posit_temp4 = N*kk;  
                               
                flow_data = [0 x(jj,posit_temp3:posit_temp4)];    %we are adding a zero flow release for actual time         
                allOneString = sprintf('%.1f,' , flow_data);
                allOneString = allOneString(1:end-1); % strip final comma
                FlowsTemp = [ '    flows = [' allOneString ']'];
                %FlowsTemp = '    flows = [10,100,50,76.6,67.5,97.0,93.8,77.5,81.1,79.4,60.4,65.1,73.5]
                InputWriteDSS2 = [path_general '\RAS_HMS_folders\' General_Name_of_Project StrID '\' string_Home_folder_HMS '\WriteDss_doNOTdelete.py'];
                OutputWriteDSS2 = [' ' path_general '\RAS_HMS_folders\' General_Name_of_Project StrID '\' string_Home_folder_HMS '\WriteDss.py'];
                ChangeDSS_files(InputWriteDSS2, OutputWriteDSS2, TextTemp, FlowsTemp);                       
                %cd(path_DSSVue_executable); 
                %cd(C:\Program Files (x86)\HEC\HEC-DSSVue)
                PathVue = 'C:\Program Files (x86)\HEC\HEC-DSSVue';
                cd(PathVue);
                
                
                %PathVue = 'C:\Program Files (x86)\HEC\HEC-DSSVue\HEC-DSSVue.exe '
                %PathVue2 = convertCharsToStrings(PathVue)
                %string_temp = strcat('HEC-DSSVue.exe',{' '},OutputWriteDSS2)
                %string_temp = string(string_temp) 
                %strcat(s1,...,sN)
                %string_temp = [PathVue2 OutputWriteDSS2]
                string_temp = ['HEC-DSSVue.exe ' path_general '\utilitaries\WriteDss.py'];
                [status,cmdout] = system(string_temp);
                if status ~= 0
                    disp('Error HEC-DSSVue.exe. Fitness NonVectorized')
                    pause
                end                
                kk = kk + 1;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %HEC-HMS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %cd(path_general);
        InputDSS=[path_general '\RAS_HMS_folders\' General_Name_of_Project ...
            StrID '\' string_Home_folder_HMS ];
        TextTemp = [ 'OpenProject ("' Name_of_HMS_project '", "' InputDSS '")'];  
        InputRUN_HMS_NonVector = [path_general '\RAS_HMS_folders\' General_Name_of_Project StrID '\' string_Home_folder_HMS '\Running_HMS_temp_doNOTdelete.script'];
        OutputRUN_HMS_NonVector = [path_general '\RAS_HMS_folders\' General_Name_of_Project StrID '\' string_Home_folder_HMS '\Running_HMS.script'];
        %InputRUN_HMS_NonVector = [path_general '\utilitaries\Running_HMS_temp_doNOTdelete.script']
        %OutputRUN_HMS_NonVector = [path_general '\utilitaries\Running_HMS.script']; 
        Run_HMS(InputRUN_HMS_NonVector, OutputRUN_HMS_NonVector, TextTemp);   
        %cd(path_HMS_executable);  %Path of HMS executable 
        [status,cmdout] = dos(command_for_running_HMS);
        if status ~= 0
                folderName = strcat(General_Name_of_Project,StrID); 
                disp('Error HEC-HMS. Fitness vectorized')            
                disp_error = sprintf('The HEC-HMS File ID is %s',folderName);
                disp(disp_error) 
                HMS_simu_crashed(jj) = 1
                %f(jj) = Large_Value_when_Fail;
                %jj = jj-1 %This is to repeat the HEC-HMS simulation
                 DimAllocatedInteger(AllocatedInteger) = DimAllocatedInteger(AllocatedInteger) + 1;
                 if DimAllocatedInteger(AllocatedInteger )>2
                     DimAllocatedInteger(AllocatedInteger)=0;
                     f(jj) = Large_Value_when_Fail;
%                     pause
                 else
                     jj = jj-1; %This is to repeat the HEC-HMS simulation
                 end
                %If HEC-HMS didn't work copy entire folder
                %cd(path_general)
                newDirectoryName = [path_general '\RAS_HMS_folders\' folderName];            
                to_delete_direct = newDirectoryName;
                if( exist(to_delete_direct, 'dir')) 
                    [status, message, messageid] = rmdir(to_delete_direct, 's');    
                    if status == 0; %0 means delete was unsuccesful
                        msg = 'Folder named ---to_delete_direct in fitness vectorized---- cannot be deleted.'; 
                        error(msg)
                    end
                end            
                copy_Original_FolderName = [path_general '\RAS_HMS_folders\' General_Name_of_Project]    ;
                status = copyfile(copy_Original_FolderName,newDirectoryName);
                if status == 0; %0 means copy was unsuccesful
                    msg = 'Error occurred copying folders fitness non vectorized 22';
                    error(msg)
                    pause
                end
                
                %pause
        elseif  status == 0; %Status = 0 (successful run), status = 1 (aborted run). If aborted, don't run HEC-RAS
                number_rows_objective_modif = number_rows_objective_modif+1; 
                HMS_simu_crashed(jj) = 0;
        else
                msg = 'Unknown condition. Subr. fitness vectorized';
                error(msg)
                pause
        end          
        jj = jj+1;
end 


% msg = 'what is going on';
% error(msg)
% pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Access the water level in wetlands before hydrograph starts
%cd(path_DSSVue_executable);
z9 = 'error message';
kk = 1;
while kk <= number_rows_objective_modif
%for kk = 1:number_rows_objective_modif
            folderName = strcat(General_Name_of_Project,StrID); 
            newDirectoryName = [path_general '\RAS_HMS_folders\' folderName '\' string_Home_folder_RAS];        
            ras_file{kk} = [newDirectoryName '\' Name_of_RAS_project '.prj'];       
            kk = kk + 1;
end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % z9 = 'error message';
    % for kk = 1:number_rows_objective_modif
    %         jj = ID_RAS_simulations(kk);
    %         StrID = num2str(jj);  
    %         folderName = strcat(General_Name_of_Project,StrID); 
    %         newDirectoryName = [path_general '\RAS_HMS_folders\' folderName '\' string_Home_folder_RAS];        
    %         ras_file{kk} = [newDirectoryName '\' Name_of_RAS_project '.prj'];   
    % end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%penalty_high = ones(number_rows_objective_modif,number_of_cross_sections_constraints,number_of_columns)
if number_rows_objective_modif >= 1
    Objective_Results = zeros(number_rows_objective_modif, 1);    
    %parfor kk = 1:number_rows_objective_modif        
    for  kk = 1:number_rows_objective_modif
                Penal = zeros(1,number_of_columns);    
                h{kk}=actxserver('RAS507.HECRASController');
                %h{kk}=actxserver('RAS505.HECRASController');
                %h{kk}=actxserver('RAS503.HECRASController');
                %h{kk}=actxserver('RAS41.HECRASCONTROLLER');
                h{kk}.Project_Open(ras_file{kk}); %Open ras file
                h{kk}.Compute_HideComputationWindow; %Hide Comput. Window
                %h{kk}.Compute_ShowComputationWindow; %Show Comput. Window     
                % h{kk}.ShowRas; %Open ras file
                h{kk}.CurrentPlanFile;
                 %h{kk}.PlanOutput_SetCurrent(0); 
                h{kk}.Compute_CurrentPlan(0,0); %Run current plan  
                %wascomputationcompleted =  h{kk}.Compute_Complete;
                %h{kk}.Project_Save; %Saves the project
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %To check if last simulation was completed        
                wascomputationcompleted(kk) = 0; %Calculation was not completed yet. wascomputationcompleted = 1 wnen calculation is completed
                while wascomputationcompleted(kk) == 0;
                    %gggg = gggg+0.0000000000000001;
                    wascomputationcompleted(kk) =  h{kk}.Compute_Complete;
                end
                if wascomputationcompleted(kk) == 1; %Simulation of entire population was completed                      
                        %penalty_high = zeros(1,N+1);                        
                        for j = 1:number_of_cross_sections_constraints
                                %[z1,z2,z3,z4,z5,z6,z7,z8,z9] ...
                                %        = h{kk}.OutputDSS_GetStageFlow(River_ID_target{j},Reach_ID_target{j}, ...
                                %            Node_ID_target{j},0,0,0,0,z9);

                                [z1,z2,z3,z4,z5,z6,z7,z8,z9] ...
                                        = h{kk}.OutputDSS_GetStageFlow(River_ID_target{j},Reach_ID_target{j}, ...
                                            Node_ID_target{j},0,0,0,0,'error message');
                                %h{kk}.PlotStageFlow(River_ID_objective,Reach_ID_objective,Node_ID_objective);                                
                                z7(z7==NaN) = 10^5; %Replace all NaN values (e.g., errors) with extremely large values
                                z7(z7<=0) = 10^5; %Replace all negative values (e.g., errors) with extremely large values        
                                z7_high = z7(z7>Max_water_level_check_constraint(j));
                                z7_high_logic = (z7>Max_water_level_check_constraint(j));
                                z7_operation = (z7-Max_water_level_check_constraint(j)).^2.0;
                                penalty_high = 1. - PenaltyConstraintWaterLevelExceeded*z7_high_logic.*z7_operation; %This is element by element multiplication
                                ii = 1
                                while ii <= NumberWetlands_managed 
                                    col1 = (ii-1)*N;
                                    col2 = ii*N;
                                    %Penal(1,col1+1:col2) = penalty_high(1,2:N+1);
                                    Penal(1,col1+1:col2) = penalty_high(2:N+1);
                                    ii = ii + 1;
                                end 
                                %penalty_high_size = size(penalty_high)
                                %xsize = size(x(jj,:))
                                %z7_low_modif = z7;                                
                                %z7_low = z7(z7 < Max_water_level_check_constraint(j)-3.0); %we put a buffer of 3 feet where there is no penalty
                                %z7_low = z7_low_modif(z7_low_modif < Max_water_level_check_constraint(j)); %we put a buffer of 3 feet where there is no penalty
                                
                                %Maximum_Water_Stage_At_Station(kk,j)= max(z7); %Gets the maximum of water stage elevations at the cross section                                
                                %calculate_squares_differences_constraints(kk,j) = ...
                                %PenaltyConstraintWaterLevelExceeded*sum((z7_high - Max_water_level_check_constraint(j)).^2.0) 
                                %+ penalty_function_below_threshold*sum((z7_low - Max_water_level_check_constraint(j)).^2.0);                            
                        end                        
                        %delete(h{kk}) %Deletes the handle h{j} 
                end
                Objective_Results(kk) = -dot(x(1,:),Penal(1,:));                 
                %The sign is negative because we are minimizing
    end
    
    for kk = 1:number_rows_objective_modif 
        f(kk) = Objective_Results(kk);
        disp('everything goes well')
        disp('everything goes well')
        disp('everything goes well')
        disp('everything goes well')
    end   

    tic,
    sum_complete_comput = sum(wascomputationcompleted(:));
    while sum_complete_comput ~= number_rows_objective_modif;
        sum_complete_comput = sum(wascomputationcompleted(:));    
        if toc>5000
            disp(['done' num2str(toc)])
            msg = 'Iteration was taking long and hence was terminated';
            error(msg);
            pause 
        end
    end
    sum_complete_comput = sum(wascomputationcompleted(:));
    if sum_complete_comput ~= number_rows_objective_modif;
        msg = 'Computation was not terminated';
        error(msg);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    %We want to maximize sum of released flows without exceeding a maximum
    %maximizing sume of of released flows is equivalent to minimizing the
    %negative of the sum

    Effectivenumberofrows = number_rows_objective_modif 
    %f = x(1)^2+x(2)^2+x(3)^2+x(4)^2;  % Use semicolon at the end of the line not to print the fucntion        
    %f = -sum_total_flows;  % Use semicolon at the end of the line not to print the function   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%     for kk = 1:number_rows_objective_modif
%         jj = ID_RAS_simulations(kk);
%         sum_penalty = 0.0;
%         for j = 1:number_of_cross_sections_constraints;
%                 sum_penalty = sum_penalty + penalty_high(jj,j,:)*x(jj)'
%         end        
%         f(jj) = sum_penalty
        
%         sum_penalty = 0.0;
%         for j = 1:number_of_cross_sections_constraints;
%                 sum_penalty = sum_penalty + calculate_squares_differences_constraints(kk,j);
%         end  
%         jj = ID_RAS_simulations(kk);
%         f(jj) = sum_penalty - ...
%             sum(x(jj,:));
    %end
end
%To find the best objective function
f(isnan(f)) = Large_Value_when_Fail; %Replace NaN values with high values
minimum_function = min(f);
Best_population_index =find(f==minimum_function);
Best_population_index = Best_population_index(1);
Current_fitness_population = f;

!taskkill /im ras.exe 
%To kill all hec-ras
