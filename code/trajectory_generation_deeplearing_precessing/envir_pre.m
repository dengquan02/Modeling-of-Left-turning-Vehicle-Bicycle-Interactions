function [ext_time] = envir_pre(ext,perception_time)
%使用恒速度等预测方法对周围环境进行预测
% 输入值是客体的位置1-2表示xy，3-4表示VxVy，以此类推
time_step = perception_time;%预测步长
% 开始预测
point_index = 1;%从第point_index个点开始预测；
ext_time = [];%预测好的未来客体位置
while point_index <=size(ext,1)
   Vx = [ext(point_index,3)/(1/0.12),ext(point_index,4)/(1/0.12)];%提取point_index的速度 除以一个系数是因为速度单位是m/s，换算到一个步长
   traj_pre = [ext(point_index,1),ext(point_index,2)];%第point_index个点
   for i = 1:time_step
       traj_pre = [traj_pre;[(traj_pre(i,1)+Vx(1,1)),(traj_pre(i,2)+Vx(1,2))]];%恒速度预测
   end
%    clf
%    scatter(traj_pre(:,1),traj_pre(:,2),'*','r');
%    hold on
%    scatter(ext(point_index:(point_index+time_step),1),ext(point_index:(point_index+time_step),2),'*','b');
%    pause(0.5)
   ext_time = [ext_time traj_pre];%提取每个客体的未来的预测值
   point_index = point_index+1;
end
end

