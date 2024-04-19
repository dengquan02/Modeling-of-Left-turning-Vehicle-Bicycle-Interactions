function [output] = Curvature_calculation(input1,input2)
%计算曲率
% %% 原始数据
% % x0 = 0 : 0.1 : 2 * pi;
% % y0 = sin(x0).*cos(x0);
% % x0=input1;
% % y0=input2;
% 
% aplha=0:pi/40:2*pi;
% r=2;
% x0=r*cos(aplha);
% y0=r*sin(aplha);
% scatter(x0,y0);
% 
% h = abs(diff([x0(2), x0(1)]));
% 
% %%一阶导
% ythe1 = cos( x0 ) .^2 - sin(x0).^2; %理论一阶导
% yapp1 = gradient(y0, h); %matlab数值近似
% 
% % hold on;
% % plot(x0, ythe1, '.');
% % plot(x0, yapp1, 'r');
% % legend('理论值', '模拟值');
% % title('一阶导');
% 
% %%二阶导
% ythe2 = (-4) * cos(x0) .* sin(x0); %理论二阶导
% yapp2 = 2 * 2 * del2(y0, h);       %matlab数值近似
% 
% % figure
% % hold on;
% % plot(x0, ythe2,'.');
% % plot(x0, yapp2,'r');
% % legend('理论值', '模拟值');
% % title('二阶导');
% 
% %% 模拟曲率
% syms x y
% y = sin(x) * cos(x);
% yd2 = diff(y, 2);
% yd1 = diff(y, 1);
% k = (yd2) / (1+yd1^2)^(3/2);  %% 曲率公式   k = abs(yd2) / (1+yd1^2)^(3/2);  %% 曲率公式
% cc1 = subs(k, x, x0);
% cc2 = (yapp2)./(1+yapp1.^2).^(3/2);  %原来是绝对值：cc2 = abs(yapp2)./(1+yapp1.^2).^(3/2);
% bar(cc2)
% % figure
% % hold on;
% % plot(x0, cc1, '.');
% % plot(x0, cc2, 'r');
% % legend('理论值', '模拟值');
% % title('曲率');
% output = cc2;%输出曲率值

%% 新代码
input1=[1;2;1;1]   ;             %traj_points(:,1);     %E_trajectory(find(E_trajectory(:,1)==1),4);
input2=[1;1;2;1] ;                  %traj_points(:,2);    %E_trajectory(find(E_trajectory(:,1)==1),5);
kappa_arr = [];
posi_arr = [];
norm_arr = [];

for num = 2:(length(input1)-1)
    x = input1(num-1:num+1,:)';
    y = input2(num-1:num+1,:)';
    [kappa,norm_l] = PJcurvature(x,y);
    posi_arr = [posi_arr;[x(2),y(2)]];
    kappa_arr = [kappa_arr;kappa];
    norm_arr = [norm_arr;norm_l];
end
kappa_arr = [0;kappa_arr;0];
output = kappa_arr ;%输出曲率

end
