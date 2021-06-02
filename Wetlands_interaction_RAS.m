function yy = Wetlands_interaction_RAS(xwet,Number_overflow);
global NW 
global NSW
global total_number_wetlands
global iterations
global Awet
global hmax_depth
global hmin_depth
global hwet
global Q_arrived_at_wetland
global Number_inflows_each_wetland
global Inflow_points_LATERAL_FROM_WETLANDS
global Dt_wetlands
global travel_time
global IDWetlands
global Qinflow_hydro
global Q_flow_delayed
global ID_hydro
global ratio_DtRAS_DtWetlands
global ID_downst_Wetlands_entering_RAS
global plot_wetlands

%figure; 
% Zero flow is released at the initial time, calculation 1 corresponds to
% hour 1, second calculation to hour 2 and so on 
%% Wetland Solver Optimization  
Q_flow_delayed = zeros(total_number_wetlands,iterations+1); 
Q_flow_delayed(:,1) = 0.0;
Number_overflow = 0; %How many times overflow has occurred
Number_drying = 0; %How many times drying has occurred
ii = 1;
uu = 1;
while ii <= iterations;  
        for j = 1:NW; 
                for kk = 1:NSW(j);
                        k =  IDWetlands(j,kk); 
                        posit_temp3 = Inflow_points_LATERAL_FROM_WETLANDS*(k-1);
                        Q_flow_delayed(k,ii) = xwet(posit_temp3+uu);  %Q(k)*n_pipe(k);
                        
                        if ii*Dt_wetlands/3600 < travel_time(k);
                                Q_arrived_at_wetland(k) = 0.0;
                        else
                                time_elapsed_after_arrival = ii*Dt_wetlands - travel_time(k)*3600;  %time elapsed after arrival in seconds
                                interv_lower = floor(time_elapsed_after_arrival/Dt_wetlands)+1; %floor(0.7) it returns 0 and ceil(0.7) it returns 
                                interv_upper =  ceil(time_elapsed_after_arrival/Dt_wetlands)+1;
                                time_cell = time_elapsed_after_arrival - (interv_lower-1)*Dt_wetlands;
                                Q_arrived_at_wetland(k) = Q_flow_delayed(k,interv_lower) + ...
                                    time_cell/Dt_wetlands*(Q_flow_delayed(k,interv_upper)-Q_flow_delayed(k,interv_lower));  %this is the flow entering to the wetland at the current time. Interpolate the flow using Q_flow_delayed
                        end
                end
        end

        for j = 1:NW; 
                for kk = 1:NSW(j);
                        k =  IDWetlands(j,kk); 
                        temp_sumQ_each_wetland = 0.0;  %Arriving flows to wetland (total flow)   
                        if Number_inflows_each_wetland(k) > 0;
                                for rr = 1:Number_inflows_each_wetland(k);
                                    ss = ID_hydro(j,kk,rr);   
                                    temp_sumQ_each_wetland = temp_sumQ_each_wetland + Q_arrived_at_wetland(ss);
                                end
                        else
                                temp_sumQ_each_wetland = 0;
                        end
                        hwet(k) = hwet(k) + Dt_wetlands/Awet(k)*(Qinflow_hydro(k,ii) + ...
                                temp_sumQ_each_wetland-Q_flow_delayed(k,ii) );
                        
                        %Including overflows from wetlands 
                        if hwet(k) >  hmax_depth(k);
                            hwet(k) = hmax_depth(k);
                            Q_overflow = Awet(k)*(hwet(k)-hmax_depth(k))/Dt_wetlands;
                            Q_flow_delayed(k,ii)  = Q_flow_delayed(k,ii) + Q_overflow; 
                            Number_overflow = Number_overflow + 1;
                        end

                         %Minimum flows at wetlands
                         if hwet(k) < hmin_depth(k);
                                hwet(k) = hmin_depth(k);
                                Q_flow_delayed(k,ii) = 0.0; %Decrease flow release
                                Number_drying = Number_drying + 1; 
                         end
                        %Flow at the most downstream wetland. This is used for HEC-RAS        
                        if kk == NSW(j) & mod(ii,ratio_DtRAS_DtWetlands) == 0;                             
                                %We find the position of the vector element 
                                qq = find(ID_downst_Wetlands_entering_RAS==IDWetlands(j,kk));
                                posit_temp7 = (qq-1)*Inflow_points_LATERAL_FROM_WETLANDS;                                                            
                                yy(posit_temp7 + uu) = Q_arrived_at_wetland(IDWetlands(j,NSW(j)));                            
                                
                                %This is done only once for the whole network of wetlands at each time step                                
                                if j == NW;
                                   uu = uu+1;
                                end
                        end
                end
        end
        
        if plot_wetlands == 1
                %Plot and change the color for each line
                hold on;
                xlabel('time (hr)')
                ylabel('water depth (ft)') 
                for j = 1:total_number_wetlands;            
                        if j == 2;
                                plot(ii*Dt_wetlands/3600,hwet(j),'ro')
                        elseif j == 7;
                                plot(ii*Dt_wetlands/3600,hwet(j),'bo')
                        elseif j == 5;
                                plot(ii*Dt_wetlands/3600,hwet(j),'mo')
                        elseif j == 1;
                                plot(ii*Dt_wetlands/3600,hwet(j),'yo')
                        elseif j == 9;
                                plot(ii*Dt_wetlands/3600,hwet(j),'co')
                        else
                            plot(ii*Dt_wetlands/3600,hwet(j),'ko')  
                        end
                end        
                hold on
        end        
        ii = ii+1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_storage = 0.0;
final_storage = 0.0;

if plot_wetlands == 1
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
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for j = 1:total_number_wetlands;     
%       init_storage = init_storage + Awet(j)* (h_wet_init_depth(j)-cover_soil(j)-depth_Sediments-d(j));
%       final_storage = (final_storage + Awet(j)* (hwet(j)-cover_soil(j)-depth_Sediments-d(j)));  
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
%      p(j) = hwet(j) - cover_soil(j)-d(j)-depth_Sediments;
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
%     if hwet(j)> h_wet_init_depth(j)
%         obj(1)=100;
%         obj(2)=100;
% 
%     end  %%keep this constraints for avoiding overflow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%