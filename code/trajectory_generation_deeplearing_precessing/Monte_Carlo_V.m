function [aim_danger,Nu_part] = Monte_Carlo_V(long_V,short_V,long,short,M,char_V,frequency_NV,NV_index)
% tic
%通过蒙特卡洛模拟求出危险度聚集程度，并用概率点进行危险度计算
% x = extract(1,1);%x坐标
% y = extract(1,2);%y坐标
% angle = extract(1,10);%角度，该角度输进来应该是绝对角度，即是跟坐标轴的角度，而不是相对于上个点的角度

index = 1;
Nu_part = [];
% while index<20

%下面是蒙特卡洛求积分
% %参数
% long_V = 8;
% short_V = 6;
% long = 5;%最外圈的长半轴，最够远的正向长轴距离;
% short = 3;%最外圈的短轴
% M = 100;%足够大的正数，将朝上的开区间
% V_index = 0.2;
% char_V = 1;%标定的参数,角度为0时的参数
% frequency_NV = 10^7;%实验次数
frequency_V = round(frequency_NV*(((2*long_V)*(2*short_V)*(M))/((2*long)*(2*short)*(M))));%求取机动车的实验次数
ecc = (long_V^2-short_V^2)^0.5/(long_V);%离心率，通过长短轴进行计算

%产生随机数
RandData = rand(frequency_V,3);%生成三维随机数，共有frequency个
RandData(:,1) = (RandData(:,1)*2*long_V)-long_V;%x坐标
RandData(:,2) = (RandData(:,2)*2*short_V)-short_V;%y坐标
RandData(:,3) = RandData(:,3)*M;%Z坐标

%筛选
ell = zeros(size(RandData,1),2);
for i = 1:size(RandData,1)%计算是否符合要求
    ell(i,1) = ((RandData(i,1)^2)/(long_V^2))+((RandData(i,2)^2)/(short_V^2));%计算是否在椭圆内
    [a,r] = cart2pol(RandData(i,1)+(abs((long_V^2-short_V^2))^0.5),(RandData(i,2)));%直角坐标转换为极坐标,把坐标原点转换到左焦点上  ((long_V^2-short_V^2)^0.5)是指c
    ell(i,2) = char_V*(((1-ecc^2)/(r*(1-ecc*cos(a))))^NV_index);%计算每个位置的危险度值
end
aim = RandData(find((ell(:,1)<=1)&RandData(:,3)<=ell(:,2)),:);%提取符合要求的点

% scatter3(aim(:,1),aim(:,2),aim(:,3),'.','r');%做图
Nu_part = [Nu_part;[size(aim,1) frequency_V]];
% index = index + 1;
% end
% toc
%得到交互区域的危险度分布点，其实这个第三列的高度已经没什么用了，因为只是用它确定了一下积分区域，稍后只是用平面落在交互区域的点就可以
% aim_danger(:,1) = aim(:,1)+x;%将随机点换算至真实位置
% aim_danger(:,2) = aim(:,2)+y;
% aim_danger(:,3) = aim(:,3);%高度直接放上去
aim_danger = aim;

end