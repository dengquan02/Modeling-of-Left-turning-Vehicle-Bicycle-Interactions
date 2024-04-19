function [output] = Excur_predict_1(acc)
%Excur_predict_1用来求优化的轨迹，Excur_predict_2用OPT来求结果
%本函数的目标是计算收益值；
%acc是加速度集合（一个步长的加速度），是极坐标；[角度，极径]是问题的解，20*2   极坐标的原因是为了在约束方程里简单
% acc = [3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;3 0.1;];
% acc = OPT;
perception_time = 25;
generating_lengh = 9; %该指标表示第一个间隔点的标号，即连续的是2，或7个间隔点是9；

timess = round(size(acc,2)/2);
acc =[acc(1:timess)' acc(timess+1:timess*2)'];%一行换成两列


%%
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
global extract_one

%% 利用差值法对加速度补充完整
[current_acc(1,1), current_acc(1,2)] = cart2pol(extract_one(1,8),extract_one(1,9));%将当前加速度换算之后代入
[complete_acc] = acc_interpolation(acc,current_acc,timess,perception_time,generating_lengh);%插值得到完整加速度集合
acc = complete_acc;
generating_lengh = 2;%插值之后这个就等于2了
interval = 0:generating_lengh-1:perception_time-1;%预测点的序号
%%
global intrusion_cood_E
if extract_one(1,14) == 1%动态调整风险偏好系数  自行车
    k4 = 5;%PPT上的结果采用的是4
elseif extract_one(1,14) == 2  %电动车
    k4 = 3;%PPT上的结果采用的是3
end
% intrusion_cood_E = [47.43 27;47.43 23.5;3 27;3 23.5];

extract = extract_one;%预测的帧
extract(:,1:3) = [];
extract = reshape(extract',11,[])';%换算成11列的
extract(all(extract==0,2),:)=[];%去掉全0行,剩下的是每个交互对象的，第一行是主体
%对客体做一下预测
[extract_pre] = envir_pre(extract,perception_time);%恒速度模型预测perception_time个步长，extract第一行是主体 输出形式是预测步长*客体x客体y
base_point = extract(1,1:2);%基准点
Vio = [extract(1,3) extract(1,4)];%前进方向&横向方向
prediction_point = base_point;%存放预测点的矩阵；
diss = [];%记录的距离
Risk = [];%用来存放风险,第一列是预测点，第二列是真实点
hengxiang = [];
standard_point = [];
Dis_Path = [];%计算路程

interval(:,1) = [];
time_interv = 0.12 * (generating_lengh-1);%新的时间间隔  %若利用贝塞尔曲线生成完整点就不用改成大时间间隔了，若没有则需要变化


%% 计算目标值 （轨迹趋势点）
for i = 1:size(interval,2)%计算每一步的收益  
    extract_time_i = reshape(extract_pre(interval(i),:)',2,[])';%将第i个步长恢复成n*2的模式  i=1是当前时刻
    extract_time_i = [extract_time_i extract(:,3:size(extract,2))];%后面的参数还给预测值，使其完整，这是环境信息，不包括主体
    %先计算 需要恒速度的那个点，确定约束范围；
    pre_point = [(base_point(1,1)+Vio(1,1)*time_interv) (base_point(1,2)+Vio(1,2)*time_interv)];%计算恒速度推进的点，也是搜索的原点；
    [acceleration(1,1),acceleration(1,2)] = pol2cart(acc(i,1),acc(i,2));%将加速度的极坐标转化为直角坐标
    %将加速度换算至速度参考系
    truth_point = [pre_point(1,1)+acceleration(1,1)*(time_interv)^2*0.5 pre_point(1,2)+acceleration(1,2)*(time_interv)^2*0.5];%根据当前时刻的加速度求出真实轨迹点；
    Vio = [Vio(1,1)+acceleration(1,1)*time_interv Vio(1,2)+acceleration(1,2)*time_interv];%将新的加速度赋予上一个步长的速度  vt=v0+at
    truth_Risk = Risk_calculation(truth_point,extract_time_i(2:size(extract_time_i,1),:),intrusion_cood_E,G,R_b,k1,k3,char_intrusion,char_end,index_end,char_intrusion_right,char_end_right,index_end_right);%计算当前点的风险；
    %下面的运行时ctrl+r掉,我在12/24改变了这边
%     real_Risk = Risk_calculation(extract_trajectory(index_in+i,4:5),extract_time_i(2:size(extract_time_i,1),:),intrusion_cood_E,G,R_b,M_b,k1,k3,char_intrusion,char_end,index_end);%计算当前点的风险；
%     Risk = [Risk;[norm(truth_Risk) norm(real_Risk)]];%记录当前预测点和真实点的风险值
  
    Risk = [Risk;norm(truth_Risk)];
    dis = Vio(1,1)*time_interv;
    dis_path = abs(norm(Vio));%求这个步长里的路程
    %判断是否满足约束条件  下面的循环0103注释掉的，因为没有风险上限值
%     if norm(truth_Risk)>5%若风险值大于阈值，给一些正向数，让他赶紧跑开；
%        dis = 2;
%     end
%     if norm(Vio)>(25/3.6)%若当前速度大于25km/h，则能给一个大的惩罚
%        dis = 2;
%     end
    prediction_point = [prediction_point;truth_point];%将预测轨迹存放到矩阵中
    standard_point = [standard_point;pre_point];%每一步搜索的标准点
    hengxiang = [hengxiang;abs(Vio(1,2)*time_interv)];
%     dis = [dis extract_trajectory(index_in+i,6)*0.12];%把真实轨迹的收益放进去
    diss = [diss;dis];%将当前时刻的前进方向的位移加进去
    Dis_Path = [Dis_Path,dis_path];%路程长度
    base_point = truth_point ; %将预测点赋予基准点
end

% %% 利用贝塞尔曲线生成轨迹
% % 赋值
% all_points = [];%存放完整的轨迹点（包括决策点和生成点）
% for j = 1:size(prediction_point,1)-1%将每段补充
%     start_point = prediction_point(j,:);%整合成终点， [ x, y]
%     end_point = prediction_point(j+1,:);%整合成终点， [ x, y]
%     [traj_points] = Path_generation(start_point,end_point,generating_lengh-1);%输出的是perception_time个轨迹点，包括起终点在内  generating_lengh-1
%     traj_points(size(traj_points,1),:) = [];%删掉每段的讫点，即下个循环的起点；
%     all_points = [all_points;traj_points];%整合为一个轨迹矩阵，应该是完整的矩阵，包括决策点和生成点
% end
% 
% %% 再次计算目标（完整轨迹点）
% time_interv = 0.12 ;
% for i = 1:size(all_points,2)%计算每一步的收益  
%     extract_time_i = reshape(extract_pre(i,:)',2,[])';%将第i个步长恢复成n*2的模式  i=1是当前时刻
%     extract_time_i = [extract_time_i extract(:,3:size(extract,2))];%后面的参数还给预测值，使其完整，这是环境信息，不包括主体
%     truth_Risk = Risk_calculation(all_points(i,:),extract_time_i(2:size(extract_time_i,1),:),intrusion_cood_E,G,R_b,k1,k3,char_intrusion,char_end,index_end,char_intrusion_right,char_end_right,index_end_right);%计算当前点的风险；
%     Risk = [Risk;norm(truth_Risk)];
%     %以上是计算风险，以下是计算距离
%     dis = all_points(i+1,1)-all_points(i,1);%这个步长内前进方向的位移,出来是负值
%     dis_path = abs(norm(all_points(i:i+1,:)));%求这个步长里的路程
%     %判断是否满足约束条件  下面的循环0103注释掉的，因为没有风险上限值
% %     if norm(truth_Risk)>5%若风险值大于阈值，给一些正向数，让他赶紧跑开；
% %        dis = 2;
% %     end
% %     if norm(Vio)>(25/3.6)%若当前速度大于25km/h，则能给一个大的惩罚
% %        dis = 2;
% %     end
% %     dis = [dis extract_trajectory(index_in+i,6)*0.12];%把真实轨迹的收益放进去
%     diss = [diss;dis];%将当前时刻的前进方向的位移加进去
%     Dis_Path = [Dis_Path,dis_path];%路程长度
% end

%% 输出目标值
% output = output + (sum(hengxiang));
% output = output + k4*(sum(Risk(size(Risk,1),1)));%风险只计算最后一个点的风险值
k4=0.1;  %k4=0.32;
output = (1-k4)*(sum(diss(:,1))) + (k4)*(mean(Risk(:,1)));%前后    *sum(Dis_Path)
% disp('目标值是')
% disp(output)
% disp((sum(diss(:,1))) );
% disp(((mean(Risk(:,1))))*2)
% disp(norm(truth_Risk))
output1 = prediction_point;%输出预测点
output2 = Risk;%输出预测风险
end

