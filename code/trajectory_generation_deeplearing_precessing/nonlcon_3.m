
%约束条件函数
function [const,const2] = nonlcon_3(acc)
% 非线性约束，const是不等式约束，const2是等式约束
%acc是加速度集合（一个步长的加速度），是极坐标；[角度，极径]是问题的解，20*2   极坐标的原因是为了在约束方程里简单
% acc = [3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;];
% acc = OPT;
acc =acc';%一行换成一列
% acc = zeros(20,2);
% acc(:,1) = deg2rad(acc(:,1));%把角度制换成弧度制
M_b = 2000;
% k4=1.2;%目标函数的权重
R_b = 1;%道路条件
%读取标定后的结果
global Parameter
%threshold_Risk = Parameter(1);
G=0.01;
k1=Parameter(1);k3=Parameter(2);char_intrusion=Parameter(3);char_end=Parameter(4);index_end=Parameter(5);k4=Parameter(6);

%extract_one使用一条轨迹的一帧
%intrusion_cood_E是基准坐标
global extract_one
if extract_one(1,14)==2%若是2，则为电动车
    acc_limit = 30;%其实电动车速度上限为49km/h
elseif extract_one(1,14)==1%若是1，则为自行车
    acc_limit = 20;%其实自行车的速度上限为27.7km/h
end
intrusion_cood_E = [47.43 27;47.43 23.5;3 27;3 23.5];

extract = extract_one;%预测的帧
extract(:,1:3) = [];
extract = reshape(extract',11,[])';%换算成11列的
extract(all(extract==0,2),:)=[];%去掉全0行,剩下的是每个交互对象的，第一行是主体
%对客体做一下预测
[extract_pre] = envir_pre(extract,size(acc,1));%恒速度模型预测perception_time个步长，extract第一行是主体 输出形式是预测步长*客体x客体y
base_point = extract(1,1:2);%基准点
Vio = [extract(1,3) extract(1,4)];%前进方向&横向方向
speed = [];
prediction_point = base_point;%存放预测点的矩阵；
acc_cha  = [];
diss = [];%记录的距离
Risk = [];%用来存放风险，第一行是0，是指初始点两边的风险
for i = 1:size(acc,1)%计算每一步的收益
    extract_time_i = reshape(extract_pre(i,:)',2,[])';%将第i个步长恢复成n*2的模式  i=1是当前时刻
    extract_time_i = [extract_time_i extract(:,3:size(extract,2))];%后面的参数还给预测值，使其完整
    %先计算 需要恒速度的那个点，确定约束范围；
    pre_point = [(base_point(1,1)+Vio(1,1)*0.12) (base_point(1,2)+Vio(1,2)*0.12)];%计算恒速度推进的点，也是搜索的原点；
    acceleration = acc(i);%将横向加速度赋予当前参数
    acc_cha = [acc_cha;acceleration];%直角坐标的加速度
    %将加速度换算至位置坐标系
    truth_point = [pre_point(1,1) pre_point(1,2)+acceleration*0.12^2*0.5];%根据当前时刻的加速度求出真实轨迹点； s=v0t+0.5*at^2
    speed = [speed;norm(Vio)*0.12];%把速度保存下来；
    Vio = [Vio(1,1) Vio(1,2)+acceleration*0.12];%将预测速度赋予基准点  vt=v0+at
%     truth_point = extract_trajectory(index_in+18,4:5);%查看真实轨迹，验算用
    truth_Risk = Risk_calculation(truth_point,extract_time_i(2:size(extract_time_i,1),:),intrusion_cood_E,G,R_b,M_b,k1,k3,char_intrusion,char_end,index_end);%计算当前点的风险；
    Risk = [Risk;norm(truth_Risk)];%记录当前点的风险值
    dis = Vio(1,1)*0.12;
    %判断是否满足约束条件
%     if norm(truth_Risk)>threshold_Risk%若风险值大于阈值
%        dis = 2;
%     end
%     if acc(i,2)>0.24||acc(i,2)<0
%        dis = 0;
%     end
    prediction_point = [prediction_point;truth_point];%将预测轨迹存放到矩阵中
    diss = [diss;dis];%将当前时刻的前进方向的位移加进去
%     scatter(truth_point(1,1),truth_point(1,2),'*','r');
%     hold on
%     scatter(pre_point(1,1),pre_point(1,2),'*','b');
    base_point = truth_point ; %将预测点赋予基准点
end
output = sum(diss);%求总位移之和
% disp(norm(truth_Risk))
output1 = prediction_point;%输出预测点
output2 = Risk;%输出预测风险
lin_speed = max((speed)-(acc_limit/3.6*0.12)) ;%速度限制,小于上限，即lin_speed小于等于0；20是最高速度限制
% lin_Risk = max((Risk)-threshold_Risk) ; %风险限制,小于上限，即lin_speed小于等于0；
acc_cha1 = [];
for i =1:19
    acc_cha1 = [acc_cha1;abs(norm(acc_cha(i+1,:)-acc_cha(i,:)))];%急动度（速度） 
end
lin_accCha1 = max(acc_cha1)-0.2;%急动度差，我也不知道这里多少合适，
const = [lin_speed;lin_accCha1];%速度标量差   const = [lin_speed;lin_Risk;lin_accCha1];%速度标量差
const2 = 0;
end