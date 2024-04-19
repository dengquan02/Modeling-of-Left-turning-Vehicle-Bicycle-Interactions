function [output,output1,output2,output_dis,output_risk,sum_Dis_Path] = Trajectory_benefit_calculating(Potential_trajectory)
%Trajectory_benefit_calculating 
%该函数是用来计算轨迹的效益的，输入变量是完整的轨迹点（通过上一步的深度学习生成）；输出是轨迹效益值
%output是轨迹效益；output1是轨迹的坐标；output2是轨迹风险

% 测试输入参数
% generating_lengh = 9; %generating_lengh表示每段已知起终点的生成轨迹长度
perception_time = size(Potential_trajectory,1); %预测长度


%%  根据轨迹位置计算效益值

%下面参数是根据文献给出的标定参数结果，除了char_end、char_intrusion和index_end
% threshold_Risk = 2;G=0.01;R_b = 1;k1 = 1;k3 = 0.05;char_intrusion = 2;char_end = 0.2;index_end = 2;
% M_b = 2000;
R_b = 1;
% k4=1.2;%目标函数的权重

%读取标定后的结果
global Parameter
%threshold_Risk = Parameter(1);
G=Parameter(10);
k1=Parameter(1);k3=Parameter(2);char_intrusion=Parameter(3);char_end=Parameter(4);index_end=Parameter(5);k4=Parameter(6);
char_intrusion_right=Parameter(7);char_end_right=Parameter(8);index_end_right=Parameter(9);

%extract_one使用一条轨迹的一帧
%intrusion_cood_E是基准坐标
global extract_one


%%
global intrusion_cood_E
if extract_one(1,14) == 1%动态调整风险偏好系数  自行车
    k4 = 0.5;%PPT上的结果采用的是4
elseif extract_one(1,14) == 2  %电动车
    k4 = 0.4;%PPT上的结果采用的是3
end
% intrusion_cood_E = [47.43 27;47.43 23.5;3 27;3 23.5];

extract = extract_one;%预测的帧
extract(:,1:3) = [];
extract = reshape(extract',11,[])';%换算成11列的
extract(all(extract==0,2),:)=[];%去掉全0行,剩下的是每个交互对象的，第一行是主体
%对客体做一下预测
[extract_pre] = envir_pre(extract,perception_time);%恒速度模型预测perception_time个步长，extract第一行是主体 输出形式是预测步长*客体x客体y
diss = [];%记录的距离
Risk = [];%用来存放风险,第一列是预测点，第二列是真实点
Dis_Path = [];%计算路程

all_points = Potential_trajectory;%将潜在轨迹赋予all_points
%% 再次计算目标（完整轨迹点）
time_interv = 0.12 ;
for i = 1:size(all_points,1)-1%计算每一步的收益  
    extract_time_i = reshape(extract_pre(i,:)',2,[])';%将第i个步长恢复成n*2的模式  i=1是当前时刻
    extract_time_i = [extract_time_i extract(:,3:size(extract,2))];%后面的参数还给预测值，使其完整，这是环境信息，不包括主体
    truth_Risk = Risk_calculation(all_points(i,:),extract_time_i(2:size(extract_time_i,1),:),intrusion_cood_E,G,R_b,k1,k3,char_intrusion,char_end,index_end,char_intrusion_right,char_end_right,index_end_right);%计算当前点的风险；
    Risk = [Risk;norm(truth_Risk)];
    %以上是计算风险，以下是计算距离
    
    

    %判断是否满足约束条件  下面的循环0103注释掉的，因为没有风险上限值
%     if norm(truth_Risk)>5%若风险值大于阈值，给一些正向数，让他赶紧跑开；
%        dis = 2;
%     end
%     if norm(Vio)>(25/3.6)%若当前速度大于25km/h，则能给一个大的惩罚
%        dis = 2;
%     end
%     dis = [dis extract_trajectory(index_in+i,6)*0.12];%把真实轨迹的收益放进去

end
global endpoint_x
global endpoint_y
dis =sqrt((all_points(size(all_points,1),1)-endpoint_x)^2+(all_points(size(all_points,2),1)-endpoint_y)^2);%这个步长内前进方向的位移,出来是负值
disp(dis);
dis_path = dis;%求这个步长里的路程
diss = [diss;dis];%将当前时刻的前进方向的位移加进去
Dis_Path = [Dis_Path,dis_path];%路程长度

%% 输出目标值
% output = output + (sum(hengxiang));
% output = output + k4*(sum(Risk(size(Risk,1),1)));%风险只计算最后一个点的风险值
% k4=0.1;  %k4=0.32;%在上面赋予的不同车型不同的值
output = (1-k4)*(sum(diss,1))+ (k4)*(mean(Risk(:,1)));%m目标值    *sum(Dis_Path)  output = (1-k4)*(sum(diss(:,1)))/8 + (k4)*(mean(Risk(:,1)))*sum(Dis_Path)/(400)/8;%前
% disp('目标值是')
% disp(output)
% disp((sum(diss(:,1)))/8 );
% disp((mean(Risk(:,1)))*sum(1)/(4)/8)   %Dis_Path
% disp(norm(truth_Risk))
output1 = Potential_trajectory;%输出预测点
output2 = (mean(Risk(:,1)))*sum(1)/(4)/8;%输出预测风险  output2 = (mean(Risk(:,1)))*sum(Dis_Path)/(400)/8;%输出预测风险
% figure(10)
% [~] = risk_3D(extract_one(1,4:5),extract_time_i(2:size(extract_time_i,1),:),intrusion_cood_E,G,R_b,k1,k3,char_intrusion,char_end,index_end,char_intrusion_right,char_end_right,index_end_right);%做风险场的图

%% 输出位移和风险后再根据备选轨迹集合情况进行归一化
output_dis = -(sum(diss,1));% 输出前进方向的位移
disp(diss)
output_risk = (mean(Risk(:,1)))*sum(1);  %输出风险值   Dis_Path   在Exhaustion_Method中计算了风险的路径因素，此处只能填sum(1)
sum_Dis_Path = -sum(Dis_Path);%输出路程总和
end



