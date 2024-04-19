function [Risk] = risk_3D(input,extract,intrusion_cood_E,G,R_b,k1,k3,char_intrusion,char_end,index_end,char_intrusion_right,char_end_right,index_end_right)
%做风险场的图
% input=pre_point;
% extract=extract_time_i(2:size(extract_time_i,1),:);
%以前小范围内的风险图
[x,y] = meshgrid([-45:0.1:10],[15:0.1:35]);
% x = input(1,1) + x;%x往右变大
% y = input(1,2) + y;%y往下变大
%整个交叉口的风险图
% x = meshgrid(-45:0.1:10);
% y = meshgrid(15:0.1:35);
% x = -45:0.1:10;
% y = 15:0.1:35;

Risk = zeros(size(x,1),size(y,2));
for i = 1:size(x,1)
    for j = 1:size(y,2)
        truth_Risk = Risk_calculation([x(i,j),y(i,j)],extract,intrusion_cood_E,G,R_b,k1,k3,char_intrusion,char_end,index_end,char_intrusion_right,char_end_right,index_end_right);%计算当前点的风险；
        Risk(i,j) = norm(truth_Risk);
    end
end
figure;
% disp(Risk)
mesh(x,y,Risk)
% view([0,0,1])
% axis([-45 10 15 35 0 4]);
end

