function [G] = Transformer_correction(G, Node_P, Node_N, Node_P_tp, Node_N_tp, a, R_eff)
   % This function corrects the conductance matrix when a transformer is
   % detected. It adds some information related to the primary and
   % secondary windings of the transformer. It also checks the node numbers
   % for zero node detection and secures right results
   if Node_N_tp ~= 0 && Node_P ~= 0 && Node_N ~= 0
       G(Node_P,Node_P_tp) = G(Node_P,Node_P_tp) - 1/(a*R_eff);
       G(Node_P,Node_N_tp) = G(Node_P,Node_N_tp) + 1/(a*R_eff);
       G(Node_N,Node_P_tp) = G(Node_N,Node_P_tp) + 1/(a*R_eff);
       G(Node_N,Node_N_tp) = G(Node_N,Node_N_tp) - 1/(a*R_eff);
       G(Node_P_tp,Node_P) = G(Node_P_tp,Node_P) - 1/(a*R_eff);
       G(Node_P_tp,Node_N) = G(Node_P_tp,Node_N) + 1/(a*R_eff);
       G(Node_P_tp,Node_P_tp) = G(Node_P_tp,Node_P_tp) + 1/((a^2)*R_eff);
       G(Node_P_tp,Node_N_tp) = G(Node_P_tp,Node_N_tp) - 1/((a^2)*R_eff);
       G(Node_N_tp,Node_P) = G(Node_N_tp,Node_P) + 1/(a*R_eff);
       G(Node_N_tp,Node_N) = G(Node_N_tp,Node_N) - 1/(a*R_eff);
       G(Node_N_tp,Node_P_tp) = G(Node_N_tp,Node_P_tp) - 1/((a^2)*R_eff);
       G(Node_N_tp,Node_N_tp) = G(Node_N_tp,Node_N_tp) + 1/((a^2)*R_eff);
   elseif Node_N_tp == 0 && Node_P == 0
       G(Node_N,Node_P_tp) = G(Node_N,Node_P_tp) + 1/(a*R_eff);
       G(Node_P_tp,Node_N) = G(Node_P_tp,Node_N) + 1/(a*R_eff);
       G(Node_P_tp,Node_P_tp) = G(Node_P_tp,Node_P_tp) + 1/((a^2)*R_eff);
   elseif Node_N_tp == 0 && Node_N == 0
       G(Node_P,Node_P_tp) = G(Node_P,Node_P_tp) - 1/(a*R_eff);
       G(Node_P_tp,Node_P) = G(Node_P_tp,Node_P) - 1/(a*R_eff);
       G(Node_P_tp,Node_P_tp) = G(Node_P_tp,Node_P_tp) + 1/((a^2)*R_eff);
   elseif Node_N_tp == 0
       G(Node_P,Node_P_tp) = G(Node_P,Node_P_tp) - 1/(a*R_eff);
       G(Node_N,Node_P_tp) = G(Node_N,Node_P_tp) + 1/(a*R_eff);
       G(Node_P_tp,Node_P) = G(Node_P_tp,Node_P) - 1/(a*R_eff);
       G(Node_P_tp,Node_N) = G(Node_P_tp,Node_N) + 1/(a*R_eff);
       G(Node_P_tp,Node_P_tp) = G(Node_P_tp,Node_P_tp) + 1/((a^2)*R_eff);
   elseif Node_P == 0
       G(Node_N,Node_P_tp) = G(Node_N,Node_P_tp) + 1/(a*R_eff);
       G(Node_N,Node_N_tp) = G(Node_N,Node_N_tp) - 1/(a*R_eff);
       G(Node_P_tp,Node_N) = G(Node_P_tp,Node_N) + 1/(a*R_eff);
       G(Node_P_tp,Node_P_tp) = G(Node_P_tp,Node_P_tp) + 1/((a^2)*R_eff);
       G(Node_P_tp,Node_N_tp) = G(Node_P_tp,Node_N_tp) - 1/((a^2)*R_eff);
       G(Node_N_tp,Node_N) = G(Node_N_tp,Node_N) - 1/(a*R_eff);
       G(Node_N_tp,Node_P_tp) = G(Node_N_tp,Node_P_tp) - 1/((a^2)*R_eff);
       G(Node_N_tp,Node_N_tp) = G(Node_N_tp,Node_N_tp) + 1/((a^2)*R_eff);
   else
       G(Node_P,Node_P_tp) = G(Node_P,Node_P_tp) - 1/(a*R_eff);
       G(Node_P,Node_N_tp) = G(Node_P,Node_N_tp) + 1/(a*R_eff);
       G(Node_P_tp,Node_P) = G(Node_P_tp,Node_P) - 1/(a*R_eff);
       G(Node_P_tp,Node_P_tp) = G(Node_P_tp,Node_P_tp) + 1/((a^2)*R_eff);
       G(Node_P_tp,Node_N_tp) = G(Node_P_tp,Node_N_tp) - 1/((a^2)*R_eff);
       G(Node_N_tp,Node_P) = G(Node_N_tp,Node_P) + 1/(a*R_eff);
       G(Node_N_tp,Node_P_tp) = G(Node_N_tp,Node_P_tp) - 1/((a^2)*R_eff);
       G(Node_N_tp,Node_N_tp) = G(Node_N_tp,Node_N_tp) + 1/((a^2)*R_eff);
   end

end

