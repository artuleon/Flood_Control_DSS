%function [x,f,eflag,outpt] = runobjconstr(x0,LB,UB)
function [x,f,eflag,outpt] = runobjconstr_parallel(x0,opts,LB,UB)

if nargin == 1 % No options supplied
    opts = [];
end

xLast = []; % Last place Fitness_Constr_Non_vectorized was called
myf = []; % Use for objective at xLast
%myc = []; % Use for nonlinear inequality constraint
%myceq = []; % Use for nonlinear equality constraint

fun = @objfun; % the objective function, nested below
%cfun = @constr; % the constraint function, nested below

% Call fmincon
%[x,f,eflag,outpt] = fmincon(fun,x0,[],[],[],[],[],[],cfun,opts);

% opts = optimoptions('patternsearch','ScaleMesh',true, 'InitialMeshSize',10, 'UseCompletePoll',true,'AccelerateMesh',true, 'UseVectorized',false,'Display','iter', ...
%                  'PlotFcn',{@psplotbestf, @psplotfuncount,@psplotmeshsize,@psplotbestx},'MeshTolerance',0.05,'FunctionTolerance',5.0);  
% [x,f,eflag,outpt] = patternsearch(fun,x0,[],[],[],[],LB,UB,cfun,opts);
 [x,f,eflag,outpt] = patternsearch(fun,x0,[],[],[],[],LB,UB,[],opts);
%'SearchFcn',@positivebasisnp1
% @psplotmaxconstr
 
    function y = objfun(x)
        if ~isequal(x,xLast) % Check if computation is necessary
            myf = Fitness_Constr_Non_vectorized(x);
            xLast = x;
        end
        % Now compute objective function
        y = myf; %+ 20*(x(3) - x(4)^2)^2 + 5*(1 - x(4))^2;
    end

%     function [c,ceq] = constr(x)
%         if ~isequal(x,xLast) % Check if computation is necessary
%             [myf,myc,myceq] = Fitness_Constr_Non_vectorized(x);
%             xLast = x;
%         end
%         % Now compute constraint functions
%         c = myc % In this case, the computation is trivial
%         ceq = myceq
%     end
end