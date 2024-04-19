function [Complete_Data_odPoints_output] = Normalizating_NEW(Complete_Data_odPoints,N_points,mmax,mmin)
% 反归一化  输进来的是宽矩阵  输出去的还是宽矩阵

% csvwrite('mmax(20210831_1).csv',mmax);%写出最大值数据
% csvwrite('mmin(20210831_1).csv',mmin);%写出最小值数据

% %% 输入参数
% mmax = csvread('mmax(20210831_1).csv');%读最大值数据
% mmin = csvread('mmin(20210831_1).csv');%读最小值数据
N_lengh_point = size(mmax,2);%读取特征数

%% 变换形状
Complete_Data_odPoints_1 = reshape(Complete_Data_odPoints',N_lengh_point,[])';%变成窄矩阵  N_lengh_point是特征数；

%% 开始运算
Complete_Data_odPoints_2 = zeros(size(Complete_Data_odPoints_1,1),size(Complete_Data_odPoints_1,2));%设定占位
for i = 1:size(Complete_Data_odPoints_1,1)
    for j = 1:N_lengh_point
        Complete_Data_odPoints_2(i,j) = (Complete_Data_odPoints_1(i,j)-mmin(j)) / (mmax(j)-mmin(j));%求取相对值
    end
end
%% 再次变换形状
Complete_Data_odPoints_output = reshape(Complete_Data_odPoints_2',(size(Complete_Data_odPoints,2)),[])';%变换形状,变成宽矩阵；


end