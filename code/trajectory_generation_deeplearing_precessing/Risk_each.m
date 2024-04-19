function [aim_danger_NV,aim_danger_int,aim_danger_end,aim_danger_V] = Risk_each(intrusion_cood_E,M,frequency_NV,long,short,long_V,short_V,char_intrusion,char_end,char_NV ,char_V,NV_index,V_index,index_end)
%计算每个部分的危险度，只需要计算一次，后期进行调用就行，需要把数据存好；
%参数
% intrusion_cood_E = csvread('intrusion_cood_E.csv');%读取机动车道基准信息，表示基准点坐标，里面的排列应该是四个点，当道路横向向左时，从上至下，分别是左上、左下、右上、右下的顺序，横坐标-纵坐标
% char_intrusion = 100;%侵入危险度的参数
% M = 100;%取得的上限值，足够大的正数
% frequency_NV = 10^6;%机动车随机点个数
% long = 5;%非机动车长半轴
% short = 3; %非机动车短半轴
% char_end = 10;%终点复杂度的参数
% char_NV = 1;%非机动车的参数
% char_V = 1;%机动车的参数
% long_V = 8;%机动车长半轴
% short_V = 6;%机动车短半轴
%参数输入结束，上面的数值是例子

%计算各个的危险度分布
[aim_danger_NV,~] = Monte_Carlo_NV(long,short,M,char_NV,frequency_NV,NV_index);%利用蒙特卡洛模拟计算动态交互对象的危险度，交互对象为0,0点,需要带入不动的对象位置和角度进行换算；
[aim_danger_int,~] = Monte_Carlo_intrusion(intrusion_cood_E,char_intrusion,M,frequency_NV,long,short);%计算机动车侵入距离的危险度，坐标原点是起点机非分割点，输入非机动车投点次数，是因为密度一样，才有可加性
[aim_danger_end,~] = Monte_Carlo_end(intrusion_cood_E,char_end,M,frequency_NV,long,short,index_end);%计算距离终点的危险度，坐标轴原点是出口道机非分隔点
[aim_danger_V,~] = Monte_Carlo_V(long_V,short_V,long,short,M,char_V,frequency_NV,V_index);%机动车的危险度
% [~] = Risk_Heat_map([aim_danger_end]);
% [~] = Risk_Heat_map([aim_danger_int]);
% scatter3(aim_danger_NV(:,1),aim_danger_NV(:,2),aim_danger_NV(:,3),'.','r');
% scatter(aim_danger_end(:,1),aim_danger_end(:,3),'.','r');
% scatter3(aim_danger_int(:,1),aim_danger_int(:,2),aim_danger_int(:,3),'.','r');
%计算危险度结束
end