function [mean_dis] = fitting(X)
char_intrusion = X(1);
M = X(2);
char_end = X(3);
char_NV = X(4);
char_V = X(5);
NV_index = X(6);
V_index = X(7);
index_end = X(8);
max_excur = X(9);

% disp('start data_handle');
% tic
% char_intrusion = 200.1;%侵入危险度的参数
% M = 100.1;%取得的上限值，足够大的正数
long = 4.5;%非机动车长半轴 原来是5
short = 2.5; %非机动车短半轴  原来是3
% char_end = 6.1;%终点复杂度的参数
% char_NV = 5.1;%非机动车的参数
% char_V = 5.1;%机动车的参数
long_V = 5.5;%机动车长半轴
short_V = 3.5;%机动车短半轴
% NV_index = 0.9;%非机动车危险度陡峭指数，0-1之间
% % V_index = 0.9;%机动车危险度陡峭指数，0-1之间
% index_end = 2.1;%侵入危险的的参数
% long_Per = 1.8;%感知长轴
% short_Per = 0.8;%感知短轴
% perception_Radius = 0.3;%感知圆形半径
% max_excur = 0.7;%最大横向偏移距离
tic
frequency_NV = 10^5;%机动车随机点个数
global trajectory_block;
global ID;
% global all_ID;
% trajectory_block = csvread('trajectory_block.csv');%读取
% ID = csvread('ID.csv');%读取
intrusion_cood_E = [47.43 27;47.43 23.5;3 27;3 23.5];
%计算客观风险值
[aim_danger_NV,aim_danger_int,aim_danger_end,aim_danger_V] = Risk_each(intrusion_cood_E,M,frequency_NV,long,short,long_V,short_V,char_intrusion,char_end,char_NV ,char_V,NV_index,V_index,index_end);
% all_dis = 0;%叠加距离
diss = [];%所有的距离
step = 20;%预测步长
for i = 1:size(ID,2)%对于每一个轨迹
    %计算每个点的感知风险分布 extract_one不是个优化参数，只是个计算的数据
    extract_one = trajectory_block((trajectory_block(:,1)==ID(i)),:);%提取当前轨迹
%     ID_in = all_ID(i,:);%提取第i条轨迹的轨迹点序号
    for j =1:step:size(extract_one,1)-step%对于每一个轨迹点，预测20步，
        perception_Radius = extract_one(1,10)/3.6*0.12/2;%根据当前的计算出一个步长的距离，当成离散点半径  extract_one(1,10)
        [prediction_point,Risk] = Excur_predict(extract_one(j,:),aim_danger_NV,aim_danger_int,aim_danger_end,aim_danger_V,intrusion_cood_E,perception_Radius,perception_Radius,perception_Radius,step,max_excur);
        dis = mean(sqrt((((extract_one(j:j+step,4)-prediction_point(:,1)).^2)+((extract_one(j:j+step,4)+prediction_point(:,2)).^2))));%计算误差值
        diss = [diss;dis];
%         figure(1)
%         scatter(extract_one(j:j+step,4),extract_one(j:j+step,5),'*','b');%可视化
%         hold on
%         scatter(prediction_point(:,1),prediction_point(:,2),'*','r');%可视化
    end
%     disp(['fitting已完成',num2str(i/size(ID,2)*100),'%']);  %disp(['fitting已完成',num2str(i/trajectory_block(size(trajectory_block,1),1)*100),'%']);
end
toc
mean_dis = mean(diss);
disp(['fitting = ',num2str(mean_dis)])
end

