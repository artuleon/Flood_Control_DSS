function Match_decision_variables_and_plot_state_flow(x);

global Number_dams
global Inflow_points_UPSTREAM_ENDS
global NLines_Out_wetlands
global Inflow_points_WETLANDS_to_WriteinFile
global NLines_Out_dam
global Number_inflow_hydrograph_UPSTREAM_ENDS_that_change
global string_Home_folder
global River_ID_target
global Reach_ID_target
global Node_ID_target
global Number_combined_wetlands
global Inflow_points_LATERAL_FROM_WETLANDS
global Array_of_wetland_flows
global Name_of_project 


RAS_simul_ID = 1; %rasID_funct;  
home_dir = pwd; %This returns the working directory.
StrID = num2str(RAS_simul_ID);  
folderName = strcat(string_Home_folder,StrID); 
newDirectoryName = [home_dir '\RAS_folders\' folderName];
ras_file{RAS_simul_ID} = [newDirectoryName '\' Name_of_project '.prj'];        
ras_inp{RAS_simul_ID} = [newDirectoryName '\' Name_of_project '_temp.u01'];        
ras_out{RAS_simul_ID} = [newDirectoryName '\' Name_of_project '.u01']; 
z9 = 'error message';    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Copy info to HEC-RAS files
    
%This is only temporal for dams and Upstream inflow hydrographs. If
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
    temp_array_main =  [0 x(posit_temp3:posit_temp4) Array_of_wetland_flows(Inflow_points_LATERAL_FROM_WETLANDS+2:Inflow_points_WETLANDS_to_WriteinFile)];    %we are adding a zero flow release for actual time     
    temp_array3 =  temp_array_main(1:1,1:pos_data)';    
    temp_array4 = temp_array_main(1:1,pos_data+1:Inflow_points_WETLANDS_to_WriteinFile);    
    Lateral_inflow_array_main_wetlands(:,:,j) = reshape(temp_array3, 10, [])';        
    Lateral_inflow_array_last_line_wetlands(1,:,j) = temp_array4'; %Transpose  
end
ChangeInlineStruct_Data(ras_inp{RAS_simul_ID},ras_out{RAS_simul_ID}, ...
Outflow_array_main_dams,Outflow_array_last_line_dams, ...
Inflow_array_main_UPSTREAM_ENDS,Inflow_array_last_line_UPSTREAM_ENDS, ...
Lateral_inflow_array_main_wetlands,Lateral_inflow_array_last_line_wetlands);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h{RAS_simul_ID}=actxserver('RAS505.HECRASController');
h{RAS_simul_ID}.Project_Open(ras_file{RAS_simul_ID}); %Open ras file
%h{RAS_simul_ID}.Compute_HideComputationWindow; %Hide Comput. Window
% h{RAS_simul_ID}.ShowRas; %Open ras file
h{RAS_simul_ID}.CurrentPlanFile;
 %h{RAS_simul_ID}.PlanOutput_SetCurrent(0); 
h{RAS_simul_ID}.Compute_ShowComputationWindow; %Show Comput. Window     
h{RAS_simul_ID}.Compute_CurrentPlan(0,0); %Run current plan  
wascomputationcompleted = 0; %Calculation was not completed yet. wascomputationcompleted = 1 wnen calculation is completed
while wascomputationcompleted == 0;
    %gggg = gggg+0.0000000000000001;
    wascomputationcompleted =  h{RAS_simul_ID}.Compute_Complete;
end

if wascomputationcompleted  == 1; %Simulation of entire population was completed    
        h{RAS_simul_ID}.PlotStageFlow(River_ID_target{1},Reach_ID_target{1}, ...
                    Node_ID_target{1}); %Plot stage and flow of cross-section that is the first constraint
end  
