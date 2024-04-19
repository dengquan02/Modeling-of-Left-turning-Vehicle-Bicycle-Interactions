function [Potential_trajectory_allData_output] = Anti_normalizating_NEW(Potential_trajectory_allData,perception_time,mmax,mmin)
% 反归一化  输进来的是窄矩阵  输出去的还是窄矩阵

% csvwrite('mmax(20210831_1).csv',mmax);%写出最大值数据
% csvwrite('mmin(20210831_1).csv',mmin);%写出最小值数据

%% 输入参数
% mmax = csvread('mmax(20210831_1).csv');%读最大值数据
% mmin = csvread('mmin(20210831_1).csv');%读最小值数据
N_lengh_point = size(mmax,2);%读取特征数

%% 开始运算
% Potential_trajectory_allData_1 = reshape(Potential_trajectory_allData',N_lengh_point,[])';%变成窄矩阵  N_lengh_point是特征数；
[Potential_trajectory_allData_output,~] = Anti_normalizating(Potential_trajectory_allData,Potential_trajectory_allData,mmax,mmin); %反归一化，tt_t表示真值，yy_y表示预测，输进去的是窄矩阵
% Potential_trajectory_allData_output = reshape(Potential_trajectory_allData_2',(N_lengh_point*perception_time),[])';%变换形状,变成宽矩阵；


end