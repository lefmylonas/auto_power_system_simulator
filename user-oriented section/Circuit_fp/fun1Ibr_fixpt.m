%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                          %
%           Generated by MATLAB 9.2 and Fixed-Point Designer 5.4           %
%                                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%#codegen
function [ out1 ] = fun1Ibr_fixpt(V_n,G_br,coeftr,Ih,Node_P,Node_N,Node_P_tp,Node_N_tp)
     % Transformer winding
     fm = get_fimath();

     if Node_N_tp ~= fi(0, 1, 2, 0, fm) && Node_P ~= fi(0, 1, 2, 0, fm) && Node_N ~= fi(0, 1, 2, 0, fm)
        out1 = fi(fi_signed(G_br*(fi_signed(V_n(Node_P)) - V_n(Node_N))) - coeftr*(fi_signed(V_n(Node_P_tp)) - V_n(Node_N_tp)) + Ih, 1, 32, 17, fm);
     elseif Node_N_tp == fi(0, 1, 2, 0, fm) && Node_P == fi(0, 1, 2, 0, fm)
        out1 = fi(fi_signed(G_br*(fi_uminus(V_n(Node_N)))) - coeftr*V_n(Node_P_tp) + Ih, 1, 32, 17, fm);
     elseif Node_N_tp == fi(0, 1, 2, 0, fm) && Node_N == fi(0, 1, 2, 0, fm)
        out1 = fi(fi_signed(G_br*V_n(Node_P)) - coeftr*V_n(Node_P_tp) + Ih, 1, 32, 17, fm);
     elseif Node_N_tp == fi(0, 1, 2, 0, fm)
        out1 = fi(fi_signed(G_br*(fi_signed(V_n(Node_P)) - V_n(Node_N))) - coeftr*V_n(Node_P_tp) + Ih, 1, 32, 17, fm);
     elseif Node_P == fi(0, 1, 2, 0, fm)
        out1 = fi(fi_signed(G_br*(fi_uminus(V_n(Node_N)))) - coeftr*(fi_signed(V_n(Node_P_tp)) - V_n(Node_N_tp)) + Ih, 1, 32, 17, fm);
     else
        out1 = fi(fi_signed(G_br*V_n(Node_P)) - coeftr*(fi_signed(V_n(Node_P_tp)) - V_n(Node_N_tp)) + Ih, 1, 32, 17, fm);
     end

end



function y = fi_signed(a)
    coder.inline( 'always' );
    if isfi( a ) && ~(issigned( a ))
        nt = numerictype( a );
        new_nt = numerictype( 1, nt.WordLength + 1, nt.FractionLength );
        y = fi( a, new_nt, fimath( a ) );
    else
        y = a;
    end
end


function y = fi_uminus(a)
    coder.inline( 'always' );
    if isfi( a )
        nt = numerictype( a );
        new_nt = numerictype( 1, nt.WordLength + 1, nt.FractionLength );
        y = -fi( a, new_nt, fimath( a ) );
    else
        y = -a;
    end
end

function fm = get_fimath()
	fm = fimath('RoundingMethod', 'Floor',...
	     'OverflowAction', 'Wrap',...
	     'ProductMode','FullPrecision',...
	     'MaxProductWordLength', 128,...
	     'SumMode','FullPrecision',...
	     'MaxSumWordLength', 128);
end