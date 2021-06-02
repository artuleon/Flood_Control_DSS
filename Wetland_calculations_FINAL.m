global Inflow_points_LATERAL_FROM_WETLANDS




Inflow_points_LATERAL_FROM_WETLANDS = 68



d(:) = d(:)/12; %diameter in feet
for j = 1:total_number_wetlands;  
        cover_soil(j) = k_compact*d(j); % cover measured from culvert inlet in feet
        R(j) = d(j)/4;
        A(j) = pi()/4*d(j)^2.0;
        Awet(j) = 43560*Awet(j); %To convert acres to square foot        
        if Siphon_or_Downward_drainage == 1 %Downward drainage 
            h_wet_init_depth(j) = h_wet_init_depth(j) + cover_soil(j)+depth_Sediments+d(j);
        end
        hwet(j) = h_wet_init_depth(j); %Initial water depths at wetlands above inlet culvert invert
        hc(j) = 0.0; %Initial critical depth. This is just for t = 0, at t + Dt, the new critical depth is automatically used.  
end


%Calculate constraints for the maximum flows at wetlands 
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
                            fsiphon=@(y) hmax_depth(k)+LS(k)- downst(k) - y^2.0/(2.0*g)*(1.0 + K_Local_Losses(k) + L(k)/diam*1.325/(log(Epsilon_D(k)/3.7 + 5.74/(y*diam/kinem_viscos)^0.9))^2);
                            %xguesssiphon = 0.1; %  
                            xguesssiphon = [0.00001 200]; % initial interval
                            y=fzero(@(y) fsiphon(y),xguesssiphon);    
                            %Maximum flow that can be released from each wetland 
                            %(Flow Units need to be the same of those used in HEC-RAS). 
                            %This would depend on the capacity of the gates 
                            MaxFlowRelease_Wetland(k) = y*A(k)*n_pipe(k);
                    else % The check valves do not allow reversal flow
                            MaxFlowRelease_Wetland(k) = 0.0;
                    end
            end
     end
end