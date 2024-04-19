function [aim_danger,Nu_part] = Monte_Carlo_intrusion(intrusion_cood_E,char_intrusion,M,frequency_NV,long,short)
% tic
%通过蒙特卡洛模拟求出侵入危险度聚集程度，并用概率点进行危险度计算
%intrusion_cood_E表示基准点坐标，里面的排列应该是四个点，当道路横向向左时，从上至下，分别是左上、左下、右上、右下的顺序，横坐标-纵坐标
% csvwrite('intrusion_cood_E.csv',intrusion_cood_E);%写入基准信息
index = 1;
Nu_part = [];
% while index<20

%下面是蒙特卡洛求积分，记住此时的实验次数与之前的有关，应该是与实验体积成正比
% %参数
% long = 5;%NV的长半轴参数;
% short = 3;%NV的短半轴参数
% M = 100;%足够大的正数，将朝上的开区间
% char_intrusion = 100;%标定的参数,侵入的程度
% frequency_NV = 10^6;%动态交互的实验次数,根据此次数求侵入的实验次数，与实验体积有关
frequency_intrusion = round(frequency_NV*((abs((intrusion_cood_E(1,1)-intrusion_cood_E(3,1))*(intrusion_cood_E(1,2)-intrusion_cood_E(2,2)))*M)/((2*long)*(2*short)*(M))));%求取侵入的实验次数

%产生随机数
RandData = rand(frequency_intrusion,3);%生成三维随机数，共有frequency_intrusion个
RandData(:,1) = (RandData(:,1)*(abs(intrusion_cood_E(3,1)-intrusion_cood_E(1,1))));%横向范围
RandData(:,2) = (RandData(:,2)*(abs(intrusion_cood_E(1,2)-intrusion_cood_E(2,2))));%纵向范围
RandData(:,3) = RandData(:,3)*M;%Z坐标

%筛选
ell = zeros(size(RandData,1),1);
for i = 1:size(RandData,1)%计算是否符合要求
    ell(i,1) = (RandData(i,3)<=(log((RandData(i,2)*char_intrusion+1)))) ; %;%只筛选出z坐标低于函数的值（利用y值计算）就行，x坐标不用管
end
aim = RandData(find(ell(:,1)==1),:);%提取符合要求的点

% scatter3(aim(:,1),aim(:,2),aim(:,3),'.','r');%做图
Nu_part = [Nu_part;[size(aim,1) frequency_intrusion]];
% index = index + 1;
% end
% toc
%得到交互区域的危险度分布点，其实这个第三列的高度已经没什么用了，因为只是用它确定了一下积分区域，稍后只是用平面落在交互区域的点就可以
% aim_danger(:,1) = aim(:,1)+x;%将随机点换算至真实位置
% aim_danger(:,2) = aim(:,2)+y;
% aim_danger(:,3) = aim(:,3);%高度直接放上去
aim_danger = aim;

end

