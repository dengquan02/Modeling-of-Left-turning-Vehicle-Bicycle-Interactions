function [output_Curve] = PonitsCurve_calculation(input_traj_points)
%计算相邻点的角度
% input_traj_points = traj_points;  %输入测试数据
%% 开始计算
output_Curve = zeros(size(input_traj_points,1),1);
for i = 2 : size(input_traj_points,1)-1    
    line1 = input_traj_points(i+1,:)-input_traj_points(i,:);  %i+1和i的线段
    line2 = input_traj_points(i,:)-input_traj_points(i-1,:);  %i+1和i的线段
    line1 = line1/norm(line1);%单位话
    line2 = line2/norm(line2);
    sigma = acos(dot(line1,line2)/(norm(line1)*norm(line2)));
    Angle_diff = sigma/pi*180;
    output_Curve(i,1) = Angle_diff;
end
end