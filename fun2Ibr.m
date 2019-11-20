function [out1] = fun2Ibr(V_n,G_br,Ih,Node_P,Node_N)
    % Branch current update
    if Node_P ~= 0 && Node_N ~= 0
        out1 = G_br*(V_n(Node_P) - V_n(Node_N)) + Ih;
    elseif Node_N == 0
        out1 = G_br*V_n(Node_P) + Ih;
    else
        out1 = G_br*(- V_n(Node_N)) + Ih;
    end

end

