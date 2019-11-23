function [count] = branch_type(R, L, C)
    count = 0;
    if R ~= 0 
        count = count + 2; 
    end
    if L ~= 0 
        count = count + 3; 
    end
    if C ~= 0 
        count = count + 4; 
    end
end

