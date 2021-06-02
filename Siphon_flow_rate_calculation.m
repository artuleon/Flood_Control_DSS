
clear all
close all 
Simulation_time_in_seconds = 100; %%%Enter period of entire simulation time in HEC-RAS. This data comes from
Dt_wetlands = 1; %Delta time for wetland calculations in seconds

%Wetlands Basic Information
kinem_viscos = 10^(-5); %ft2/s    This is water kinematic viscosity    
g = 32.2; %This code was prepared in English units
d = 6.0 %diameter in inches

%Enter data here (English units)
home_dir = pwd; %This returns the working directory.
%Read data of Wetland Characteristics
filenameinput = [home_dir '\Wetland_data\WetlCharactSiphonDownw_Drain.xlsx'];
sheet = 'Wetland_characteristics';
xlRange = ['A5:L' num2str(total_number_wetlands + 4)];
Wet_data = xlsread(filenameinput,sheet,xlRange);
MaxFlowRelease_Wetland = zeros(total_number_wetlands,1); %This is very important as we need the info for maximum flow realeases for each wetland
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iterations = ceil(Simulation_time_in_seconds/Dt_wetlands);
[rownum,colnum]=size(Wet_data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
d = d/12; %diameter in feet
R = d/4;
A = pi()/4*d^2.0;
Awet = 43560*Awet; %To convert acres to square foot                
hwet = h_wet_init_depth; %Initial water depths at wetlands above inlet culvert invert        

%Calculate Flow rate in wetland
for j = 1:iterations;            
        %%%f = 1.325/(log(Epsilon_D/3.7 + 5.74/(abs(x)*d/kinem_viscos)^0.9))^2;   %Swamee–Jain equation for friction factor (we can also use Haaland equation instead)                                                        
        %We are solving for velocity
        %downst = max(d/2.0,downst); inlet and
        %outlet pipes are vertical so no d/2 is
        %required 
        if hmax_depth + LS- downst > 0.02;
                fsiphon=@(y) hmax_depth+LS- downst - y^2.0/(2.0*g)*(1.0 + K_Local_Losses + L/d*1.325/(log(Epsilon_D/3.7 + 5.74/(y*d/kinem_viscos)^0.9))^2);
                %xguesssiphon = 0.1; %  
                xguesssiphon = [0.00001 200]; % initial interval
                y=fzero(@(y) fsiphon(y),xguesssiphon);    
                %Maximum flow that can be released from each wetland 
                %(Flow Units need to be the same of those used in HEC-RAS). 
                %This would depend on the capacity of the gates 
                MaxFlowRelease_Wetland = y*A*n_pipe;
        else % The check valves do not allow reversal flow
                MaxFlowRelease_Wetland = 0.0;
        end
end