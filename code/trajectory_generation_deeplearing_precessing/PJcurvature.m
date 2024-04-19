function [kappa,norm_k] = PJcurvature(x,y)
    %计算曲率  kappa表示曲率吧应该


    x = reshape(x,3,1);
    y = reshape(y,3,1);
    t_a = norm([x(2)-x(1),y(2)-y(1)]);
    t_b = norm([x(3)-x(2),y(3)-y(2)]);
    
    M =[[1, -t_a, t_a^2];
        [1, 0,    0    ];
        [1,  t_b, t_b^2]];

    a =  pinv(x)*M;%M\x;
    b =  pinv(y)*M;   %M\y;%

    kappa  = 2.*(a(3)*b(2)-b(3)*a(2)) / (a(2)^2.+b(2)^2.)^(1.5)*sign(a/b);
    norm_k =  [b(2),-a(2)]/sqrt(a(2)^2.+b(2)^2.);
end
