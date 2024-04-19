function [output] = Curvature_dis(input1,input2)
%计算输入两条轨迹各个对应点的曲率之差
% input1 = Truth_no(:,4:5);
% input2 = output1;
index_size = size(input1,1);%读取轨迹的轨迹点数
cos_ang_all = [];%存放各个对应点的角度差的余弦值
dis_all = [];
for i = 1:index_size-1
    new_1 = input1(i:i+1,:);
    new_2 = input2(i:i+1,:) - (input2(i,:) - input1(i,:));%按照第一个线段的起点归一化
    ang_dis = polyarea([new_1(2:size(new_1,1),1);new_2(:,1)],[new_1(2:size(new_1,1),2);new_2(:,2)])/norm(new_1(1,:)-new_1(2,:))*100;
    cos_ang_all = [cos_ang_all;ang_dis];
    dis = norm(input1(i,:)-input2(i,:));%计算轨迹点之间的距离误差
    dis_all = [dis_all;dis];
%     disp(dis)
%     disp(ang_dis)
end
cos_dis = mean(cos_ang_all);%因为余弦值是减函数，因此是求最大值，获取角度的最小值  
output = cos_dis + mean(dis_all);
end

% scatter([new_1(:,1);new_2(:,1)],[new_1(:,2);new_2(:,2)],'*','r')