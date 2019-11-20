function [ I_history ] = fun2Ihistory(I_history,I_source,c,Node_P_tp,Node_N_tp)
    % Transformer winding
    if Node_N_tp ~= 0
         I_history(Node_P_tp) = I_history(Node_P_tp) + I_source*c; 
         I_history(Node_N_tp) = I_history(Node_N_tp) - I_source*c;
     else
         I_history(Node_P_tp) = I_history(Node_P_tp) + I_source*c; 
     end

end

