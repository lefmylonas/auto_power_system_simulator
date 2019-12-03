%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                          %
%           Generated by MATLAB 9.2 and Fixed-Point Designer 5.4           %
%                                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%#codegen
function [ I_history ] = fun2Ihistory_fixpt(I_history_1,I_source,c,Node_P_tp,Node_N_tp)
    % Transformer winding
    fm = get_fimath();
    I_history = fi(I_history_1, 1, 32, 17, fm);

    if Node_N_tp ~= fi(0, 1, 2, 0, fm)
         I_history(Node_P_tp) = fi(I_history(Node_P_tp) + I_source*c, 1, 32, 17, fm); 
         I_history(Node_N_tp) = fi_signed(I_history(Node_N_tp)) - I_source*c;
     else
         I_history(Node_P_tp) = fi(I_history(Node_P_tp) + I_source*c, 1, 32, 17, fm); 
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