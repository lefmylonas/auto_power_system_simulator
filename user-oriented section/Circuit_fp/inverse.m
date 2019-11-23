function [Ainv] = inverse(A, Thres)
    [U, S, V] = svd(A);
    s = diag(S);
    k = sum(s> Thres);
    Ainv = V(:, 1:k)* diag(1./ s(1:k))* (U(:, 1:k)');
end

