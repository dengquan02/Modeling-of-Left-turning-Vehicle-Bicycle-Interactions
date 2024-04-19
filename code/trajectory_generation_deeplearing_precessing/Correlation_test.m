function [outputArg1,outputArg2] = Correlation_test(inputArg1,inputArg2)
global E_trajectory;
%期望通过分析相同时刻的个体，通过位置相关性识别交互对象；
%% 按照主体归一化，看了一下交互关系，其实没啥用，因为其他交互对象也要按照主体对他们的冲突进行回馈，归一化之后失去了这样的信息
index = 1;
while index <=E_trajectory(size(E_trajectory,1),1)
    operation = E_trajectory(E_trajectory(:,1)==index,:);
    %先做一下交互方位的动态图
    for i = 1:size(operation,1)
        postion = operation(i,:);%提取一个时间片段
        postion(:,1:3) = [];%去掉前三列没用的东西
        postion = reshape(postion',11,[])';
        postion(all(postion==0,2),:)=[];%去掉全0行
        postion_zero = postion(:,1:2);
        postion_zero(:,1) = postion(:,1)-postion(1,1);%按照主体归一化
        postion_zero(:,2) = postion(:,2)-postion(1,2);
        clf
        scatter(postion_zero(:,1),postion_zero(:,2),'*','b')
        axis([-25 25 -10 10]); % 设置坐标轴在指定的区间
        hold on 
        scatter(postion_zero(1,1),postion_zero(1,2),'*','r')
        axis([-25 25 -10 10]); % 设置坐标轴在指定的区间
        pause(0.1)
    end
end

%% 做交互对象时空图，以期通过相关性关系找到他们的交互对象，确定交互距离
end
index = 55;
while index <=E_trajectory(size(E_trajectory,1),1)
    operation = E_trajectory(E_trajectory(:,1)==index,:);
    for i = 1:11
        scatter(operation(:,2),operation(:,11),'r','*')%横坐标时空图
        hold on 
        scatter(operation(:,2),operation(:,11+(i)*11),'b','*')%横坐标时空图
        hold on 
    end
end
