function [ out1 ] = fun1Ihs(I_br,V_n,coef1,coef2,coeftr,Node_P,Node_N,Node_P_tp,Node_N_tp)
     % History current source computation | Transformer Winding
     if Node_N_tp ~= 0 && Node_P ~= 0 && Node_N ~= 0
        out1 = coef1*(V_n(Node_P) - V_n(Node_N)) - coeftr*(V_n(Node_P_tp) - V_n(Node_N_tp)) + coef2*I_br;
     elseif Node_N_tp == 0 && Node_P == 0
        out1 = coef1*(- V_n(Node_N)) - coeftr*V_n(Node_P_tp) + coef2*I_br;
     elseif Node_N_tp == 0 && Node_N == 0
        out1 = coef1*V_n(Node_P) - coeftr*V_n(Node_P_tp) + coef2*I_br;
     elseif Node_N_tp == 0
        out1 = coef1*(V_n(Node_P) - V_n(Node_N)) - coeftr*V_n(Node_P_tp) + coef2*I_br;
     elseif Node_P == 0
        out1 = coef1*(- V_n(Node_N)) - coeftr*(V_n(Node_P_tp) - V_n(Node_N_tp)) + coef2*I_br;
     else
        out1 = coef1*V_n(Node_P) - coeftr*(V_n(Node_P_tp) - V_n(Node_N_tp)) + coef2*I_br;
     end

end

