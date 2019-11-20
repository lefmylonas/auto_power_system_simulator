function [I_history] = I_history_correction(I_history, Vk_nodes, No_Vk, No_Nodes)
    % This function corrects the current vector, which is the sum of the 
    % history current sources and external current sources, due to known
    % voltage sources following the logic of section 2.5
    for i=1:No_Vk
       temp = I_history(Vk_nodes(i,1),1);
       I_history(Vk_nodes(i,1):No_Nodes-1,1) = I_history((Vk_nodes(i,1)+1):No_Nodes,1);
       I_history(No_Nodes,1) = temp;
    end

end

