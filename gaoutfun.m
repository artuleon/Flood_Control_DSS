function [state,options,optchanged] = ...
             myoutput(options,state,flag,interval) 
 global g_number
         g_number = state.Generation ; %get current generation number
         optchanged = false;
     end
% 
% 
% function [state,options,optchanged] = gaoutfun(options,state,flag)
% persistent history
% optchanged = false;
% switch flag    
%     case 'iter'       
%         % Make a smoothing of the data after 2 generations.
%         if state.Generation == 2
%             %options.CrossoverFraction = 0.8;
%             %optchanged = true;
%         end
%     case 'done'
%         % Include the final population in the history.
%         ss = size(history,3);
%         history(:,:,ss+1) = state.Population;
%         assignin('base','gapopulationhistory',history);
% end