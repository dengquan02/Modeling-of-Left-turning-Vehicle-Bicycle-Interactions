%%数据分割%%%%
function [x_train_output,y_train_output] = input_improving(x_train,y_train,N_lengh_point) %start_point_test,ratio_test,mmin,mmax
% 利用交通知识把输入值改进一些，让其能更好的的专注于学习生成轨迹点的特点；
% 各个点位置均减去了起点位置；
%% 对x处理
x_train_processing = x_train;
for i = 1:N_lengh_point:size(x_train,2)
    x_train_processing(:,i:i+1) = x_train(:,i:i+1)-x_train(:,1:2);
end
x_train_output = x_train_processing;
x_train_output(:,1:2) = x_train(:,1:2);%原始起点赋予处理后的矩阵；
% x_train_output = [x_train_output(:,1:i-1) zeros(size(x_train,1),2) x_train_output(:,i:size(x_train,2)) ones(size(x_train,1),2)];

%% 对y处理；
y_train_output = y_train;
y_train_output(:,1:2) = y_train(:,1:2)-x_train_processing(:,1:2);%按照起点归一化
proportion_1 = (y_train_output(:,1) - x_train(:,1))./(x_train_output(:,i+2));
proportion_2 = (y_train_output(:,2) - x_train(:,2))./(x_train_output(:,i+3));
proportion = [proportion_1 proportion_2];
y_train_output = [y_train_output proportion];%将比例放到最后，中间点占起终点的比例
end