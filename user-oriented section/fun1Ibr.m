function [ out1 ] = fun1Ibr(V_n,G_br,coeftr,Ih,Node_P,Node_N,Node_P_tp,Node_N_tp)
     % Transformer winding
     if Node_N_tp ~= 0 && Node_P ~= 0 && Node_N ~= 0
        out1 = G_br*(V_n(Node_P) - V_n(Node_N)) - coeftr*(V_n(Node_P_tp) - V_n(Node_N_tp)) + Ih;
     elseif Node_N_tp == 0 && Node_P == 0
        out1 = G_br*(- V_n(Node_N)) - coeftr*V_n(Node_P_tp) + Ih;
     elseif Node_N_tp == 0 && Node_N == 0
        out1 = G_br*V_n(Node_P) - coeftr*V_n(Node_P_tp) + Ih;
     elseif Node_N_tp == 0
        out1 = G_br*(V_n(Node_P) - V_n(Node_N)) - coeftr*V_n(Node_P_tp) + Ih;
     elseif Node_P == 0
        out1 = G_br*(- V_n(Node_N)) - coeftr*(V_n(Node_P_tp) - V_n(Node_N_tp)) + Ih;
     else
        out1 = G_br*V_n(Node_P) - coeftr*(V_n(Node_P_tp) - V_n(Node_N_tp)) + Ih;
     end

end

