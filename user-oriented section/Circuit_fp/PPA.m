function [rlc,src,outputs,G,G_br,No_Nodes,No_Brn,No_Src,No_Out,I_hs] = PPA(sps, Dt)
    rlc = sps.RlcBranch; % Topology matrix of linear elements
    src = sps.SourceBranch; % Sources' matrix
    outputs = sps.OutputMatrix; % Outputs' matrix
    No_Brn = size(rlc,1); % Number of branches
    No_Src = size(src,1); % Number of sources
    No_Out = size(outputs,1); % Number of outputs
    % Node vector without the ground node
    PA_nodes = unique([rlc(:,1)' rlc(:,2)']); 
    if any(find(PA_nodes == 0))
        PA_nodes=PA_nodes(PA_nodes ~= 0);
    end
    No_Nodes = size(PA_nodes,2); % Number of nodes
    flag = 0;
    % Correction of topology matrix for (R)LC components
    for i=1:No_Brn
        Type = rlc(i,3);
        L = rlc(i,5); % Inductance
        C = rlc(i,6); % Capacitance
        if (Type == 0 || Type == 1) && L ~= 0 && C ~= 0
            if Type == 0
                No_Brn = No_Brn + 1;
                No_Nodes = No_Nodes + 1;
                rlc(end+1,:) = [No_Nodes,rlc(i,2),1,0,0,C,No_Brn];
                PA_nodes(1,end+1) = No_Nodes;
                rlc(i,2) = No_Nodes;
                rlc(i,6) = 0;
            else
                No_Brn = No_Brn + 1;
                rlc(end+1,:) = [rlc(i,1),rlc(i,2),1,0,0,C,No_Brn];
                rlc(i,6) = 0;
            end
        end
    end
    I_hs = zeros(No_Brn,5); % History current sources information matrix
    G = zeros(No_Nodes,No_Nodes); % Conductance matrix
    G_br = zeros(No_Brn,1); % Branch conductance vector
    % Assignment of correct node numbers in topology matrix
    Pr_Type = -1;
    for i=1:No_Brn
        Node_P = rlc(i,1);
        Node_N = rlc(i,2);
        Type = rlc(i,3);
        if Node_P ~= 0
            rlc(i,1) = find(PA_nodes == Node_P);
        end
        if Node_N ~= 0
            rlc(i,2) = find(PA_nodes == Node_N);
        end
        if (Type == 2) && (Pr_Type ~= 2)
            rlc(i,2) = find(PA_nodes == rlc(i+2,1));
        end
        Pr_Type = Type;
    end
    % Assignment of correct node numbers in sources' matrix
    for i=1:No_Src
        Node_P = src(i,1);
        Node_N = src(i,2);
        if Node_P ~= 0
            src(i,1) = find(PA_nodes == Node_P);
        end
        if Node_N ~= 0
            src(i,2) = find(PA_nodes == Node_N);
        end
    end
    % Assignment of correct node numbers in outputs' matrix
    for i=1:No_Out
        if size(outputs{i,1},2) == 2 % Voltage Output
            Node_P = outputs{i,1}(1,1);
            Node_N = outputs{i,1}(1,2);
            if Node_P ~= 0
                outputs{i,1}(1,1) = find(PA_nodes == Node_P);
            end
            if Node_N ~= 0
                outputs{i,1}(1,2) = find(PA_nodes == Node_N);
            end
        end
    end
    % Conductance matrix evaluation
    Pr_Type = -1;
    for i=1:No_Brn
        Node_P = rlc(i,1); % Positive Node
        Node_N = rlc(i,2); % Negative Node
        Type = rlc(i,3);
        R = rlc(i,4); % Resistance in Ohms
        L = rlc(i,5) * 1e-3; % Inductance in mH
        if Type == 0 || Type == 1 % Serial/Parallel RLC branches
            C = rlc(i,6) * 1e-6; % Capacitance in uF
            count = branch_type(R, L, C);
            if Type == 0 % Series branch
                if C ~= 0 % RC
                    R_eff = R + Dt/(2*C);
                else % RL
                    R_eff = R + 2*L/Dt;
                end
                I_hs(i,:) = Branch_Ihs(Node_P, Node_N, R_eff, R, C, Dt, count, 0);
            else % Parallel branch
                if R ~= 0 && L ~= 0 % RL
                    R_eff = 1/(1/R + Dt/(2*L));
                elseif R ~= 0 && C ~= 0 % RC
                    R_eff = 1/(1/R + 2*C/Dt);
                elseif R ~= 0 && (L == 0 || C == 0)
                    R_eff = R;
                elseif R == 0 && L ~= 0
                    R_eff = 2*L/Dt;
                else
                    R_eff = Dt/(2*C);
                end
                I_hs(i,:) = Branch_Ihs(Node_P, Node_N, R_eff, R, C, Dt, count, 1);
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
             R_eff = R + 2*L/Dt;
             I_hs(i,:) = Branch_Ihs(Node_P, Node_N, R_eff, R, 0, 0, 5, 0);
        elseif Type == 3 % Coupled (mutual) winding
             %
        elseif Type < 0 % Transmission line modeled by a PI section of length |type|
             %
        end
        G_br(i,1) = 1/R_eff;
        % RLC branches-related cells assignment
        if Node_P ~= 0 && Node_N ~= 0
            G(Node_P,Node_P) = G(Node_P,Node_P) + 1/R_eff; 
            G(Node_N,Node_N) = G(Node_N,Node_N) + 1/R_eff; 
            G(Node_P,Node_N) = G(Node_P,Node_N) - 1/R_eff; 
            G(Node_N,Node_P) = G(Node_N,Node_P) - 1/R_eff; 
        elseif Node_N == 0
            G(Node_P,Node_P) = G(Node_P,Node_P) + 1/R_eff; 
        else
            G(Node_N,Node_N) = G(Node_N,Node_N) + 1/R_eff;
        end 
        % Transformer branches-related cells correction
        if flag
           flag = 0;
           G = Transformer_correction(G, Node_P, Node_N, Node_P_tp, Node_N_tp, a, R_eff);
        end

        Pr_Type = Type;
    end
end