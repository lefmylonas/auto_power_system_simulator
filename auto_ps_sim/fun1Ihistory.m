function [ I_history ] = fun1Ihistory(I_history,I_source,Node_P,Node_N)
    % Normal branches
    if  Node_P ~= 0 && Node_N ~= 0
        I_history(Node_N) = I_history(Node_N) + I_source; 
        I_history(Node_P) = I_history(Node_P) - I_source; 
    else
        if Node_N ~= 0 
            I_history(Node_N) = I_history(Node_N) + I_source;
        elseif Node_P ~= 0 
            I_history(Node_P) = I_history(Node_P) - I_source;  
        end 
    end

end

