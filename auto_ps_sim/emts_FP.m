%%
% Automatic microgrid analysis and solution script 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% System simulation parameters' evaluation %%%%
handle = getSimulinkBlockHandle(strcat(gcs,'/powergui'));
if ~strcmp(get_param(handle,'SolverType'),'Tustin')
    set_param(handle,'SolverType','Tustin'); % Trapezoidal Rule for numerical solution is selected
end
if ~strcmp(get_param(handle,'x0status'),'zero')
    set_param(handle,'x0status','zero'); % Zero Initial State
end
sps = power_analyze(gcs,'sort'); % Derive schematic information
Dt = sps.SampleTime; % Simulation Step
Start = str2num(get_param(gcs,'StartTime'));
Stop = str2num(get_param(gcs,'StopTime'));
time = Start:Dt:Stop;
count = 0;
%%
%%%%%%%%%%%%%% Power Plant Analysis %%%%%%%%%%%%%%
[rlc,src,outputs,G,G_br,No_Nodes,No_Brn,No_Src,No_Out,I_hs] = PPA(sps, Dt);
V_n = zeros(No_Nodes,1); % Nodal voltages
I_br = zeros(No_Brn,1); % Branch currents
Out = zeros(No_Out,size(time,2)); % Network Analysis simulation results for Error Estimation
[No_Vk, Vk_nodes, idx, G] = G_correction(src, G, No_Nodes, No_Src); % Correction of G matrix if voltage sources exist
src = [src, zeros(No_Src,1)];
if No_Vk ~= 0 % Voltage sources exist, G matrix is fragmented to Guu, Guk, Gku, Gkk
    G_UU = G(1:(No_Nodes-No_Vk),1:(No_Nodes-No_Vk)); 
    G_UU = inverse(G_UU, 1e-9);
    G_UK = G(1:(No_Nodes-No_Vk),(No_Nodes-No_Vk+1):No_Nodes);
else % Only current sources exist
    G = inverse(G, 1e-9);
end
for i=1:No_Src
    if src(i,6) == 0 % DC Source
        count = 1;
        break
    end
end
if count ~= 1 % AC sources only
    [V_n, I_br] = initial_state(time(1), rlc, src, No_Brn, No_Nodes, No_Src);
    Out = outp_assign(Out, outputs, No_Out, V_n, I_br, 1);
    count = 2;
end
%%
%%%%%%%%%%%%%%%%%%% Simulation %%%%%%%%%%%%%%%%%%%
while count <= size(time,2)
    % New values of sources
    for i=1:No_Src
        if src(i,6) ~= 0 % AC source
             src(i,8) = src(i,4)*sin(2*pi*src(i,6)*time(count) + src(i,5)*pi/180);
        else % DC source
            src(i,8) = src(i,4);
        end
    end
    Vk = Vk_assign(No_Vk, No_Src, idx, src); % Create known voltages vector, Vk
    I_hs = Ihs_assign(No_Brn, rlc, I_hs, V_n, I_br);
    I_history = I_history_assign(No_Nodes, No_Brn, No_Src, rlc, src, I_hs);
    
    if No_Vk ~= 0 % Voltage sources exist
        I_history = I_history_correction(I_history, Vk_nodes, No_Vk, No_Nodes);
        I_U = I_history(1:(No_Nodes-No_Vk),1); 
        V_U = Vnodal(I_history,I_U,G,G_UU,G_UK,Vk,1);
        % Assign nodal voltages in the correct order
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
    else % Only current sources exist
        V_n = Vnodal(I_history,[],G,[],[],0,0);
    end
    I_br = Ibr_assign(No_Brn,rlc,I_hs,V_n,G_br,I_br);
    
    Out = outp_assign(Out, outputs, No_Out, V_n, I_br, count);
    count = count + 1;
end
