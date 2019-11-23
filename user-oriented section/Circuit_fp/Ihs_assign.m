function [I_hs] = Ihs_assign(No_Brn, rlc, I_hs, V_n, I_br)
    % This function computes the history current sources of the system
    Pr_Type = -1;
    U1 = 0;
    for i=1:No_Brn
        if ~any(I_hs(i,3:end))
            continue
        end
        Type = rlc(i,3);
        Node_P = I_hs(i,1);
        Node_N = I_hs(i,2);
        coef1 = I_hs(i,3);
        coef2 = I_hs(i,4);
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
                 I_hs(i,5) = fun1Ihs_wrapper_fixpt(I_br(i),V_n,coef1,coef2,coef1/a,Node_P,Node_N,Node_P_tp,Node_N_tp);
                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                 Pr_Type = Type;
                 continue
             end
        end
        Pr_Type = Type;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        I_hs(i,5) = fun2Ihs_wrapper_fixpt(V_n,I_br(i),coef1,coef2,Node_P,Node_N);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

end

        