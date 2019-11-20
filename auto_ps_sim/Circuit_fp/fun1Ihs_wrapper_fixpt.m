%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                          %
%           Generated by MATLAB 9.2 and Fixed-Point Designer 5.4           %
%                                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out1 = fun1Ihs_wrapper_fixpt(I_br,V_n,coef1,coef2,coeftr,Node_P,Node_N,Node_P_tp,Node_N_tp)
    fm = get_fimath();
    I_br_in = fi( I_br, 1, 32, 17, fm );
    V_n_in = fi( V_n, 1, 32, 17, fm );
    coef1_in = fi( coef1, 1, 32, 17, fm );
    coef2_in = fi( coef2, 1, 32, 17, fm );
    coeftr_in = fi( coeftr, 1, 32, 17, fm );
    Node_P_in = fi( Node_P, 1, 3, 0, fm );
    Node_N_in = fi( Node_N, 1, 2, 0, fm );
    Node_P_tp_in = fi( Node_P_tp, 1, 4, 0, fm );
    Node_N_tp_in = fi( Node_N_tp, 1, 2, 0, fm );
    [out1_out] = fun1Ihs_fixpt( I_br_in, V_n_in, coef1_in, coef2_in, coeftr_in, Node_P_in, Node_N_in, Node_P_tp_in, Node_N_tp_in );
    out1 = double( out1_out );
end

function fm = get_fimath()
	fm = fimath('RoundingMethod', 'Floor',...
	     'OverflowAction', 'Wrap',...
	     'ProductMode','FullPrecision',...
	     'MaxProductWordLength', 128,...
	     'SumMode','FullPrecision',...
	     'MaxSumWordLength', 128);
end
