
%约束条件函数_轨迹生成的方法
function [const,const2] = nonlcon_Complete_path(traj_points,perception_time)
% traj_points = Potential_trajectory ;
% 非线性约束，const是不等式约束，const2是等式约束
%约束条件包括：①曲率约束；②加速度约束；③速度约束；④风险约束
global extract_one  %准备提取当前状态下的约束
Risk_constraint = 60;%短时预测中是60最好，这个不知道多少15，先不动 21
Cur_constraint = 5;% max(0.16,extract_one(1,13));%这里是角度制  这里设置了1度   5
lin_Angle_constraint = 5;%3;%10起点速度和轨迹角度的差值3，角度制  较好的时候是10   20

if extract_one(1,14)==2%若是2，则为电动车
    a_limit_V = 16.9;%电动车的速度平均值  16.9
    a_limit_a = 0.2703;%电动车的加速度平均值  0.2703   0.36差一些
elseif extract_one(1,14)==1%若是1，则为自行车
    a_limit_V = 11.4;%自行车的速度平均值11.4：
    a_limit_a = 0.05934;%自行车的加速度平均值   0.05934    0.22差一些
end
speed_constraint = max(a_limit_V,extract_one(1,10));%mean([a_limit_V;extract_one(1,10)])+0.25;%+0.25max(a_limit_V,extract_one(1,10));%单位是km/h    max(a_limit_V,extract_one(1,10));   %    mean([a_limit_V;extract_one(1,10)])+0.25
accle_constraint = 0.8;%mean([a_limit_a;abs(extract_one(1,11))])+0.1;%max(a_limit_a,extract_one(1,11))+0.05;%单位是m/s^2   accle_constraint = max(a_limit_a,extract_one(1,11));%单位是m/s^2
% Perception_interval = 0.4*2^0.5;

%mean([a_limit_a;abs(extract_one(1,11))])+0.1;
%%
% tic
%acc终点坐标
% acc = [-5 -3]  %举个例子
% acc = OPT;
% perception_time = 17;
%真实轨迹
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

global intrusion_cood_E
if extract_one(1,14) == 1%动态调整风险偏好系数  自行车
    k4 = 1*10^-1;%PPT上的结果采用的是4
elseif extract_one(1,14) == 2  %电动车
    k4 = 0.2*10^-1;%PPT上的结果采用的是3
end
% intrusion_cood_E = [47.43 27;47.43 23.5;3 27;3 23.5];

extract = extract_one;%预测的帧
extract(:,1:3) = [];
extract = reshape(extract',11,[])';%换算成11列的
extract(all(extract==0,2),:)=[];%去掉全0行,剩下的是每个交互对象的，第一行是主体
%% 对客体做一下预测
[extract_pre] = envir_pre(extract,perception_time);%恒速度模型预测perception_time个步长，extract第一行是主体 输出形式是预测步长*客体x客体y
base_point = extract(1,1:2);%基准点  即起点

%% 赋予起终点
% 赋值
start_point = traj_points(1,:);
end_point = traj_points(size(traj_points,1),:);
% toc
%%
Risk = [];%用来存放风险,第一列是预测点，第二列是真实点
for i = 1:perception_time%计算每一步的收益,减少计算量，包括终点
    extract_time_i = reshape(extract_pre(i,:)',2,[])';%将第i个步长恢复成n*2的模式  i=1是当前时刻
    extract_time_i = [extract_time_i extract(:,3:size(extract,2))];%后面的参数还给预测值，使其完整，这是环境信息，不包括主体
    %提取轨迹对应的轨迹点；
    truth_point = traj_points(i,1:2);%提取轨迹对应的轨迹点位置 作为计算风险的位置
    truth_Risk = Risk_calculation(truth_point,extract_time_i(2:size(extract_time_i,1),:),intrusion_cood_E,G,R_b,k1,k3,char_intrusion,char_end,index_end,char_intrusion_right,char_end_right,index_end_right);%计算当前点的风险；
    %下面的运行时ctrl+r掉,我在12/24改变了这边  下面计算的是真实轨迹的风险
%     real_Risk = Risk_calculation(extract_trajectory(index_in+i,4:5),extract_time_i(2:size(extract_time_i,1),:),intrusion_cood_E,G,R_b,M_b,k1,k3,char_intrusion,char_end,index_end);%计算当前点的风险；
%     Risk = [Risk;[norm(truth_Risk) norm(real_Risk)]];%记录当前预测点和真实点的风险值
    Risk = [Risk;norm(truth_Risk)];
    %判断是否满足约束条件  下面的循环0103注释掉的，因为没有风险上限值
%     if norm(truth_Risk)>11%若风险值大于阈值，给一些正向数，让他赶紧跑开；
%         disp(truth_Risk)
%        lin_Risk = 2;
%     end
%     if norm(Vio)>(25/3.6)%若当前速度大于25km/h，则能给一个大的惩罚
%        dis = 2;
%     end
end
diss = end_point(1,1) - start_point(1,1);%距离等于起终点的x坐标之差
diss_one = (diss-0)/(20-0);%位移的归一化结果  公式为：（x-min）/（max-min）
% output = output + (sum(hengxiang));
risk_one = log10(1+mean(Risk(:,1))) /log10(4+1);%风险的归一化结果    公式为：x’ = log10(x) /log10(max)  注意x要大于1，所以x和max均+1
output =  (1-k4)*diss_one + k4*(risk_one);%需标定，两个的权重
% disp(norm(truth_Risk))
output1 = traj_points;%输出预测点
output2 = Risk;%输出预测风险  部分点（缩减样本后）
% toc
% scatter(output1(:,1),output1(:,2),'*','r')
%% 计算风险
lin_Risk = max(Risk)-Risk_constraint;%最大风险约束
% disp(max(Risk))
%% 计算曲率
[all_Cur] = PonitsCurve_calculation(traj_points);
lin_Cur = max(abs(all_Cur)) - Cur_constraint;%曲率约束
% disp(max(all_Cur))
%% 计算速度
distance = 0;
for i = 1:size(traj_points,1)-1
    distance = distance + norm(traj_points(i+1,:)-traj_points(i,:));
end
end_speed = (2*distance / (perception_time*0.12)*3.6) - extract_one(1,10);%平均速度约束  单位是km/h
lin_speed = end_speed - speed_constraint; %速度约束
%% 计算加速度
accle = (end_speed - extract_one(1,10))/3.6/(perception_time*0.12);%单位是m/s
lin_accle = abs(accle) - abs(accle_constraint);%加速度约束  
% disp(accle)
%% 计算起点速度方向和轨迹方向的夹角，需要小于一定的角度
V_angle = [extract_one(1,6),extract_one(1,7)];  %速度角度
V_angle = V_angle/norm(V_angle);
traj_angle = [(traj_points(2,1)-traj_points(1,1)),(traj_points(2,2)-traj_points(1,2))];%第一个点和第二个点的轨迹角度
traj_angle = traj_angle/norm(traj_angle);
sigma = acos(dot(V_angle,traj_angle)/(norm(V_angle)*norm(traj_angle)));
Angle_diff = sigma/pi*180;
lin_Angle_diff = Angle_diff - lin_Angle_constraint;
%% 约束
const = [lin_speed;lin_Cur;lin_Risk;lin_accle;lin_Angle_diff];%速度标量差   const = [lin_speed;lin_Risk;lin_accCha1];%速度标量差  全是负数表示满足约束
const2 = [];
end