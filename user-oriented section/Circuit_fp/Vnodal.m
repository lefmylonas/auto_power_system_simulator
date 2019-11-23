function [A] = Vnodal(I_history,I_U,G,G_UU,G_UK,Vk,flag)
    if flag == 1 % Known voltage sources exist
        I_d_history = I_U - G_UK*Vk;  
        V_U = G_UU*I_d_history;
        A = V_U;
    else % Only current sources exist
        V_n = G*I_history;
        A = V_n;
    end
end

