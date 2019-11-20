function [Out] = outp_assign(Out, outputs, No_Out, V_n, I_br, count)
    % This function assigns simulation results to Outputs' matrix for Error
    % Estimation or Presenting Results
    for i=1:No_Out
        if size(outputs{i,1},2) == 2 % Voltage Output
            Node_P = outputs{i,1}(1,1);
            Node_N = outputs{i,1}(1,2);
            if Node_P ~= 0 && Node_N ~= 0
                Out(i,count) = V_n(Node_P) - V_n(Node_N);
            elseif Node_N == 0
                Out(i,count) = V_n(Node_P);
            else
                Out(i,count) = - V_n(Node_N);
            end
        elseif size(outputs{i,1},2) == 1 % Current Output
            Out(i,count) = I_br(outputs{i,1}(1,1));
        end
    end
end

