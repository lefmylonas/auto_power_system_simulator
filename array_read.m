function [A] = array_read(name,dim1,dim2,wl,fl)
    A = zeros(dim1,dim2);
    file = strcat(name,'.txt');
    fileID = fopen(file,'r');
    for j=1:dim2
        for i=1:dim1
            v = bin2dec(fscanf(fileID,'%s',1));
            if v > 2^(wl-1)-1
                v = v - 2^(wl);
            end
            A(i,j) = v*(2^(-fl));
        end
    end
    fclose(fileID);
end