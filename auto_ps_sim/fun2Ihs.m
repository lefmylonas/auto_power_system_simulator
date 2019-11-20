function [out1] = fun2Ihs(V_n,I_br,coef1,coef2,Node_P,Node_N)
    % Simple RL/RC branch
    if Node_P ~= 0 && Node_N ~= 0
        out1 = coef1*(V_n(Node_P) - V_n(Node_N)) + coef2*I_br;
    elseif Node_N == 0
        out1 = coef1*V_n(Node_P) + coef2*I_br;
    else
        out1 = coef1*(- V_n(Node_N)) + coef2*I_br;
    end

end

