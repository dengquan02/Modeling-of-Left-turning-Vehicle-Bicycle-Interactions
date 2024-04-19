function [sample] = data_expand_test(input_test,generating_lengh) 
%%数据拓展%%%%
%该函数的目的是把轨迹集分割为样本，分别按照3、5....
% input_test = data_test;%输入测试数据
% generating_lengh = 17;%输入生成的长度，必须是单数  
% 对测试轨迹进行拓展，主要是把长轨迹切割成合适的长度；

%% 以下开始数据拓展
N_test = unique(input_test(:,1));%读取轨迹编号
sample = [];%存放样本
index = 1;
for i = 1:size(N_test,1)%对每个轨迹进行处理
    exter_trajectory = input_test(input_test(:,1)==N_test(i),:);
    start_point = randperm(generating_lengh,1)-1;%在1~generating_lengh中间随机开始
    for j = start_point : generating_lengh : size(exter_trajectory,1)-generating_lengh  %生成不同的划分级别
        sample_1 = [ones(generating_lengh,1)*index exter_trajectory(j+1:j+generating_lengh,:)];  %generating_lengh个点
        sample = [sample; sample_1];%每个样本是generating_lengh个点（即行）；
        index = index + 1;
        disp(index);
    end
end
% sample_test = sample;
end
    