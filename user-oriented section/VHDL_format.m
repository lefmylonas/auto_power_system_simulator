%%
% Automatic microgrid analysis and solution script 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% System simulation parameters' evaluation %%%%
handle = getSimulinkBlockHandle(strcat(gcs,'/powergui'));
if ~strcmp(get_param(handle,'SolverType'),'Tustin')
    set_param(handle,'SolverType','Tustin');
end
if ~strcmp(get_param(handle,'x0status'),'zero')
    set_param(handle,'x0status','zero');
end
sps = power_analyze(gcs,'sort');
Dt = sps.SampleTime;
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
prompt = {"Enter word length:","Enter fraction length:","Text files' generation (1) or Simulink/VHDL error estimation (2)?"};
dlgtitle = "Input";
dims = [1 35];
answer = inputdlg(prompt,dlgtitle,dims);
wl=str2num(answer{1,1});
fl = str2num(answer{2,1});
choice = str2num(answer{3,1});

if choice == 1
    %%%%%%%%%%%% Format for VHDL template %%%%%%%%%%%%
    fileID = fopen('coeffs.txt','w'); % Text File = "coeffs.txt"
    wl_f = fi(wl,0,15,0);
    fl_f = fi(fl,0,15,0);
    Nodes_f = fi(No_Nodes,1,15,0);
    Brn_f = fi(No_Brn,0,15,0);
    Src_f = fi(No_Src,0,15,0);
    Vk_f = fi(No_Vk,0,15,0);
    if count == 1 
       time_f = fi(size(time,2),0,15,0); 
    else
       time_f = fi(size(time,2)-1,0,15,0); 
    end
    fprintf(fileID,'%s\r\n%s\r\n',wl_f.bin,fl_f.bin);
    fprintf(fileID,'%s\r\n%s\r\n',Nodes_f.bin,Brn_f.bin);
    fprintf(fileID,'%s\r\n%s\r\n',Src_f.bin,Vk_f.bin);
    fprintf(fileID,'%s\r\n',time_f.bin);
    fclose(fileID);

    BrnInfo = [rlc(:,1:2), zeros(No_Brn,3)];
    Pr_Type = -1;
    for i=1:No_Brn
       Type = rlc(i,3);
       if Type == 2
            if Pr_Type ~= 2
                % Primary winding
                U1 = rlc(i,6);
            else
                % Secondary winding
                U2 = rlc(i,6);
                a_inv = U2/U1; % Transformer's inverse turns ratio
                BrnInfo(i,3) = a_inv;
                BrnInfo(i,4) = I_hs(i,3)*a_inv;
                BrnInfo(i,5) = G_br(i)*a_inv;
                Pr_Type = Type;
                continue;
            end
       end
       Pr_Type = Type;
    end
    array_print('BrnInfo',BrnInfo(:,1:2),10,0);
    array_print('Transf',BrnInfo(:,3:5),wl,fl);

    IsInfo = zeros(No_Src-No_Vk,2);
    I_s = zeros(No_Src-No_Vk,size(time,2));
    j = 0;
    for i=1:No_Src
       if src(i,3) == 1 % Current source
           j = j + 1;
           IsInfo(j,:) = src(i,1:2);
           I_s(j,:) = src(i,4)*sin(2*pi*src(i,6).*time + src(i,5)*pi/180);
       end
    end
    if count == 2 
        I_s = I_s(:,2:end);
    end
    array_print('IsInfo',IsInfo,10,0);
    array_print('I_s',I_s,wl,fl);

    if No_Vk ~= 0 % Voltage sources exist
        array_print('G_UU',G_UU,wl,fl);
        array_print('G_UK',G_UK,wl,fl);
    else % Only current sources exist
        array_print('G',G,wl,fl);
    end
    array_print('G_br',G_br,wl,fl);
    array_print('I_hs',I_hs(:,3:4),wl,fl);

    array_print('V_n',V_n,wl,fl);
    V_branch = zeros(No_Brn,1);
    for i=1:No_Brn
        if BrnInfo(i,1) ~= 0 && BrnInfo(i,2) ~= 0
            V_branch(i,1) = V_n(BrnInfo(i,1)) - V_n(BrnInfo(i,2));
        elseif BrnInfo(i,1) == 0
            V_branch(i,1) = - V_n(BrnInfo(i,2));
        else
            V_branch(i,1) = V_n(BrnInfo(i,1));
        end
    end
    array_print('V_branch',V_branch,wl,fl);

    array_print('I_br',I_br,wl,fl);
elseif choice == 2
    %%%%% Error Estimation after VHDL simulation %%%%%
    Vnodal_report = array_read('Vnodal_report',No_Nodes,size(time,2),wl,fl);
    Ibranch_report = array_read('Ibranch_report',No_Brn,size(time,2),wl,fl);
    Vload = logsout{1}.Values.Data(:,1);
    Iload = logsout{2}.Values.Data(:,1);
    Verr = abs(Vnodal_report(1,:) - Vload');
    Ierr = abs(Ibranch_report(2,:) - Iload');
    figure;
    plot(time,Verr,'-k',time,Ierr,':k');
    legend('Verr','Ierr'); 
    xlabel('Time (Seconds)');
end