function [I_br] = Ibr_assign(No_Brn,rlc,I_hs,V_n,G_br,I_br)
    % Branch currents are updated with this function
    Pr_Type = -1;
    U1 = 0;
    for i=1:No_Brn
        Type = rlc(i,3);
        Node_P = I_hs(i,1);
        Node_N = I_hs(i,2);
        Ih = I_hs(i,5);
        if Type == 2 % Transformer branches - no magnetization branches
             if Pr_Type ~= 2
                 % Primary winding
                 U1 = rlc(i,6);
             else
                 % Secondary winding
                 U2 = rlc(i,6);
                 a = U1/U2;
                 % Primary winding nodes
                 Node_P_tp = rlc(i+1,1); 
                 Node_N_tp = rlc(i+1,2);
                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                 I_br(i) = fun1Ibr(V_n,G_br(i),G_br(i)/a,Ih,Node_P,Node_N,Node_P_tp,Node_N_tp);
                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                 Pr_Type = Type;
                 continue
             end
        end
        Pr_Type = Type;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        I_br(i) = fun2Ibr(V_n,G_br(i),Ih,Node_P,Node_N);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

end

