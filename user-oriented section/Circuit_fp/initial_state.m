function [V_n, I_br] = initial_state(time, rlc, src, No_Brn, No_Nodes, No_Src)
    flag = 0;
    G0 = zeros(No_Nodes,No_Nodes); % Zero Initial State Conductance Matrix
    Info = zeros(No_Brn,6); % Information about branches
    I_br = zeros(No_Brn,1); % Branch currents
    V_n = zeros(No_Nodes,1); % Nodal voltages
    I0 = zeros(No_Nodes,1); % Initial current sources' values vector
    Pr_Type = -1;
    for i=1:No_Brn
        Node_P = rlc(i,1); % Positive Node
        Node_N = rlc(i,2); % Negative Node
        Type = rlc(i,3);
        R = rlc(i,4); % Resistance in Ohms
        L = rlc(i,5) * 1e-3; % Inductance in mH
        if Type == 0 || Type == 1 % Serial/Parallel RLC branches
            C = rlc(i,6) * 1e-6; % Capacitance in uF
            if Type == 0 % Series branch
                if L ~= 0
                    Info(i,1) = 1;
                    Pr_Type = Type;
                    continue
                else
                    Info(i,2:4) = [1/R, Node_P, Node_N];
                end
            else % Parallel branch
                if C ~= 0
                    if Node_P == 0
                        Info(i,1:4) = [2, 4, Node_P, Node_N];
                    elseif Node_N == 0
                        Info(i,1:4) = [2, 3, Node_P, Node_N];
                    else
                        Info(i,1:4) = [2, 0, Node_P, Node_N];
                    end
                    Pr_Type = Type;
                    continue
                else
                    Info(i,2:4) = [1/R, Node_P, Node_N];
                end
            end
        elseif Type == 2 % Transformer branches - no magnetization branches
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
                 flag = 1;
             end
             if L ~= 0
                 flag = 0;
                 Info(i,1) = 1;
                 Pr_Type = Type;
                 continue
             else
                 Info(i,2:4) = [1/R, Node_P, Node_N];
             end
        elseif Type == 3 % Coupled (mutual) winding
             %
        elseif Type < 0 % Transmission line modeled by a PI section of length |type|
             %
        end
        % RLC branches-related cells assignment
        if Node_P ~= 0 && Node_N ~= 0
            G0(Node_P,Node_P) = G0(Node_P,Node_P) + Info(i,2); 
            G0(Node_N,Node_N) = G0(Node_N,Node_N) + Info(i,2); 
            G0(Node_P,Node_N) = G0(Node_P,Node_N) - Info(i,2); 
            G0(Node_N,Node_P) = G0(Node_N,Node_P) - Info(i,2); 
        elseif Node_N == 0
            G0(Node_P,Node_P) = G0(Node_P,Node_P) + Info(i,2); 
        else
            G0(Node_N,Node_N) = G0(Node_N,Node_N) + Info(i,2);
        end 
        % Transformer branches-related cells correction
        if flag
           flag = 0;
           G0 = Transformer_correction(G0, Node_P, Node_N, Node_P_tp, Node_N_tp, a, 1/Info(i,2));
        end

        Pr_Type = Type;
    end
    for i=1:No_Src % Initial values for sources
        if src(i,6) ~= 0 % AC source
            src(i,8) = src(i,4)*sin(2*pi*src(i,6)*time + src(i,5)*pi/180);
        else % DC source
            src(i,8) = src(i,4);
        end
        if src(i,3) == 1 % Current source
           Is = src(i,8);
           Node_P = src(i,1);
           Node_N = src(i,2);
           % Assign values to I0 vector
           if Node_P ~= 0 && Node_N ~= 0
               I0(Node_N) = I0(Node_N) + Is; 
               I0(Node_P) = I0(Node_P) - Is; 
           elseif Node_N ~= 0 
               I0(Node_N) = I0(Node_N) + Is;
           elseif Node_P ~= 0 
               I0(Node_P) = I0(Node_P) - Is;  
           end 
       end
    end
    for i=1:No_Brn
       if Info(i,1) == 2 % Parallel RLC branch with existing capacitance
           if Info(i,2) == 0 % Non-zero node values
               Node_P = Info(i,3);
               Node_N = Info(i,4);
               if Node_P > Node_N
                   Node_1 = Node_N;
                   Node_2 = Node_P;
               else
                   Node_1 = Node_P;
                   Node_2 = Node_N;
               end
               % The branch is a short circuit, so the information of Node 
               % 2 is added to Node 1 for right simulation. The row and
               % column of Node 2 are set to zero and I0 vector is corrected
               Info(i,3:4) = [Node_1, Node_2];
               temp = [G0(1:Node_1-1,Node_2) + G0(1:Node_1-1,Node_1); G0(Node_1,Node_1) + G0(Node_2,Node_2); ...
                   G0(Node_1+1:Node_2-1,Node_2) + G0(Node_1+1:Node_2-1,Node_1); 0; G0(Node_2+1:No_Nodes,Node_2) + G0(Node_2+1:No_Nodes,Node_1)];
               G0(Node_1,:) = G0(Node_2,:) + G0(Node_1,:);
               I0(Node_1,1) = I0(Node_2,1) + I0(Node_1,1);
               G0 = [G0(1:Node_2-1,1:Node_2-1), zeros(Node_2-1,1), G0(1:Node_2-1,Node_2+1:No_Nodes); zeros(1,No_Nodes); ...
                   G0(Node_2+1:No_Nodes,1:Node_2-1), zeros(No_Nodes-Node_2,1), G0(Node_2+1:No_Nodes,Node_2+1:No_Nodes)];
               I0 = [I0(1:Node_2-1,1); 0; I0(Node_2+1:No_Nodes,1)];
               G0(:,Node_1) = temp;
           else
               % The non-zero node is connected to ground directly
               Node_Gr = Info(i,Info(i,2));
               G0 = [G0(:,1:Node_Gr-1), zeros(No_Nodes,1), G0(:,Node_Gr+1:No_Nodes)];
           end
       end
    end
    % Known voltage sources demand the correction of conductance matrix G0
    [No_Vk, Vk_nodes, idx, G0] = G_correction(src, G0, No_Nodes, No_Src);
    if No_Vk ~= 0
        G0_UU = G0(1:(No_Nodes-No_Vk),1:(No_Nodes-No_Vk)); 
        G0_UU = inverse(G0_UU, 1e-9);
        G0_UK = G0(1:(No_Nodes-No_Vk),(No_Nodes-No_Vk+1):No_Nodes);
    else
        G0 = inverse(G0, 1e-9);
    end
    Vk = Vk_assign(No_Vk, No_Src, idx, src);
    for i=1:No_Vk
       temp = I0(Vk_nodes(i,1),1);
       I0(Vk_nodes(i,1):No_Nodes-1,1) = I0((Vk_nodes(i,1)+1):No_Nodes,1);
       I0(No_Nodes,1) = temp;
    end
    % Zero Initial State System Solution
    if No_Vk ~= 0
        I0_U = I0(1:(No_Nodes-No_Vk),1); 
        V_U = Vnodal(I0,I0_U,G0,G0_UU,G0_UK,Vk,1);
        c = 0;
        for i=1:No_Nodes
            if any(find(Vk_nodes == i))
                index = find(Vk_nodes == i);
                V_n(i) = Vk(index);
            else
                c = c + 1;
                V_n(i) = V_U(c);
            end
        end
    else
        V_n = Vnodal(I0,[],G0,[],[],0,0);
    end
    % Short circuit branch nodal voltages are updated
    for i=1:No_Brn
        if Info(i,1) == 2 && Info(i,2) == 0
            V_n(Info(i,4)) = V_n(Info(i,3)); 
        end
    end
    % Branch currents for resistive branches
    for i=1:No_Brn
        if Info(i,1) == 1
            continue
        elseif Info(i,1) == 0
            Node_P = Info(i,3);
            Node_N = Info(i,4);
            if Node_P ~= 0 && Node_N ~= 0
                I_br(i) = Info(i,2)*(V_n(Node_P) - V_n(Node_N));
            elseif Node_N == 0
                I_br(i) = Info(i,2)*V_n(Node_P);
            else
                I_br(i) = Info(i,2)*(- V_n(Node_N));
            end
        end
    end
    % Branch currents for short circuit branches
    for i=1:No_Brn
        if Info(i,1) == 2
            if Info(i,2) == 0
                Info(i,6) = Info(i,3);
            else
                Info(i,6) = Info(i,Info(i,2)); % Non-zero node
            end
            for j=1:No_Brn
               if Info(j,1) ~= 2
                  if Info(j,3) == Info(i,6) || Info(j,4) == Info(i,6)
                      if Info(j,3) == Info(i,6)
                         Info(i,5) = Info(i,5) - I_br(j);
                      else
                         Info(i,5) = Info(i,5) + I_br(j);
                      end
                  end
               end
            end
            I_br(i) = Info(i,5);
        end
    end
end
