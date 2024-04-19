function [R] = draw_danger(R,e,char)
e=0.8/2;%离心率
char = 1;%标定参数
angle = 0:0.1:2*pi;%角度
r = 0:0.1:10;
for i = 1:63
    for j = 1:101
   R(j,i) = (char*(1-e^2))/(r(1,j)*(1-e*cos(angle(1,i))));
    end
end
polarplot3d(R);
end
%侵入距离和危险度的图像，我使用了正切函数
x = 0:0.1:45;
plot(x,(6*(2.^(-x))),'r')
hold on
plot(x,(10*(2.^(-x))),'b')