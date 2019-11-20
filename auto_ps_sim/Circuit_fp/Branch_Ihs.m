function [I_hs] = Branch_Ihs(Node_P, Node_N, R_eff, R, C, Dt, count, flag)
    % Series or Parallel branch
    if count == 2 % R
        I_hs = [Node_P, Node_N, 0, 0, 0];
        return
    elseif count == 3 % L
        I_hs = [Node_P, Node_N, 1/R_eff, 1, 0];
        return
    elseif count == 4 % C
        I_hs = [Node_P, Node_N, -1/R_eff, -1, 0];
        return
    end
    if flag
        % Parallel branch
        if count == 5 % RL
            I_hs = [Node_P, Node_N, 1/R_eff - 2/R, 1, 0];
        elseif count == 6 % RC
            I_hs = [Node_P, Node_N, 2/R - 1/R_eff, -1, 0];
        end
    else
        % Series branch
        if count == 5 % RL
            I_hs= [Node_P, Node_N, 1/R_eff, (R_eff - 2*R)/R_eff, 0];
        elseif count == 6 % RC
            I_hs = [Node_P, Node_N, -1/R_eff, (R_eff - Dt/C)/R_eff, 0];
        end    
    end
end

