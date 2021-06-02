%function obj=Wetlands_system_culverts(number_pipes,~) 
%function obj=Wetlands_system_culverts(3,~) 
clear all;
close all;
Siphon_or_Downward_drainage = 0; % Enter 1 if the drainage pipe is downward using sluices. Enter any other number if siphons are used. 
simulation_wetlands = 2 %1 is for simulation of wetlands only; 2 is for optimization 
kinem_viscos = 10^(-5); %ft2/s           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Enter data here (English units)
%NW = Number of Combined Wetlands connected to a single drain
%NSW = Number of SubWetlands for a Combined Wetland
%Read data of wetlands 
%If search is completed set Done_search= 1
home_dir = pwd; %This returns the working directory.
filenameinput = [home_dir '\Wetland_data\Wetland_network.txt'];
fid = fopen (filenameinput, 'rt'); %Open file for reading  
if fid == -1
  error('Author:Function:OpenFile', 'Cannot open file: %s', filenameinput);
end

j = 0;
while ~feof(fid);     
        strTextLine = fgetl(fid); %To read one additional line;    
        if strfind(strTextLine,'Combined'); 
            i = 0;
            j = j+1;
            %NewstrTextLine = fgetl(fid); %To read one additional line
            %if strfind(NewstrTextLine,'Lateral Inflow Hydrograph='); 
            status = feof(fid);
            if status ==1 %End of file has been arrived
                msg = 'There is no data of wetland for last wetland in file';
                disp(strTextLine)          
                error(msg);                    
            end 
        else
            i = i + 1;             
            temp_vector = sscanf(strTextLine,'%f, %f, %f');
            A_wet_original(j,i,1) =  temp_vector(1); 
            A_wet_original(j,i,2) =  temp_vector(2); 
            A_wet_original(j,i,3) =  temp_vector(3); 
            travel_time(temp_vector(1)) = temp_vector(3);
            NSW(j) = i;
        end        
end
fclose (fid); %Close the text file
NW = j;
total_number_wetlands = sum(NSW(:));
Awet = zeros(total_number_wetlands,1);   
d = zeros(total_number_wetlands,1);  
n_pipe = zeros(total_number_wetlands,1);  
L = zeros(total_number_wetlands,1);    
hmax_depth = zeros(total_number_wetlands,1);    
h_wet_init_depth = zeros(total_number_wetlands,1);    
LS = zeros(total_number_wetlands,1);    
downst = zeros(total_number_wetlands,1);    
ke = zeros(total_number_wetlands,1);    
n = zeros(total_number_wetlands,1);   
h = zeros(total_number_wetlands,1); 
hc = zeros(total_number_wetlands,1); 
K_Local_Losses = zeros(total_number_wetlands,1);   
Epsilon_friction = zeros(total_number_wetlands,1); 
Epsilon_D = zeros(total_number_wetlands,1);  
Q_arrived_at_wetland = zeros(total_number_wetlands,1); 
temp_sumQ_each_wetland = zeros(total_number_wetlands,1);   
Number_inflows_each_wetland = zeros(total_number_wetlands,1);  
Qmax_optimiz = zeros(total_number_wetlands,1); 

[number_wetlands2,max_number_subwetlands]=size(A_wet_original(:,:,1));
IDWetlands = zeros(NW,max_number_subwetlands);
for j = 1:NW;   
    if NSW(j)==1;
       IDWetlands(j,1) = A_wet_original(j,1,1);
    else %Combined wetland has several sub-wetlands
        tempA_wet = A_wet_original(j,:,1);
        tempB_wet = A_wet_original(j,:,2);
        i = 0;
        done_search = 0;
        low_range = 1;
        while done_search == 0;
            %Find the values in A that are not in B.
            [C,ia] = setdiff(tempA_wet,tempB_wet);            
            [rownum,colnum]=size(C);
             highrange = low_range+colnum-1;
             IDWetlands(j,low_range:highrange) = C;
             low_range = highrange+1;
             for k = 1:colnum;
                 tempA_wet(ia(k)) = -1;
                 tempB_wet(ia(k)) = -1;    
             end
             if all(tempA_wet < 0);
                done_search =1;
             end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ID_hydro = zeros(NW,max_number_subwetlands,max_number_subwetlands);
for j = 1:NW; 
    if NSW(j)==1;
        jj = IDWetlands(j,1); %%% This is the ID. It should look for this. It it not found. 
        %IDWetlands(j,1) = A_wet_original(j,1,1);
        ID_hydro(j,1,1) = -1;
		Number_inflows_each_wetland(jj) = 0;
        %travel_time(jj) = A_wet_original(j,1,3);
    else
            for k = 1:NSW(j)                    
                    jj = IDWetlands(j,k); %%% This is the ID. It should look for this. It it not found. 
                    %travel_time(jj) = A_wet_original(j,k,3);
                    %ID_hydro(j,k,1) = IDWetlands(j,k);
                    %Then it should imply that there is no inflows connected to the
                    %wetland. Otherwise, search in the matrix for those inflows            
                    %tempB_wet = A_wet_original(j,k,2)
                    ii = 0;
                    for kk = 1:NSW(j)
                            if jj == A_wet_original(j,kk,2);
                                ii = ii+1;
                                ID_hydro(j,k,ii) = A_wet_original(j,kk,1);         
                                A_wet_original(j,kk,:) = -1; 
                                Number_inflows_each_wetland(jj) = ii; 
                                %travel_time(jj) =  Complete_travel_time  %this must be related to ID_hydro and perhaps no
                            end
                    end
            end
    end
end

%Read data of Wetland Characteristics
filenameinput = [home_dir '\Wetland_data\WetlCharactSiphonDownw_Drain.xlsx'];
sheet = 'Wetland_characteristics';
xlRange = ['A5:K' num2str(total_number_wetlands + 4)];
Wet_data = xlsread(filenameinput,sheet,xlRange);

%Read data of Inflow Hydrographs
filenameinput = [home_dir '\Wetland_data\Wetland_Inflow_hydrographs.xlsx'];
sheet = 'Wetland_hydrographs';
temp_data = xlsread(filenameinput,sheet);
hydrograph_data = temp_data(2:end,2:end);
[rowhydro,colhydro]=size(hydrograph_data);  

g = 32.2;
TW = 0.0;
%Drainage time for 95% of the water volume  
drainage_time_input = 48; %In hours 
% drainage_time = 3; %Drainage time in hours
depth_Sediments=0.492; %This is the water depth in feet from the bottom of the wetland until the invert of the 5-way intake %Note that 0.15 m = 0.492 ft
Dt = 900; %Deta time in seconds
%diameter_pipes=[diameter_pipes_max diameter_pipes_max diameter_pipes_max diameter_pipes_max]; %Diameter in inches

[rownum,colnum]=size(Wet_data);
test_ID = find(IDWetlands(:,:) > rownum);
if any(test_ID > 0);
        msg = 'The IDs in the File Wetland_network.txt exceeds the number of wetlands. Please correct this. '    
        msg = 'make sure that the wetlands IDs are 1, 2, 3, in any order but the IDs should not exceed the number of wetlands';    
        error(msg)
end

if colhydro ~= rownum
        msg = 'The number of columns in the wetland_hydrograph.csv file should be the same as the number of wetlands. '
        msg = 'The hydrographs data should be in ascending order, e.g., 1, 2, 3, ....'        
        error(msg)
end

%check if data of IdNumber in File Weland_Characteristics.txt is in ascending order
for j = 1:rownum;   
    if Wet_data(j,1) ~= j;
        msg = 'There is an error in data of Wetland characteristics. Make sure that the number of wetlands is the same as the number of rown in the wetland file'    
        msg = 'The Wetland IDs need to be named in numbers and in ascending order: example: 1, 2, 3, 4, 5, 6, ...';    
        error(msg)
    end
end

max_sub_wetlands = max(NSW(:));
for j = 1:total_number_wetlands;          
        Awet(j) = Wet_data(j,2)+0.00000001; %Wetland Area in acres %%%%+0.00000001 is added to make the numbers real
        d(j) = Wet_data(j,3)+0.00000001; %Diameter in inches        
        n_pipe(j)= Wet_data(j,4)+0.00000001;  %This is the number of drainage pipes at each wetland  
        L(j) = Wet_data(j,5)+0.00000001; %Length of pipes in feet 
        hmax_depth(j) = Wet_data(j,6)+0.00000001; %Maximum water depth in wetland
        h_wet_init_depth(j) = Wet_data(j,7)+0.00000001; %Initial water depths at wetlands above inlet culvert invert         
        LS(j) = Wet_data(j,8)+0.00000001; %drop height between the inlet and outlet culvert inverts in feet
        K_Local_Losses(j) = Wet_data(j,9)+0.00000001; %Local Losses sum of coefficient (No units)
        Epsilon_friction(j) = Wet_data(j,10)+0.00000001; %Roughness height in inches        
        downst(j) = Wet_data(j,11)+0.00000001; %Downstream depth above outlet pipe invert in feet. If below pipe invert eneter 0. 
        Epsilon_D(j) = Epsilon_friction(j)/d(j); %Both terms are in inches
end     
k_compact = 1.25; %constant for pipe cover on top of pipe crown (k_compact*d(j));     

for j = 1:total_number_wetlands;
    ke(j) = 0.8; %Culvert entrance loss coefficient (see Federal Highway Administration 2012)
    n(j) = 0.009; %n is the roughness coefficient of the culvert barrel (see Federal Highway Administration 2012)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iterations = drainage_time_input*3600/Dt;
d(:) = d(:)/12; %diameter in feet

for j = 1:total_number_wetlands;  
        cover_soil(j) = k_compact*d(j); % cover measured from culvert inlet in feet
        R(j) = d(j)/4;
        A(j) = pi()/4*d(j)^2.0;
        Awet(j) = 43560*Awet(j); %To convert acres to square foot        
        if Siphon_or_Downward_drainage == 1 %Downward drainage 
            h_wet_init_depth(j) = h_wet_init_depth(j) + cover_soil(j)+depth_Sediments+d(j);
        end
        h(j) = h_wet_init_depth(j); %Initial water depths at wetlands above inlet culvert invert
        hc(j) = 0.0; %Initial critical depth. This is just for t = 0, at t + Dt, the new critical depth is automatically used.  
end

%Calculate constraints for the maximum flows at wetlands 
kinem_viscos = 10^(-5); %ft2/s
for j = 1:NW; 
     for kk = 1:NSW(j);
            k =  IDWetlands(j,kk);
            diam = d(k);                       
            if Siphon_or_Downward_drainage == 1 %Downward drainage 
                    msg = 'We are missing the code for Downward drainage. Complete when you have time';    
                    error(msg)
            else %Siphon flows
                    %%%f = 1.325/(log(Epsilon_D(k)/3.7 + 5.74/(abs(x)*diam/kinem_viscos)^0.9))^2;   %Swamee–Jain equation for friction factor (we can also use Haaland equation instead)                                                        
                    %We are solving for velocity
                    %downst(k) = max(diam/2.0,downst(k)); inlet and
                    %outlet pipes are vertical so no diam/2 is
                    %required 
                    if hmax_depth(k) + LS(k)- downst(k) > 0.02;
                            fsiphon=@(x) hmax_depth(k)+LS(k)- downst(k) - x^2.0/(2.0*g)*(1.0 + K_Local_Losses(k) + L(k)/diam*1.325/(log(Epsilon_D(k)/3.7 + 5.74/(x*diam/kinem_viscos)^0.9))^2);
                            %xguesssiphon = 0.1; %  
                            xguesssiphon = [0.00001 200]; % initial interval
                            x=fzero(@(x) fsiphon(x),xguesssiphon);                            
                            Qmax_optimiz(k) = x*A(k);
                    else % The check valves do not allow reversal flow
                            Qmax_optimiz(k) = 0.0;
                    end
            end
     end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    




figure;
if simulation_wetlands == 1 %1 is for simulation of wetlands only; 2 is for optimization 
        %% Wetland Solver Simulation
        %%%% Find wetlands that are entering to each wetland for the flow hydrograph%%downst(j,k) = Read this data from Excel file 
        ii = 1;
        Q_flow_delayed = zeros(total_number_wetlands,iterations+1); 
        Flows_To_Write = zeros(total_number_wetlands,iterations+1); 
        Q_flow_delayed(:,1) = 0.0;
        while ii <iterations;    
                Current_Time_hours = ii*Dt/3600;
                %Round Current_Time_hours to the nearest 3 decimal digits.
                Current_Time_rounded_3decimals = round(Current_Time_hours,3);
                for k = 1:total_number_wetlands;  
                    if (Current_Time_hours - Current_Time_rounded_3decimals < 0.0001) %round(X) rounds each element of X to the nearest integer. 
                        Current_Time_rounded_nearest_integer = round(Current_Time_hours);
                        Qinflow_hydro(k) = hydrograph_data(Current_Time_rounded_nearest_integer+1,k);
                    else
                        time_down = floor(Current_Time_hours); %floor(0.7) it returns 0 and ceil(0.7) it returns 1
                        time_up = ceil(Current_Time_hours);
                        %Interpolate. Note that inflow data is hourly
                        Qinflow_hydro(k) = hydrograph_data(time_down+1,k) + (Current_Time_hours-time_down)/(time_up-time_down)*(hydrograph_data(time_up+1,k) - hydrograph_data(time_down+1,k));
                    end
                end    
                %downst(1) = TW; %downst(2) = h(1); %downst(3) = h(1); %downst(4) =
                %h(2); %downst(5) = h(3);

                for j = 1:NW; 
                     for kk = 1:NSW(j);
                            k =  IDWetlands(j,kk);
                            diam = d(k);                       
                            if Siphon_or_Downward_drainage == 1 %Downward drainage 
                                    if (hc(k)+diam)/2.0 > downst(k);
                                        %We are solving for theta
                                        f=@(x) h(k)+LS(k)+ -[([diam/2*(1-cos(x/2))]+diam)/2.0]  - [1/8*(x-sin(x))*diam^2]^3 /[2.0*sin(x/2)*diam*(A(k))^2]*[1+ke(k)+29*n(k)^2*L(k)/R(k)^1.33];
                                        xguess = 0.6*2*pi();    
                                    else 
                                        %We are solving for theta
                                        f=@(x) h(k)+LS(k) - downst(k) - [1/8*(x-sin(x))*diam^2]^3 /[2.0*sin(x/2)*diam*(A(k))^2]*[1+ke(k)+29*n(k)^2*L(k)/R(k)^1.33];
                                         xguess = 0.6*2*pi(); %  
                                    end
                                    %dc = 0.325(Q/D)2/3 + 0.083D 
                                    x=fzero(@(x) f(x),xguess);
                                    Acubictemp = [1/8*(x-sin(x))*diam^2]^3;
                                    Ttemp = sin(x/2)*diam;
                                    hc(k) = diam/2*(1-cos(x/2));
                                    %add n_pipe for correcting Q;                            
                                    Q(k) = g*Acubictemp/Ttemp;  
                            else %Siphon flows   
                                    kinem_viscos = 10^(-5); %ft2/s
                                    %%%f = 1.325/(log(Epsilon_D(k)/3.7 + 5.74/(abs(x)*diam/kinem_viscos)^0.9))^2;   %Swamee–Jain equation for friction factor (we can also use Haaland equation instead)                                                        
                                    %We are solving for velocity
                                    %downst(k) = max(diam/2.0,downst(k)); inlet and
                                    %outlet pipes are vertical so no diam/2 is
                                    %required                              

                                    if h(k) + LS(k)- downst(k) > 0.02;
                                            fsiphon=@(x) h(k)+LS(k)- downst(k) - x^2.0/(2.0*g)*(1.0 + K_Local_Losses(k) + L(k)/diam*1.325/(log(Epsilon_D(k)/3.7 + 5.74/(x*diam/kinem_viscos)^0.9))^2);
                                            %xguesssiphon = 0.1; %  
                                            xguesssiphon = [0.00001 200]; % initial interval
                                            x=fzero(@(x) fsiphon(x),xguesssiphon);                            
                                            Q(k) = x*A(k);
                                    else % The check valves do not allow reversal flow
                                            Q(k) = 0.0;
                                    end
                            end
                            Q_flow_delayed(k,ii) = Q(k)*n_pipe(k);
                            if ii*Dt/3600 < travel_time(k);
                                    Q_arrived_at_wetland(k) = 0.0;
                            else
                                    time_elapsed_after_arrival = ii*Dt - travel_time(k)*3600;  %time elapsed after arrival in seconds
                                    interv_lower = floor(time_elapsed_after_arrival/Dt)+1; %floor(0.7) it returns 0 and ceil(0.7) it returns 
                                    interv_upper =  ceil(time_elapsed_after_arrival/Dt)+1;
                                    time_cell = time_elapsed_after_arrival - (interv_lower-1)*Dt;
                                    Q_arrived_at_wetland(k) = Q_flow_delayed(k,interv_lower) + ...
                                        time_cell/Dt*(Q_flow_delayed(k,interv_upper)-Q_flow_delayed(k,interv_lower));  %this is the flow entering to the wetland at the current time. Interpolate the flow using Q_flow_delayed
                            end                     
                     end
                end
                for j = 1:NW; 
                        for kk = 1:NSW(j);
                                k =  IDWetlands(j,kk); 
                                temp_sumQ_each_wetland(k) = 0.0;  %Arriving flows to wetland (total flow)   
                                if Number_inflows_each_wetland(k) > 0;
                                    for rr = 1:Number_inflows_each_wetland(k);
                                        rr = ID_hydro(j,kk,rr);   
                                        temp_sumQ_each_wetland(k) = temp_sumQ_each_wetland(k) + Q_arrived_at_wetland(rr);
                                        %temp_sumQs(1) = Q(2)+Q(3)-Q(1);
                                        %%%temp_sumQs(2) = Q(4)-Q(2); 
                                        %%%temp_sumQs(3) = -Q(3);
                                        %%%%temp_sumQs(4) = -Q(4); %temp_sumQs(5) = -Q(5);
                                    end
                                else
                                    temp_sumQ_each_wetland(k) = 0;
                                end
                                h(k) = h(k) + Dt/Awet(k)*(Qinflow_hydro(k) + temp_sumQ_each_wetland(k)-Q(k)*n_pipe(k));

                                %Including overflows from wetlands 
                                if h(k) >  hmax_depth(k);
                                    h(k) = hmax_depth(k);
                                    Q_overflow = Awet(k)*(h(k)-hmax_depth(k))/Dt;
                                    Q_flow_delayed(k,ii)  = Q_flow_delayed(k,ii) + Q_overflow; 
                                end

                                 if Siphon_or_Downward_drainage == 1 %Downward drainage 
                                        if (h(k) < (cover_soil(k)+d(k)+depth_Sediments));    %Minimum water depth in wetland
                                            h(k) = (cover_soil(k)+d(k)+depth_Sediments);   
                                        end
                                 else %Siphon flow
                                     if h(k) < 0.0;
                                            h(k) = 0.0;
                                     end
                                 end
                        end              
                end 
                % Plot and change the color for each line 
                hold on;
                xlabel('time (hr)')
                ylabel('water depth (ft)') 
                for j = 1:total_number_wetlands;            
                    if j == 2;
                            plot(ii*Dt/3600,h(j),'ro')
                    elseif j == 7;
                            plot(ii*Dt/3600,h(j),'bo')
                    elseif j == 5;
                            plot(ii*Dt/3600,h(j),'mo')
                    elseif j == 1;
                            plot(ii*Dt/3600,h(j),'yo')
                    elseif j == 9;
                            plot(ii*Dt/3600,h(j),'co')
                    else
                        plot(ii*Dt/3600,h(j),'ko')  
                    end
                end
                hold off

        %         hold on
        %         xlabel('time (hr)')
        %         ylabel('Flow discharge delayed (cfs)')
        %         for j = 1:total_number_wetlands;            
        %             if j == 2;
        %                     plot(ii*Dt/3600,Q_flow_delayed(j,ii),'ro')
        %             elseif j == 7;
        %                     plot(ii*Dt/3600,Q_flow_delayed(j,ii),'bo')
        %             elseif j == 5;
        %                     plot(ii*Dt/3600,Q_flow_delayed(j,ii),'mo')
        %             elseif j == 1;
        %                     plot(ii*Dt/3600,Q_flow_delayed(j,ii),'yo')
        %             elseif j == 9;
        %                     plot(ii*Dt/3600,Q_flow_delayed(j,ii),'co')
        %             else
        %                 plot(ii*Dt/3600,Q_flow_delayed(j,ii),'ko')  
        %             end
        %         end
        %         hold off 


        %         hold on
        %         xlabel('time (hr)')
        %         ylabel('Flow arrived_at_wetland (cfs)')
        %         for j = 1:total_number_wetlands;            
        %             if j == 2;
        %                     plot(ii*Dt/3600,Q_arrived_at_wetland(j),'ro')
        %             elseif j == 7;
        %                     plot(ii*Dt/3600,Q_arrived_at_wetland(j),'bo')
        %             elseif j == 5;
        %                     plot(ii*Dt/3600,Q_arrived_at_wetland(j),'mo')
        %             elseif j == 1;
        %                     plot(ii*Dt/3600,Q_arrived_at_wetland(j),'yo')
        %             elseif j == 9;
        %                     plot(ii*Dt/3600,Q_arrived_at_wetland(j),'co')
        %             else
        %                 plot(ii*Dt/3600,Q_arrived_at_wetland(j),'ko')  
        %             end
        %         end
        %         hold off 

                ii = ii+1;
        end 
else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %% Wetland Solver Optimization
        Dt = 3600 %We are using 1 hour time step
        %%%% Find wetlands that are entering to each wetland for the flow hydrograph%%downst(j,k) = Read this data from Excel file        
        ii = 1;
        Q_flow_delayed = zeros(total_number_wetlands,iterations+1); 
        Q_flow_delayed(:,1) = 0.0;

        while ii <iterations;    
                Current_Time_hours = ii*Dt/3600;
                %Round Current_Time_hours to the nearest 3 decimal digits.
                Current_Time_rounded_3decimals = round(Current_Time_hours,3);
                for k = 1:total_number_wetlands;  
                    if (Current_Time_hours - Current_Time_rounded_3decimals < 0.0001) %round(X) rounds each element of X to the nearest integer. 
                        Current_Time_rounded_nearest_integer = round(Current_Time_hours);
                        Qinflow_hydro(k) = hydrograph_data(Current_Time_rounded_nearest_integer+1,k);
                    else
                        time_down = floor(Current_Time_hours); %floor(0.7) it returns 0 and ceil(0.7) it returns 1
                        time_up = ceil(Current_Time_hours);
                        %Interpolate. Note that inflow data is hourly
                        Qinflow_hydro(k) = hydrograph_data(time_down+1,k) + (Current_Time_hours-time_down)/(time_up-time_down)*(hydrograph_data(time_up+1,k) - hydrograph_data(time_down+1,k));
                    end
                end  
                
                for j = 1:NW; 
                     for kk = 1:NSW(j);
                            k =  IDWetlands(j,kk);
                           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           Q(k) = 20; %x(ii); %This is flow. Please check this: Transfer Flow from optimization
                           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            Q_flow_delayed(k,ii) = Q(k)*n_pipe(k);
                            if ii*Dt/3600 < travel_time(k);
                                    Q_arrived_at_wetland(k) = 0.0;
                            else
                                    time_elapsed_after_arrival = ii*Dt - travel_time(k)*3600;  %time elapsed after arrival in seconds
                                    interv_lower = floor(time_elapsed_after_arrival/Dt)+1; %floor(0.7) it returns 0 and ceil(0.7) it returns 
                                    interv_upper =  ceil(time_elapsed_after_arrival/Dt)+1;
                                    time_cell = time_elapsed_after_arrival - (interv_lower-1)*Dt;
                                    Q_arrived_at_wetland(k) = Q_flow_delayed(k,interv_lower) + ...
                                        time_cell/Dt*(Q_flow_delayed(k,interv_upper)-Q_flow_delayed(k,interv_lower));  %this is the flow entering to the wetland at the current time. Interpolate the flow using Q_flow_delayed                                    
                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% This is the flow to write
                                    Flows_To_Write(k,ii)= Q_arrived_at_wetland(k);
                            end                     
                     end
                end
                
                for j = 1:NW; 
                        for kk = 1:NSW(j);
                                k =  IDWetlands(j,kk); 
                                temp_sumQ_each_wetland(k) = 0.0;  %Arriving flows to wetland (total flow)   
                                if Number_inflows_each_wetland(k) > 0;
                                    for rr = 1:Number_inflows_each_wetland(k);
                                        rr = ID_hydro(j,kk,rr);   
                                        temp_sumQ_each_wetland(k) = temp_sumQ_each_wetland(k) + Q_arrived_at_wetland(rr);
                                    end
                                else
                                    temp_sumQ_each_wetland(k) = 0;
                                end
                                h(k) = h(k) + Dt/Awet(k)*(Qinflow_hydro(k) + temp_sumQ_each_wetland(k)-Q(k)*n_pipe(k));

                                %Including overflows from wetlands 
                                if h(k) >  hmax_depth(k);
                                    h(k) = hmax_depth(k);
                                    Q_overflow = Awet(k)*(h(k)-hmax_depth(k))/Dt;
                                    Q_flow_delayed(k,ii)  = Q_flow_delayed(k,ii) + Q_overflow; 
                                end

                                 if Siphon_or_Downward_drainage == 1 %Downward drainage 
                                        if (h(k) < (cover_soil(k)+d(k)+depth_Sediments));    %Minimum water depth in wetland
                                            h(k) = (cover_soil(k)+d(k)+depth_Sediments);   
                                        end
                                 else %Siphon flow
                                     if h(k) < 0.0;
                                            h(k) = 0.0;
                                     end
                                 end
                        end              
                end 
                % Plot and change the color for each line 
                hold on;
                xlabel('time (hr)')
                ylabel('water depth (ft)') 
                for j = 1:total_number_wetlands;            
                    if j == 2;
                            plot(ii*Dt/3600,h(j),'ro')
                    elseif j == 7;
                            plot(ii*Dt/3600,h(j),'bo')
                    elseif j == 5;
                            plot(ii*Dt/3600,h(j),'mo')
                    elseif j == 1;
                            plot(ii*Dt/3600,h(j),'yo')
                    elseif j == 9;
                            plot(ii*Dt/3600,h(j),'co')
                    else
                        plot(ii*Dt/3600,h(j),'ko')  
                    end
                end
                hold off

        %         hold on
        %         xlabel('time (hr)')
        %         ylabel('Flow discharge delayed (cfs)')
        %         for j = 1:total_number_wetlands;            
        %             if j == 2;
        %                     plot(ii*Dt/3600,Q_flow_delayed(j,ii),'ro')
        %             elseif j == 7;
        %                     plot(ii*Dt/3600,Q_flow_delayed(j,ii),'bo')
        %             elseif j == 5;
        %                     plot(ii*Dt/3600,Q_flow_delayed(j,ii),'mo')
        %             elseif j == 1;
        %                     plot(ii*Dt/3600,Q_flow_delayed(j,ii),'yo')
        %             elseif j == 9;
        %                     plot(ii*Dt/3600,Q_flow_delayed(j,ii),'co')
        %             else
        %                 plot(ii*Dt/3600,Q_flow_delayed(j,ii),'ko')  
        %             end
        %         end
        %         hold off 


        %         hold on
        %         xlabel('time (hr)')
        %         ylabel('Flow arrived_at_wetland (cfs)')
        %         for j = 1:total_number_wetlands;            
        %             if j == 2;
        %                     plot(ii*Dt/3600,Q_arrived_at_wetland(j),'ro')
        %             elseif j == 7;
        %                     plot(ii*Dt/3600,Q_arrived_at_wetland(j),'bo')
        %             elseif j == 5;
        %                     plot(ii*Dt/3600,Q_arrived_at_wetland(j),'mo')
        %             elseif j == 1;
        %                     plot(ii*Dt/3600,Q_arrived_at_wetland(j),'yo')
        %             elseif j == 9;
        %                     plot(ii*Dt/3600,Q_arrived_at_wetland(j),'co')
        %             else
        %                 plot(ii*Dt/3600,Q_arrived_at_wetland(j),'ko')  
        %             end
        %         end
        %         hold off 

                ii = ii+1;
        end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_storage = 0.0;
final_storage = 0.0;

figure;
hold on
iterations_vector = 1:iterations+1;
xlabel('iterations')
ylabel('Flow discharge delayed (cfs)')
for j = 1:total_number_wetlands;    
    if j == 2;
            plot(iterations_vector,Q_flow_delayed(j,:),'ro')
    elseif j == 7;
            plot(iterations_vector,Q_flow_delayed(j,:),'bo')
    elseif j == 5;
            plot(iterations_vector,Q_flow_delayed(j,:),'mo')
    elseif j == 1;
            plot(iterations_vector,Q_flow_delayed(j,:),'yo')
    elseif j == 9;
            plot(iterations_vector,Q_flow_delayed(j,:),'co')
    else
            plot(iterations_vector,Q_flow_delayed(j,:),'ko')  
    end
end

hold off
msg = 'Simulation completed with No Errors';
error(msg) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for j = 1:total_number_wetlands;     
%       init_storage = init_storage + Awet(j)* (h_wet_init_depth(j)-cover_soil(j)-depth_Sediments-d(j));
%       final_storage = (final_storage + Awet(j)* (h(j)-cover_soil(j)-depth_Sediments-d(j)));  
%       if final_storage < 0
%           final_storage = 0;
%       end
% end
% % fprintf('The percentage of storage released during the specified drainage time is:');
% Ratio_storage_released = (init_storage-final_storage)/init_storage;
% if Ratio_storage_released>1.0
%     Ratio_storage_released=-1;
% end 
% %Maximize
% Ratio_storage_released =1-Ratio_storage_released; 

% fprintf('The final water depths in the wetlands are (measured from wetland bottom):');

% for j = 1:total_number_wetlands;
%      p(j) = h(j) - cover_soil(j)-d(j)-depth_Sediments;
% end
 
%calculate the pipe cost
% fprintf('The cost in the wetlands are :');
% for j = 1:NW
%     CostPipe(j)=(L(j)/10*(1.8857148201*diameter_pipes(j).^2 - 2.5216879005*diameter_pipes(j) + 31.4830646471))*n_pipe(j);  
%     CostValve(j)=(33.9150692189*diameter_pipes(j).^2 - 104.3377332666*diameter_pipes(j) + 464.2608919823)*n_pipe(j);
% end   %% in dollar
% obj(1)=Ratio_storage_released
% 
% obj(2)=(sum(CostPipe)+sum(CostValve))/2.0e7 %% ratio of cost 
 
% for j = 1:NW
%     if h(j)> h_wet_init_depth(j)
%         obj(1)=100;
%         obj(2)=100;
% 
%     end  %%keep this constraints for avoiding overflow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%