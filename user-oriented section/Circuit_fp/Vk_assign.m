function [Vk] = Vk_assign(No_Vk, No_Src, idx, src)
    % Known voltage sources are assigned in Vk vector in the order
    % specified in idx vector, to be used in the simulation logic
    Vk = zeros(No_Vk,1);
    if No_Vk ~= 0
        count = 0;
        for i=1:No_Src
           if src(i,3) == 0 % Voltage Source
               count = count + 1;
               index = find(idx == count);
               if src(i,1) == 0
                   Vk(index) = -src(i,8);
               else
                   Vk(index) = src(i,8);
               end
           end
           if count == No_Vk
               break
           end
        end
    end
end

