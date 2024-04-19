function [output] = Risk_validation(extract_20)
%本函数的目标是验证真实轨迹是否真的处于风险最小化，还是在一定的阈值之下就行了；
%acc是加速度集合（一个步长的加速度），是极坐标；[角度，极径]是问题的解，20*2   极坐标的原因是为了在约束方程里简单
%这里输入的是后20个真实加速度
% acc = [3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;];
% acc = OPT;

extract_20 = extract_trajectory(index_in:index_in+20,:);%20个步长的真实数据（不包括主体值） 
acc = zeros(20,2);
[acc(:,1),acc(:,2)] = cart2pol(extract_20(2:21,8),extract_20(2:21,9));%把直角坐标换成极坐标，后面的就不用改啦  这个加速度是位置的正向方向的，需要转化为
extract_20(:,1:3) = [];
% wo = extract_20(:,3:4)*0.12;
% scatter(extract_20(:,1),extract_20(:,2),'*','r')%真实轨迹点
% 将预测交通环境值换成真实交通环境，做出每一步搜索区域的风险值，查看预测点是否属于最低；
threshold_Risk = 0.5;
G=0.01;
R_b = 1;
M_b = 5000;
k1 = 1;
k3 = 0.05;
char_intrusion = 2;%原来是200
char_end = 0.2;%原来是6
index_end = 2;

%extract_one使用一条轨迹的一帧
%intrusion_cood_E是基准坐标
global extract_one
intrusion_cood_E = [47.43 27;47.43 23.5;3 27;3 23.5];

extract = extract_one;%预测的帧
extract(:,1:3) = [];
extract = reshape(extract',11,[])';%换算成11列的
extract(all(extract==0,2),:)=[];%去掉全0行,剩下的是每个交互对象的，第一行是主体

base_point = extract(1,1:2);%基准点
Vio = [extract(1,3) extract(1,4)];%前进方向&横向方向
prediction_point = base_point;%存放预测点的矩阵；
diss = [];%记录的距离
Risk = [];%用来存放风险，第一行是0，是指初始点两边的风险
standard_point = [];
for i = 1:size(acc,1)%计算每一步的收益
    extract_time_i = reshape(extract_20(i,:),11,[])';
    extract_time_i(all(extract_time_i==0,2),:)=[];%去掉全0行,剩下的是每个交互对象的，第一行是主体
    %先计算 需要恒速度的那个点，确定约束范围；
    pre_point = [(base_point(1,1)+Vio(1,1)*0.12) (base_point(1,2)+Vio(1,2)*0.12)];%计算恒速度推进的点，也是搜索的原点；
    [acceleration(1,1),acceleration(1,2)] = pol2cart(acc(i,1),acc(i,2));%将加速度的极坐标转化为直角坐标
    %将加速度换算至位置坐标系
    truth_point = [pre_point(1,1)+acceleration(1,1)*0.12^2*0.5 pre_point(1,2)+acceleration(1,2)*0.12^2*0.5];%根据当前时刻的加速度求出真实轨迹点；
    Vio = [Vio(1,1)+acceleration(1,1)*0.12 Vio(1,2)+acceleration(1,2)*0.12];%将新的加速度赋予上一个步长的速度
    disp(Vio)
%     truth_point = extract_trajectory(index_in+18,4:5);%查看真实轨迹，验算用
    truth_Risk = Risk_calculation(truth_point,extract_time_i(2:size(extract_time_i,1),:),intrusion_cood_E,G,R_b,M_b,k1,k3,char_intrusion,char_end,index_end);%计算当前点的风险；
    [All_Risk] = risk_3D(pre_point,extract_time_i(2:size(extract_time_i,1),:),intrusion_cood_E,G,R_b,M_b,k1,k3,char_intrusion,char_end,index_end);%pre_point 做恒速度点一定范围内的风险分布
    hold on
    scatter3(truth_point(1,1),truth_point(1,2),10,'*','r')%真实轨迹点
    hold on
%     scatter3(acceleration(1,1)*0.12+base_point(1,1),acceleration(1,2)*0.12+base_point(1,2),10,'*','r')%真实轨加速度
%     hold on
    scatter3([base_point(1,1);pre_point(1,1)],[base_point(1,2);pre_point(1,2)],[10,10],'*','b')%上一个点和基准点
    hold on 
    [~] = cycle_draw(pre_point,0.12);
%       scatter3(base_point(1,1),base_point(1,2),10,'*','r')%基准轨迹点
%       hold on
%     做到这里了，上面在做图
    Risk = [Risk;norm(truth_Risk)];%记录当前点的风险值
    dis = Vio(1,1)*0.12;
    %判断是否满足约束条件
    if norm(truth_Risk)>threshold_Risk%若风险值大于阈值，给一些正向数，让他赶紧跑开；
       dis = 2;
    end
    if norm(Vio)>(15/3.6*0.12)
       dis = 2;
    end
    prediction_point = [prediction_point;truth_point];%将预测轨迹存放到矩阵中
    standard_point = [standard_point;pre_point];%每一步搜索的标准点
    diss = [diss;dis];%将当前时刻的前进方向的位移加进去
%     scatter(truth_point(1,1),truth_point(1,2),'*','r');
%     hold on
%     scatter(pre_point(1,1),pre_point(1,2),'*','b');
    base_point = truth_point ; %将预测点赋予基准点
end
output = sum(diss);%求总位移之和
disp(output)
% disp(norm(truth_Risk))
output1 = prediction_point;%输出预测点
output2 = Risk;%输出预测风险
end

