function [No_Vk, Vk_nodes, idx, G] = G_correction(src, G, No_Nodes, No_Src)

    Vk_nodes = [];
    idx = [];
    % Vector of known voltage nodes 
    for i=1:No_Src
        if src(i,3) == 0 % Voltage Source
            Vk_nodes(end+1,:) = src(i,1:2); 
        end
    end
    No_Vk = size(Vk_nodes,1); % Number of known voltage sources
    % Voltage sources must have 1 zero node
    % Non-zero nodes are kept
    for i=1:No_Vk
        if Vk_nodes(i,1) ~= 0 && Vk_nodes(i,2) ~= 0 
            error('Voltage source with no grounded terminal was found. Please ground your desired terminal in order to continue');
        end
        if Vk_nodes(i,1) == 0
            Vk_nodes(i,1) = Vk_nodes(i,2);
        end
    end
    % Non-zero nodes are sorted in descending order
    if No_Vk ~= 0
        [Vk_nodes,idx] = sort(Vk_nodes(:,1),'descend');
    end
    % Conductance matrix correction
    for i=1:No_Vk
       % Associated row is placed last in matrix in order to accumulate all
       % known voltage sources' currents in last rows, as in section 2.5
       % analysis
       temp = G(Vk_nodes(i,1),:);
       G(Vk_nodes(i,1):No_Nodes-1,:) = G((Vk_nodes(i,1)+1):No_Nodes,:);
       G(No_Nodes,:) = temp;
       % Associated column is placed last in matrix in order to accumulate 
       % all known nodal voltages in last columns, as in section 2.5 
       % analysis
       temp = G(:,Vk_nodes(i,1));
       G(:,Vk_nodes(i,1):No_Nodes-1) = G(:,(Vk_nodes(i,1)+1):No_Nodes);
       G(:,No_Nodes) = temp;
    end

end

