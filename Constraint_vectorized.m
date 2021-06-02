function [c ceq] = Constraint_vectorized(x)
%EXPENSIVE_CONFUN An expensive constraint function used in optimparfor example.
%global RAS_simul_ID
%global number_rows_objective
global Inflow_points_LATERAL_FROM_WETLANDS
global NumberWetlands_managed

number_rows_objective = size(x,1);  
if number_rows_objective >=1
        N = Inflow_points_LATERAL_FROM_WETLANDS;
        ot = ones(N,1);
        H21 = zeros(N-1,N);
        Rows = 2*(N-1);
        Columns = 2*N;
        A1 = spdiags([ot -ot ],[0 1],N-1,N);
        A = [A1  H21; H21 -A1];
        b = 100; %20 cfs because this is constant we can substract this from the entire column %[b2; b2];
        P = NumberWetlands_managed*N; % number of individual matrices you have;
        Columns_eachWetland = Rows*NumberWetlands_managed;
        z = zeros(2*(N-1)*NumberWetlands_managed,2*P); % pre-allocate space
        xalloc = zeros(1,2*P); % pre-allocate space
        for k = 1:number_rows_objective
            for ii = 1:NumberWetlands_managed;
                row1 = (ii-1)*Rows;
                row2 = ii*Rows;
                col1 = (ii-1)*Columns;
                col2 = ii*Columns;
                z(row1+1:row2,col1+1:col2) = A; % Assign to the appropriate location
                xalloc(1,(ii-1)*N+1:ii*N) = x(k,(ii-1)*N+1:ii*N);
                xalloc(1,ii*N+1:(ii+1)*N) = x(k,(ii-1)*N+1:ii*N);
            end
            const = z*xalloc' - b;            
            c(k,:)=const';
            %c(k,:)=const';
        end
else 
    c = [];
end

% if number_rows_constr > number_rows_objective
%     number_rows_constr = number_rows_objective;
% end
%c = zeros(number_rows_objective,Inflow_points_LATERAL_FROM_WETLANDS*NumberWetlands_managed); % allocate output
%c = zeros(number_rows_objective,1); % allocate output

%coeff_dry_wetland = zeros(number_rows_objective,Inflow_points_LATERAL_FROM_WETLANDS*NumberWetlands_managed);
 
%Example:
% 10 - x1*x2 <=0,            (nonlinear constraint)
%In the code specify as: -x(1)*x(2) + 10

% for j = 1,number_rows_objective
%         %Read data of Wetland Characteristics
%         StrID = num2str(j);
%         filenameinput = [path_general '\RAS_HMS_folders\' General_Name_of_Project StrID '\' ...
%             string_Home_folder_HMS '\wetland_mass_balance' StrID '.xls'];
%         sheet = 'sheet1';        
%         Wet_data= xlsread(filenameinput,sheet); %Wet_data reads "numeric" data,string_wetlands reads "text" data
%         %Wet_data= xlsread(filenameinput,sheet,xlRange); %Wet_data reads "numeric" data,string_wetlands reads "text" data
%         
%         c(j) = 0.0
%         for kk = 1:NumberWetlands_managed  
%                 %Bassign = zeros(1,Inflow_points_LATERAL_FROM_WETLANDS);
%                 posit_temp3 = Inflow_points_LATERAL_FROM_WETLANDS*(kk-1)+1;
%                 posit_temp4 = Inflow_points_LATERAL_FROM_WETLANDS*kk;                 
%                 Initial_storage = Wet_data(1, 2 + 2*NumberWetlands_managed + kk);
%                 column_inflow=  2 + 1*NumberWetlands_managed + kk;
%                 inflow = Wet_data(1:Inflow_points_LATERAL_FROM_WETLANDS,column_inflow:column_inflow)';
%                 storage_time = Initial_storage + inflow - x(j,posit_temp3:posit_temp4)
%                 
%                 storage_time(storage_time < 10) = 1.0;
%                 storage_time(storage_time >= 10) = -0.0;
%                 
%                 %Bassign(storage_time(:) <= 0) = 1;
%                 %coeff_dry_wetland(j,posit_temp3:posit_temp4) = storage_time;
%                 c(j) = c(j) + storage_time*(transpose(x(j,posit_temp3:posit_temp4)).^2); %The power is element by element 
%                 
% %                 c(j,posit_temp3:posit_temp4) = storage_time.*x(j,posit_temp3:posit_temp4).^2; %This multiplies them element by element. 
% %                 aaaaa = c(j,posit_temp3:posit_temp4)
%                 %[status,cmdout] = system(command_for_running_HECDSSVue);
%         end
%         aaaaa = c(j)
% end

% if Pattern_search_Optimization == 1 %Pattern search is being used
%     for k = 1:number_rows_objective; %Wetlands 
%         aa = Maximum_Water_Stage_At_Station
%         bb = Max_water_level_check_constraint
%         c(k,1) = Maximum_Water_Stage_At_Station(k,1) - Max_water_level_check_constraint(1); 
%         c(k,2) = Maximum_Water_Stage_At_Station(k,2) - Max_water_level_check_constraint(2); 
%         c(k,3) = Maximum_Water_Stage_At_Station(k,3) - Max_water_level_check_constraint(3); 
%     end    
%     %Maximum_Water_Stage_At_Station = zeros(Pop_Opt,number_of_cross_sections_constraints);     
% else  %GA is being used
%     %alloc_water_sta = Maximum_Water_Stage_At_Station(1:number_rows_constr,:);
%     %c(:,1) = alloc_water_sta(:,1)*x(
% %     c(:,2) = alloc_water_sta(:,2) - Max_water_level_check_constraint(2); 
% %     c(:,3) = alloc_water_sta(:,3) - Max_water_level_check_constraint(3);
%     for j = 1, number_rows_objective
%         c(j,1) = coeff_dry_wetland(j,:)*x(j,:)'.^2;
%     end
% end
ceq = [];


