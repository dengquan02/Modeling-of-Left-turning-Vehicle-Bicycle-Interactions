function [output] = Excur_predict_3(acc)
%Excur_predict_3用来求优化的轨迹，Excur_predict_2用OPT来求结果,Excur_predict_3是优化横向加速度，纵向目前以恒速度模型为准
%本函数的目标是计算收益值；
%acc是加速度集合（一个步长的加速度），是极坐标；[角度，极径]是问题的解，20*2   极坐标的原因是为了在约束方程里简单
% acc = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% acc = OPT;
acc =acc';%一行换成一列
%真实轨迹
%下面参数是根据文献给出的标定参数结果，除了char_end、char_intrusion和index_end
% threshold_Risk = 2;G=0.01;R_b = 1;k1 = 1;k3 = 0.05;char_intrusion = 2;char_end = 0.2;index_end = 2;
M_b = 2000;
R_b = 1;
% k4=1.2;%目标函数的权重

%读取标定后的结果
global Parameter
%threshold_Risk = Parameter(1);
G=0.01;
k1=Parameter(1);k3=Parameter(2);char_intrusion=Parameter(3);char_end=Parameter(4);index_end=Parameter(5);k4=Parameter(6);

%extract_one使用一条轨迹的一帧
%intrusion_cood_E是基准坐标
global extract_one
global intrusion_cood_E
% intrusion_cood_E = [47.43 27;47.43 23.5;3 27;3 23.5];

extract = extract_one;%预测的帧
extract(:,1:3) = [];
extract = reshape(extract',11,[])';%换算成11列的
extract(all(extract==0,2),:)=[];%去掉全0行,剩下的是每个交互对象的，第一行是主体
%对客体做一下预测
[extract_pre] = envir_pre(extract,size(acc,1));%恒速度模型预测perception_time个步长，extract第一行是主体 输出形式是预测步长*客体x客体y
base_point = extract(1,1:2);%基准点
Vio = [extract(1,3) extract(1,4)];%前进方向&横向方向
prediction_point = base_point;%存放预测点的矩阵；
diss = [];%记录的距离
Risk = [];%用来存放风险,第一列是预测点，第二列是真实点
hengxiang = [];
standard_point = [];
for i = 1:size(acc,1)%计算每一步的收益
    extract_time_i = reshape(extract_pre(i,:)',2,[])';%将第i个步长恢复成n*2的模式  i=1是当前时刻
    extract_time_i = [extract_time_i extract(:,3:size(extract,2))];%后面的参数还给预测值，使其完整，这是环境信息，不包括主体
    %先计算 需要恒速度的那个点，确定约束范围；
    pre_point = [(base_point(1,1)+Vio(1,1)*0.12) (base_point(1,2)+Vio(1,2)*0.12)];%计算恒速度推进的点，也是搜索的原点； X轴是恒速度推进，
    acceleration = acc(i);%将横向加速度赋予当前参数
    %加上加速度
    truth_point = [pre_point(1,1) pre_point(1,2)+acceleration*0.12^2*0.5];%根据当前时刻的加速度求出真实轨迹点；
    Vio = [Vio(1,1) Vio(1,2)+acceleration*0.12];%将新的加速度赋予上一个步长的速度  vt=v0+at
    truth_Risk = Risk_calculation(truth_point,extract_time_i(2:size(extract_time_i,1),:),intrusion_cood_E,G,R_b,M_b,k1,k3,char_intrusion,char_end,index_end);%计算当前点的风险；
    %下面的运行时ctrl+r掉,我在12/24改变了这边
    real_Risk = Risk_calculation(extract_trajectory(index_in+i,4:5),extract_time_i(2:size(extract_time_i,1),:),intrusion_cood_E,G,R_b,M_b,k1,k3,char_intrusion,char_end,index_end);%计算当前点的风险；
    Risk = [Risk;[norm(truth_Risk) norm(real_Risk)]];%记录当前预测点和真实点的风险值
%     Risk = [Risk;norm(truth_Risk)];
    dis = Vio(1,1)*0.12;
    %判断是否满足约束条件  下面的循环0103注释掉的，因为没有风险上限值
%     if norm(truth_Risk)>threshold_Risk%若风险值大于阈值，给一些正向数，让他赶紧跑开；
%        dis = 2;
%     end
%     if norm(Vio)>(25/3.6)%若当前速度大于25km/h，则能给一个大的惩罚
%        dis = 2;
%     end
    prediction_point = [prediction_point;truth_point];%将预测轨迹存放到矩阵中
    standard_point = [standard_point;pre_point];%每一步搜索的标准点
    hengxiang = [hengxiang;abs(Vio(1,2)*0.12)];
%     dis = [dis extract_trajectory(index_in+i,6)*0.12];%把真实轨迹的收益放进去
    diss = [diss;dis];%将当前时刻的前进方向的位移加进去
    base_point = truth_point ; %将预测点赋予基准点
end
% output = sum(diss(:,1));%求总位移之和
% output = output + k4*(sum(Risk(:,1)));%需标定，两个的权重
output = (sum(Risk(:,1)));%风险最小
% disp(output)
% disp(norm(truth_Risk))
output1 = prediction_point;%输出预测点
output2 = Risk;%输出预测风险

% %计算误差并做图
 clf
    for j =1:20
        scatter(extract_trajectory(index_in+j,4),extract_trajectory(index_in+j,5),'*','b')
        hold on
        scatter(output1(j+1,1),output1(j+1,2),'*','r')
        pause(0.5)
    end
    ADE(extract_trajectory(index_in:index_in+20,4:5),output1)
end

