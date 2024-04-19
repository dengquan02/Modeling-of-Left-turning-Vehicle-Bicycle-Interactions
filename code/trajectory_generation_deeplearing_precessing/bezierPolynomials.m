function [res] = bezierPolynomials(s,alpha)
% s在[0,1]之间 alpha决定着曲线的形状
    M = size(alpha,2)-1;% 只需要设定alpha的大小M就确定了
    M_factorial = factorial(M);
    res = 0;
    for k = 0:1:M
       res = res + M_factorial/(factorial(k)*factorial(M-k))*alpha(k+1)*s^k*(1-s)^(M-k);
    end
end
