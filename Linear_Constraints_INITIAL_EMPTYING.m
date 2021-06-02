global Inflow_points_LATERAL_FROM_WETLANDS
global NumberWetlands_managed
global Inflow_wetlands_for_constraint 
global Ecologicaldepth_storage
global Initial_storage
global End_storage
global StorageAtOverflowLevel




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Note that x can not be negative, so maybe we need to enforce this. First
%check latex paper and then code it. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


N = Inflow_points_LATERAL_FROM_WETLANDS;
P = NumberWetlands_managed;
dt = 3600;  %currently time step is one hour.

%Including and not including change of flows constraint
ChangeOfFlowsConstraint = 1; %1 includes change of flows constraint, otherwise it doesn't include
%Constraints for /xi+1-x1/ <= b_maximum (Ax<=b_maximum)
%b is the maximum change of flow between hours allowed 
b_maximum = 5.0;

%UppermaximumFlow = [1000 500 800 600 1000 400 300 300];
%UppermaximumFlow is the maximum flow allowed for each wetland
UppermaximumFlow = [25 12 15 15 25 10 10 10]; %this flow is in M3/s for each of the ponds
UppermaximumFlow = 3*UppermaximumFlow;

%Water levels at wetlands before rainfall need to be at minimum levels 
%e.g., 3 days (3x24)=72 hors 
Number_hours = 72; %Number of hours after the optimization at which the wetland is at minimum level

for ii = 1:P;
    Constant1(ii) = (Ecologicaldepth_storage(ii) - Initial_storage(ii))/dt;
    Constant2(ii) = (StorageAtOverflowLevel(ii) - Initial_storage(ii))/dt;
end


if ChangeOfFlowsConstraint == 1
    A = zeros(2*(N-1)*P + 2*P*N,P*N);
    b = zeros(2*(N-1)*P + 2*P*N,1); %Rows must be the same as that of A
    b = b + b_maximum; %This is the change of flow in m3/s (we set up a flow of 2 m3/s)
    %Constraints for /xi+1-x1/ <= b (Ax<=b)
    ot = ones(N,1);
    Rows = 2*(N-1);
    Columns = N;
    A1 = spdiags([ot -ot ],[0 1],N-1,N);
    A1 = [A1 ; -A1];
    for ii = 1:P;
        row1 = (ii-1)*Rows;
        row2 = ii*Rows;
        col1 = (ii-1)*Columns;
        col2 = ii*Columns;
        A(row1+1:row2,col1+1:col2) = A1; % Assign to the appropriate location
    end
else
    A = zeros(2*P*N,P*N);
    b = zeros(2*P*N,1); %Rows must be the same as that of A
end

%Water level in the wetland needs to be above ecological depth
A3 = ones(N);
A3 = tril(A3); 
for ii = 1:P;
    if ChangeOfFlowsConstraint == 1
        row1 = 2*(N-1)*P + (ii-1)*N;
        row2 = 2*(N-1)*P + ii*N;
    else
        row1 = (ii-1)*N;
        row2 = ii*N;
    end    
    col1 = (ii-1)*N;
    col2 = ii*N;
    A(row1+1:row2,col1+1:col2) = A3; % Assign to the appropriate location
    b(row1+1:row2) = A3*Inflow_wetlands_for_constraint(ii,:)' -  Constant1(ii);
end



%Water level needs to be below the maximum wetland overflow depth
for ii = 1:P;
    if ChangeOfFlowsConstraint == 1
        row1 = 2*(N-1)*P + P*N + (ii-1)*N;
        row2 = 2*(N-1)*P + P*N +  ii*N;
    else
        row1 = P*N + (ii-1)*N;
        row2 = P*N + ii*N;
    end    
    col1 = (ii-1)*N;
    col2 = ii*N;
    A(row1+1:row2,col1+1:col2) = -A3; % Assign to the appropriate location
    b(row1+1:row2) = -A3*Inflow_wetlands_for_constraint(ii,:)' +  Constant2(ii);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Equality constraints
%Water level at end of simulation needs to be at specified levels or
%storages 
%Aeq = zeros(2*P,N*P);
Aeq = zeros(P,N*P);
A4 = ones(1,N);
%beq = zeros(2*P,1);
beq = zeros(P,1);
% for ii = 1:P 
%     col1 = (ii-1)*N;
%     col2 = ii*N;
%     Aeq(ii,col1+1:col2) = A4;
%     beq(ii) = (Initial_storage(ii)-End_storage(ii))/dt + sum(Inflow_wetlands_for_constraint(ii,:));
% end
% 
% %Water levels at wetlands before rainfall need to be at minimum levels 
% for ii = 1:P 
%     col1 = (ii-1)*N;
%     Aeq(ii+P,col1+1:col1+Number_hours) = 1;
%     beq(ii+P) = (Initial_storage(ii)-Ecologicaldepth_storage(ii))/dt + sum(Inflow_wetlands_for_constraint(ii,1:Number_hours));
% end



%Water levels at wetlands before rainfall need to be at minimum levels 
for ii = 1:P 
    col1 = (ii-1)*N;
    Aeq(ii,col1+1:col1+Number_hours) = 1;
    beq(ii) = (Initial_storage(ii)-Ecologicaldepth_storage(ii))/dt + sum(Inflow_wetlands_for_constraint(ii,1:Number_hours));
end

%Water level at end of simulation needs to be at specified levels or
%storages 
% for ii = 1:P 
%     col1 = (ii-1)*N;
%     col2 = ii*N;
%     Aeq(ii+P,col1+1:col2) = A4;
%     beq(ii+P) = (Initial_storage(ii)-End_storage(ii))/dt + sum(Inflow_wetlands_for_constraint(ii,:));
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Upper and lower bounds
LB = zeros(1,nvar); % Lower bound is zero, which means no release from wetlands or dams
UB = zeros(1,nvar); % Upper bound (allocating)
for ii = 1:P 
    col1 = (ii-1)*N;
    col2 = ii*N;
    UB(1,col1+1:col2) = UppermaximumFlow(ii);
end
LB = max(1/10000*UB, 0.01);

