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
%%
%%%%%%%%%%%%%%%% Error Estimation %%%%%%%%%%%%%%%%
prompt = {"Do you want to compute the error between Simulink and NIS method? Answer 'y' or 'n'"};
dlgtitle = "Input";
dims = [1 35];
answer = inputdlg(prompt,dlgtitle,dims);

if answer{1,1}== 'y' && strcmp(gcs,'Circuit')
    Vload = logsout{1}.Values.Data(:,1);
    Iload = logsout{2}.Values.Data(:,1);
    Verr = abs(Out(1,:) - Vload');
    Ierr = abs(Out(2,:) - Iload');
    figure;
    plot(time,Verr,'-k',time,Ierr,':k');
    legend('Verr','Ierr'); 
    xlabel('Time (Seconds)');
elseif answer{1,1}== 'y' && strcmp(gcs,'Tphase')
    Vag_load1 = logsout{1}.Values.Data(:,1);
    Vbg_load1 = logsout{1}.Values.Data(:,2);
    Vcg_load1 = logsout{1}.Values.Data(:,3);
    Iag_load1 = logsout{2}.Values.Data(:,1);
    Ibg_load1 = logsout{2}.Values.Data(:,2);
    Icg_load1 = logsout{2}.Values.Data(:,3);
    Vab_load2 = logsout{3}.Values.Data(:,1);
    Vbc_load2 = logsout{3}.Values.Data(:,2);
    Vca_load2 = logsout{3}.Values.Data(:,3);
    Iab_load2 = logsout{4}.Values.Data(:,1);
    Ibc_load2 = logsout{4}.Values.Data(:,2);
    Ica_load2 = logsout{4}.Values.Data(:,3);
    Vag_err1 = abs(Out(1,:) - Vag_load1');
    Vbg_err1 = abs(Out(2,:) - Vbg_load1');
    Vcg_err1 = abs(Out(3,:) - Vcg_load1');
    Iag_err1 = abs(Out(7,:) - Iag_load1');
    Ibg_err1 = abs(Out(8,:) - Ibg_load1');
    Icg_err1 = abs(Out(9,:) - Icg_load1');
    Vab_err2 = abs(Out(4,:) - Vab_load2');
    Vbc_err2 = abs(Out(5,:) - Vbc_load2');
    Vca_err2 = abs(Out(6,:) - Vca_load2');
    Iab_err2 = abs(Out(10,:) - Iab_load2');
    Ibc_err2 = abs(Out(11,:) - Ibc_load2');
    Ica_err2 = abs(Out(12,:) - Ica_load2');
    figure;
    subplot(1,2,1);
    plot(time,Vag_err1,'-k',time,Vbg_err1,':k',time,Vcg_err1,'-.k');
    legend('Vag_err1','Vbg_err1','Vcg_err1'); 
    xlabel('Time (Seconds)');
    subplot(1,2,2);
    plot(time,Vab_err2,'-k',time,Vbc_err2,':k',time,Vca_err2,'-.k');
    legend('Vab_err2','Vbc_err2','Vca_err2'); 
    xlabel('Time (Seconds)');
    figure;
    subplot(1,2,1);
    plot(time,Iag_err1,'-k',time,Ibg_err1,':k',time,Icg_err1,'-.k');
    legend('Iag_err1','Ibg_err1','Icg_err1'); 
    xlabel('Time (Seconds)');
    subplot(1,2,2);
    plot(time,Iab_err2,'-k',time,Ibc_err2,':k',time,Ica_err2,'-.k');
    legend('Iab_err2','Ibc_err2','Ica_err2'); 
    xlabel('Time (Seconds)');
end