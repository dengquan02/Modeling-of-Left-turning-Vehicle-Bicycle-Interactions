function [complete_acc] = acc_interpolation(acc,current_acc,timess,perception_time,generating_lengh)
%利用差值法对稀疏加速度补充完整
acc_input = [current_acc;acc];%将当前加速度放入最上面；
% perception_time = 25;%输入步长+预测步长
% generating_lengh = 9; %中间插值个数+2
% timess = size(acc_input,1);%输入加速度的个数

%% 开始插值
acc_all = [];
for i = 1 : timess-1
    start_acc = acc_input(i,:);
    end_acc = acc_input(i+1,:);
    inter_x = (end_acc(1) - start_acc(1))/(generating_lengh-1);%第1列插值单位长度
    inter_y = (end_acc(2) - start_acc(2))/(generating_lengh-1);%第2列插值单位长度
    acc_i = start_acc;%中间的插值
    for j = 1:generating_lengh-2  %这里应该是-2
        acc_i = [acc_i;[start_acc(1)+j*inter_x,end_acc(2)+j*inter_y]];
    end
    acc_all = [acc_all;acc_i];
end
complete_acc = acc_all;
%% 结束
end
        
        