function [sample] = data_expand(input) 
%%数据拓展%%%%
%该函数的目的是把轨迹集分割为样本，分别按照3、5....
% input = data_train_ver;%输入训练数据

%% 以下开始数据拓展
N_test = unique(input(:,1));
sample = [];%存放样本
index = 1;
for i = 1:size(N_test,1)
    
    exter_trajectory = input(input(:,1)==N_test(i),:);
    ID_index = 2:2:16; %生成不同的循环取样级别         ID_index = 2:2:size(exter_trajectory,1); %生成不同的循环取样级别
    for j = 1:size(ID_index,2)
        for z = 1:ID_index(j):size(exter_trajectory,1) - ID_index(j)
%             portion_point_x = (exter_trajectory(z+(ID_index(j))/2,4)-exter_trajectory(z,4))/(exter_trajectory(z+ID_index(j),4)-exter_trajectory(z,4));%每个中间点占起终点的比例  x坐标
%             portion_point_y = (exter_trajectory(z+(ID_index(j))/2,5)-exter_trajectory(z,5))/(exter_trajectory(z+ID_index(j),5)-exter_trajectory(z,5));%每个中间点占起终点的比例  x坐标
            sample_1 = [[index exter_trajectory(z,:)] ; [index exter_trajectory(z+(ID_index(j))/2,:)]; [index exter_trajectory(z+ID_index(j),:)]];%起终点和中间点
            sample = [sample; sample_1];%每个样本是三行，如此下去
            index = index + 1;
            disp(['  i是',num2str(i),'  j是',num2str(j),'  z是',num2str(z),])
        end
    end
end
% sample_train_ver = sample;
end
    