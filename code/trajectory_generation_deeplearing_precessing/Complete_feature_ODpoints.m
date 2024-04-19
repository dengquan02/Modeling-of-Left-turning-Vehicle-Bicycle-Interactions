function [output] = Complete_feature_ODpoints(start_point,end_point,extract_one,perception_time)
% 输入数据包括：起终点及交互对象，以及 预测时间
% 那边训练完确定可用之后，这边再进行针对性的修改；

%% 新修改
% %研究主体
% precessing_test1 = [extract_one(4:9) extract_one(14) extract_one(15:20) extract_one(25)];
% 
% t = (perception_time - 1)*0.12;%计算运行时间
% Host_S_start_test =  extract_one(4:5);  %起点位置
% Host_V_start_test =  extract_one(6:7);  %起点速度
% Host_A_start_test =  extract_one(8:9);%换算成m/s   起点加速度
% 
% Host_S_end_test =  end_point;  %终点位置
% Host_V_end_test = (2 .*(Host_S_end_test - Host_S_start_test)./t) - Host_V_start_test; %得到的是速度矩阵
% Host_V_end_test = Host_V_start_test + Host_A_start_test.*t;
% A_mean_test = (Host_V_end_test - Host_V_start_test)./t;%计算加速度，这一段上的平均加速度
% Host_A_end_test = A_mean_test*2 - Host_A_start_test;%计算得到最终的加速度
% 
% %交互对象  相较于研究主体  列数为+n
% Inter_S_start_test =  extract_one(1,15:16);  %起点位置
% Inter_V_start_test =  extract_one(1,17:18);%换算成m/s
% Inter_A_start_test =  extract_one(1,19:20);
% 
% Inter_A_end_test = Inter_A_start_test;%加速度不变
% Inter_V_end_test = t.*Inter_A_start_test + Inter_V_start_test;%速度按照恒加速度计算
% Inter_S_end_test = Inter_S_start_test + Inter_V_start_test * t+ 0.5.*Inter_A_end_test.*t.^2;%恒速度模型计算
% 
% %赋值
% test_output1 = precessing_test1;%这是研究主体现状 和交互对象现状
% test_output1 = [test_output1 Host_S_end_test Host_V_start_test Host_A_start_test extract_one(14)];%存放研究主体终点位置 ,速度和加速度（速度和加速度就是初始状态） 
% test_output1 = [test_output1 Inter_S_end_test Inter_V_end_test Inter_A_end_test extract_one(25)];%赋予交互对象的位置 速度和加速度
% 
% output = test_output1;

%% 原来的 对研究主体进行处理，x和y方向同时处理  假设是恒加速度模型
V0 = extract_one(1,6:7);%换算成m/s
t = (perception_time - 1)*0.12;%计算运行时间
A0 = extract_one(1,8:9);%研究主体的加速度
A_mean = ((end_point - start_point) - V0.*t).*2./(t^2);   %按照s=0.5*a*t^2+V0*t计算而来
Vt = (A_mean*t) + V0;  %按照Vt=V0+a*t
At = A_mean*2 - A0;%计算得到最终的加速度   按照A_mean = (AT+A0)/2

%% 对交互对象进行处理  加速度不变，速度不变，位置按照CA模型计算
inter_Data = extract_one(1,15:25);%提取一个交互对象（第1个）
A_inter_Data = inter_Data(1,5:6);%5:6应该是加速度的数据 ，加速度不变直接赋予
V_inter_Data =  t.*A_inter_Data;%这个公式是错的，但是错公式带进去算的反而结果好些；   恒加速度算速度   %2021.11.24是： V_inter_Data = inter_Data(1,3:4);%速度不变    V_inter_Data =  inter_Data(1,3:4) + t.*A_inter_Data;%恒加速度算速度  
P_inter_Data =  V_inter_Data.*t + 0.5.*A_inter_Data.* t^2;%这个公式是错的，但是错公式带进去算的反而结果好些；   根据恒加速度模型计算出,这是路程    P_inter_Data = inter_Data(1,1:2) + V_inter_Data.*t + 0.5.*A_inter_Data.* t^2;%根据恒加速度模型计算出,这是路程
inter = [P_inter_Data V_inter_Data A_inter_Data];


% P_inter_Data = inter_Data(1,1:2) + inter_Data(1,3:4) * t ;%根据恒速度模型计算出,这是路程
% inter = [P_inter_Data inter_Data(1,3:4) A_inter_Data];
%% 赋值
x_output = [extract_one(1,4:9) extract_one(1,14)];%赋予起点研究主体信息
x_output = [x_output extract_one(1,13)]
x_output = [x_output inter_Data(1,1:6) inter_Data(1,11)];%赋予起点交互对象信息
x_output = [x_output extract_one(1,24)]
x_output = [x_output end_point Vt At extract_one(1,14)];%赋予终点研究主体信息   %2021.11.24是： x_output = [x_output end_point V0 A0 extract_one(1,14)];%赋予终点研究主体信息    %x_output = [x_output end_point Vt At extract_one(1,14)];%赋予终点研究主体信息
x_output = [x_output extract_one(1,13)]
x_output = [x_output inter inter_Data(1,11)]; %赋予终点交互对象信息
x_output = [x_output extract_one(1,24)]

output = x_output;


end