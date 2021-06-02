function f1 = Fitness_Constr_Non_vectorized(x);
global NLines_Out_wetlands 
global Number_combined_wetlands
global Inflow_points_WETLANDS_to_WriteinFile
global string_Home_folder_RAS
global Maximum_Water_Stage_At_Station
global h
global RAS_simul_ID
global number_of_cross_sections_constraints
global River_ID_target
global Reach_ID_target
global Node_ID_target
global Array_of_wetland_flows
global Inflow_points_LATERAL_FROM_WETLANDS
global counter_non_vect_kill_RAS
global Max_water_level_check_constraint
global Number_of_decision_variables
global Name_of_project 


number_rows_objective = size(x,1);
if number_rows_objective ~= 1
        msg = 'Number of rows for objective is not 1. Fitness_Non_vectorized ';      
        error(msg)
end
%number_rows_objective = max(1,number_rows_objective)
f1 = zeros(number_rows_objective, 1); %There is one single objective
c1 =  zeros(number_rows_objective, 3); %There is one single objective

Maximum_Water_Stage_At_Station = zeros(number_rows_objective,number_of_cross_sections_constraints);

% z6 = zeros(5000); %There is one single objective
% z7 = zeros(5000); %There is one single objective
% z8 = zeros(5000); %There is one single objective
% z9 = zeros(5000); %There is one single objective
% zzz3 = zeros(5000); %There is one single objective
% zzz4 = zeros(5000); %There is one single objective

%Maximum_Water_Stage_At_Station = zeros(Pop_Opt,number_of_cross_sections_constraints); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

home_dir = pwd; %This returns the working directory.
for RAS_simul_ID = 1:number_rows_objective 
        StrID = num2str(RAS_simul_ID);  
        folderName = strcat(string_Home_folder_RAS,StrID); 
        newDirectoryName = [home_dir '\RAS_HMS_folders\' folderName];        
        ras_file{RAS_simul_ID} = [newDirectoryName '\' Name_of_project '.prj'];        
        ras_inp{RAS_simul_ID} = [newDirectoryName '\' Name_of_project '_temp.u01'];        
        ras_out{RAS_simul_ID} = [newDirectoryName '\' Name_of_project '.u01'];         
        z9 = 'error message';    
        
        %Copy info to HEC-RAS files. This is only temporal for dams and Upstream inflow hydrographs. If
        %dams and inflow hydrographs are changing, we need to do something
        %similar to what has been done for wetlands
        Outflow_array_main_dams = zeros(10,1);
        Outflow_array_last_line_dams = zeros(10,1);
        Inflow_array_main_UPSTREAM_ENDS = zeros(10,1);
        Inflow_array_last_line_UPSTREAM_ENDS = zeros(10,1); 
        
        pos_data = 10*(NLines_Out_wetlands-1);   
        for j = 1:Number_combined_wetlands; %Wetlands 
            posit_temp3 = Inflow_points_LATERAL_FROM_WETLANDS*(j-1)+1;
            posit_temp4 = Inflow_points_LATERAL_FROM_WETLANDS*j;
           
            temp_array_main =  [0 x(RAS_simul_ID,posit_temp3:posit_temp4) Array_of_wetland_flows(Inflow_points_LATERAL_FROM_WETLANDS+2:Inflow_points_WETLANDS_to_WriteinFile)];    %we are adding a zero flow release for actual time     
            temp_array3 =  temp_array_main(1:1,1:pos_data)';    
            temp_array4 = temp_array_main(1:1,pos_data+1:Inflow_points_WETLANDS_to_WriteinFile);    
            Lateral_inflow_array_main_wetlands(:,:,j) = reshape(temp_array3, 10, [])';        
            Lateral_inflow_array_last_line_wetlands(1,:,j) = temp_array4'; %Transpose  
        end
        ChangeInlineStruct_Data(ras_inp{RAS_simul_ID},ras_out{RAS_simul_ID}, ...
        Outflow_array_main_dams,Outflow_array_last_line_dams, ...
        Inflow_array_main_UPSTREAM_ENDS,Inflow_array_last_line_UPSTREAM_ENDS, ...
        Lateral_inflow_array_main_wetlands,Lateral_inflow_array_last_line_wetlands);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for RAS_simul_ID = 1:number_rows_objective
        %h{RAS_simul_ID}=actxserver('RAS503.HECRASController');   
         h{RAS_simul_ID}=actxserver('RAS503.HECRASCONTROLLER');   
        
        %h{RAS_simul_ID}=actxserver('RAS41.HECRASCONTROLLER');
        h{RAS_simul_ID}.Project_Open(ras_file{RAS_simul_ID}); %Open ras file
        h{RAS_simul_ID}.Compute_HideComputationWindow; %Hide Comput. Window
        %h{RAS_simul_ID}.Compute_ShowComputationWindow; %Show Comput. Window     
        % h{RAS_simul_ID}.ShowRas; %Open ras file
        h{RAS_simul_ID}.CurrentPlanFile;
         %h{RAS_simul_ID}.PlanOutput_SetCurrent(0); 
        h{RAS_simul_ID}.Compute_CurrentPlan(0,0); %Run current plan  
        %wascomputationcompleted =  h{RAS_simul_ID}.Compute_Complete;
        %h{RAS_simul_ID}.Project_Save; %Saves the project
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %To check if last simulation was completed        
        wascomputationcompleted(RAS_simul_ID) = 0; %Calculation was not completed yet. wascomputationcompleted = 1 wnen calculation is completed       
        startTime_nonVector = tic;        
        while wascomputationcompleted(RAS_simul_ID) == 0;               
                %use tic toc to see if computation is completed
                time_RAS_Non_Vectorized = toc(startTime_nonVector);
                if time_RAS_Non_Vectorized > 100
                        disp ('Warning: RAS simulation was not completed in 100 sec')
                        msg = 'The simulationof HEC-RAS exceeded 100 seconds. Function Fitness_Non_vectorized'                     
                        error(msg) 
                end                        
                wascomputationcompleted(RAS_simul_ID) =  h{RAS_simul_ID}.Compute_Complete;          
        end
        
        if wascomputationcompleted(RAS_simul_ID) == 1; %Simulation of entire population was completed    
                 for j = 1:number_of_cross_sections_constraints
                        [z1,z2,z3,z4,z5,z6,z7,z8,z9] ...
                               = h{RAS_simul_ID}.OutputDSS_GetStageFlow(River_ID_target{j},Reach_ID_target{j}, ...
                                   Node_ID_target{j},0,0,0,0,'error message');


% data_River_ID_objective = ['Cypress Creek   ';'Cypress Creek   ';'Cypress Creek   '];
% data_Reach_ID_objective = ['Lower Reach';'Lower Reach';'Lower Reach'];   
% data_Node_ID_objective = ['42006.23';'42006.23';'42006.23'];

% [z1,z2,z3,z4,z5,z6,z7,z8,z9] ...
%                                = h{RAS_simul_ID}.OutputDSS_GetStageFlow('Cypress Creek','Upper reach','97492.05',0,0,0,0,'error message');                               


%                                [z1,z2,z3,z4,z5,z6,z7,z8,z9] ...
%                                = h{RAS_simul_ID}.OutputDSS_GetStageFlow(River_ID_target{j},Reach_ID_target{j}, ...
%                                    Node_ID_target{j},0,0,0,0, 'error message');
                               
%                                [z1,z2,z3,z4,z5,z6,z7,z8,z9] ...
%                                = h{RAS_simul_ID}.OutputDSS_GetStageFlow(River_ID_target{j},Reach_ID_target{j}, ...
%                                    Node_ID_target{j},0,0,0,0,'error');
%                                
%                                aaa25 = h{RAS_simul_ID}.Output_NodeOutput(River_ID_target{j},Reach_ID_target{j}, ...
%                                    Node_ID_target{j},2,1,2)
                               
                               %h.Output_NodeOutput(riverID,reachID,nodeIDs,updn,profile,nVar); 
                                
%                                 [z1,z2,z3,z4,z5,z6,z7,z8,z9] ...
%                                 = h{RAS_simul_ID}.OutputDSS_GetStageFlow('Cypress Creek','Lower Reach', ...
%                                     '42006.230',0,0,0,0,'error message');
                                
                                
%                                 
% mmmmmmmmm = RAS_simul_ID

% bbbb1 = z1
% bbbb2 = z2
% bbbb3 = z3
% bbbb4 = z4
% bbbb5 = z5
% bbbb6 = z6
                                bbbb7 = z7
%                                 bbbb8= z8
%                                 bbbb9=z9
%                                 error('dbhwdjhwcdj')
                        %h{RAS_simul_ID}.PlotStageFlow(River_ID_objective,Reach_ID_objective, ...
                        %                    Node_ID_objective);                       
                        z7(z7<=0) = 10^10; %Replace all negative values (e.g., errors) with extremely large values        
                        z7(z7==NaN) = 10^10; %Replace all negative values (e.g., errors) with extremely large values        
                        Maximum_Water_Stage_At_Station(RAS_simul_ID,j)= max(z7); %Gets the maximum of water stage elevations at the cross section            
                        
%                         aaaa8 = Maximum_Water_Stage_At_Station(RAS_simul_ID,j)
                 end
                 delete(h{RAS_simul_ID}) %Deletes the handle h{j} 
        end
end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

%We want to maximize sum of released flows without exceeding a maximum
%maximizing sume of of released flows is equivalent to minimizing the
%negative of the sum

%f1 = x(1)^2+x(2)^2+x(3)^2+x(4)^2;  % Use semicolon at the end of the line not to print the fucntion        
%f1 = -sum_total_flows;  % Use semicolon at the end of the line not to print the function   


penalty_function = 100.0; 
for k = 1:number_rows_objective;
	sum_temp = sum(x(k,:));
   f1(k,1) = -sum_temp/Number_of_decision_variables;
    %xvalues = x;
    
    
    
    
    sum_penalty = 0.0;
    for j = 1:number_of_cross_sections_constraints
        if Maximum_Water_Stage_At_Station(k,j) > Max_water_level_check_constraint(j);
            
%             aaa1 = Maximum_Water_Stage_At_Station(k,j)
%             aaa2 = Max_water_level_check_constraint(j)
            sum_penalty = sum_penalty + penalty_function*(Maximum_Water_Stage_At_Station(k,j)-Max_water_level_check_constraint(j))^2.0       
        end
    end
        
       f1(k,1) = f1(k,1) + sum_penalty;

%       c1(k,1) = Maximum_Water_Stage_At_Station(k,1) - Max_water_level_check_constraint(1)
%       c1(k,2) = Maximum_Water_Stage_At_Station(k,2) - Max_water_level_check_constraint(2)
%       c1(k,3) = Maximum_Water_Stage_At_Station(k,3) - Max_water_level_check_constraint(3)
%     
% %     c1(k,1) = 0;
% %     c1(k,2) =0;
% %     c1(k,3) = 0;



%         c1(k,1) = Maximum_Water_Stage_At_Station(k,1) - Max_water_level_check_constraint(1);
%         c1(k,2) = Maximum_Water_Stage_At_Station(k,2) - Max_water_level_check_constraint(2);
%         c1(k,3) = Maximum_Water_Stage_At_Station(k,3) - Max_water_level_check_constraint(3);

end
%c1 = [];
%ceq1 = []; %Equality constraints

counter_non_vect_kill_RAS = counter_non_vect_kill_RAS + number_rows_objective;
if counter_non_vect_kill_RAS > 10; %Kill RAS when counter exceeds 5 simulations
    counter_non_vect_kill_RAS = 0;
        !taskkill /im ras.exe 
        %To kill all hec-ras
end

end %End of function


