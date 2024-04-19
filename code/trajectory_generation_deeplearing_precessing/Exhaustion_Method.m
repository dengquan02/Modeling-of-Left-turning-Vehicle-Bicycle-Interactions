function [OPT,EXITFLAG,possible_points_allData,const_output,ID_best_inOPT,ID_best_inDis] = Exhaustion_Method(perception_time,Possible_points,OPT_th,mmax,mmin)
%通过预测对象车型等查看速度和加速度约束
% for k44 = 0.5
% Possible_points = possible_points;  %在这里面运行时需要运行该行代码
Possible_points(find((Possible_points(:,1)==0)&(Possible_points(:,2)==0)),:) = [];%删掉起终点一致的点
% OPT_th= 3;
% input_data = E_trajectory;
% % input_data = data_test;
% % a_limit = (input_data(find(input_data(:,14)==1),10));%10是速度，11是加速度    1是自行车  2是电动车
% a_limit = sort(abs(input_data(:,9)));
% % % % % % % a_limit = prctile(a_limit ,85);%求百分位数
% a_limit(size(a_limit,1)-500:size(a_limit,1),:) = [];
% % % median(a_limit)%中位数median
% mean(abs(a_limit))%平均值
% hist(a_limit)
% % % mode(a_limit)
% % hist(a_limit);
wigh_path = 0.5;
%% 以ga求解
% % Nu_point表示基于几个点表征的轨迹趋势
% % perception_time = 25;
% generating_lengh = 9;
% 
% Nu_point = (perception_time-1)/(generating_lengh-1);%两个点，终点和中间点
% 
% lb = zeros(Nu_point*2,1);
% ub = zeros(Nu_point*2,1);
% ub(1:Nu_point,1) = 2*pi;
% ub(Nu_point+1:Nu_point*2,1) = a_limit;%a_limit;%加速度的上界  单位m/s  0.2是加速度的平均值，从数据中来
% 
% %优化参数  
% options = gaoptimset('PopInitRange',[pi,0.15;pi,0.15],'PopulationSize',50, 'Generations', 200,'CrossoverFraction',0.8,'MigrationFraction',0.04 ); % 遗传算法相关配置   'StallGenLimit',20  
% 
% %利用遗传算法进行计算
% [OPT,FVAL,EXITFLAG,OUTPUT] =ga(@Excur_predict_1,(Nu_point*2),[],[],[],[],lb,ub,@nonlcon,options);%利用遗传算法进行参数标定  

%% 以穷举法求解
possible_points_in = [];%初始可行域
% optimal_solution = [];

%%  把目标值的地方以与真实轨迹的误差值进行替换，看看若机理万无一失的预测误差是多少？  正式计算时这一节是X掉的
global E_trajectory;
global extract_one
fit_dis = [];
index_Truth = find((E_trajectory(:,1)==extract_one(1,1))&(E_trajectory(:,2)==extract_one(1,2)));
Truth_trj = E_trajectory(index_Truth:index_Truth+perception_time-1,4:5);%真实轨迹
const_output_all = [];%存放各自的约束 -1表示满足，1表示不满足   [速度  曲率 风险 加速度  第一个点的曲率]

% 设置风险偏好系数 ！！调参主要部分
if extract_one(1,14) == 1%动态调整风险偏好系数  自行车  风险的份额
    k4 = 0.2;%PPT上的结果采用的是0.2
elseif extract_one(1,14) == 2  %电动车
    k4 = 0.2;%PPT上的结果采用的是0.1
end

%% 以下是计算目标值
for i = 1:size(Possible_points,1)   %潜在轨迹个数
        %% 提取潜在轨迹
        Potential_trajectory_allData = reshape(Possible_points(i,3:size(Possible_points,2))',[],perception_time)';%将一行还原成17行*14列  possible_points前面两列是序号
        %% 以下是逆归一化
        [Potential_trajectory_allData_output] = Anti_normalizating_NEW(Potential_trajectory_allData,perception_time,mmax,mmin);%  反归一化，利用之前训练预处理数据的mmaxm和mmin
        %% 继续计算
        Potential_trajectory = Potential_trajectory_allData_output(:,1:2);%只取前两列是研究主体位置
        fit_dis = [fit_dis; ADE(Truth_trj,Potential_trajectory)];%计算与真实轨迹的误差的时候进行计算
%        %做图出来看一看
%         hold on
%         figure(1)
%         plot(Potential_trajectory(:,1),Potential_trajectory(:,2),'black')  %o v *   %预测轨迹
%         hold on
%         scatter(Potential_trajectory(perception_time,1),Potential_trajectory(perception_time,2),'o','m')
        Potential_trajectory_1D = reshape(Potential_trajectory, 1 , []);%reshpe成一行，前部分是[1x,2x,3x]，后部分是[1y,2y,3y]
%         以上弄出来真实轨迹，下面按照计算每个潜在轨迹的目标值
        [const,~] = nonlcon_Complete_path(Potential_trajectory,perception_time);%求约束
        const_output_all = [const_output_all sign(const)];%横向排列
        [~,~,~,output_dis,output_risk,sum_Dis_Path] = Trajectory_benefit_calculating(Potential_trajectory); %求fitt  利用Trajectory_benefit_calculating求取每个潜在轨迹的fitt
        possible_points_in = [possible_points_in;[Possible_points(i,1:2) output_dis sum(sign(const)) Potential_trajectory_1D output_risk,sum_Dis_Path]];   %待选终点 [前后位置序号i 前后位置序号j 效益值 约束值 一维轨迹坐标 ]     possible_points_in = [possible_points_in;[Possible_points(i,1:2) fitt sum(sign(const)) Potential_trajectory_1D output2]];   %待
end
%% 根据样本情况进行归一化，并赋予总目标值
% dis_min = 0.5 * min(possible_points_in(:,size(possible_points_in,2)));%不要用最小值去归一化，以免数据差异太大
sum_Dis_Path = possible_points_in(:,size(possible_points_in,2));%不进行归一化     %(possible_points_in(:,size(possible_points_in,2))-dis_min)/(max(possible_points_in(:,size(possible_points_in,2)))-dis_min);%提取出来每个样本的总路程,并进行归一化；（即每个样本的路径的归一化结果） 备用： (possible_points_in(:,size(possible_points_in,2)));
%对 sum_Dis_Path进行赋值归一化
risk_handle1 = [(1:size(possible_points_in,1))' sum_Dis_Path];
risk_handle1 = sortrows(risk_handle1,2);
risk_handle1 = [risk_handle1 (1:size(possible_points_in,1))'];
risk_handle1 = sortrows(risk_handle1,1);
sum_Dis_Path = risk_handle1(:,3);
sum_Dis_Path = ((sum_Dis_Path)-(min(sum_Dis_Path)))./(max(sum_Dis_Path)-min(sum_Dis_Path))+0.1;
% 赋值归一化结束
possible_points_in(:,size(possible_points_in,2)) = [];%把路径信息删除掉
% 下面最后一列是风险信息   下面第二行控制是否风险计算中包含总路径长度
possible_points_in(:,size(possible_points_in,2)) = ((possible_points_in(:,size(possible_points_in,2)))-(min(possible_points_in(:,size(possible_points_in,2)))))./((max(possible_points_in(:,size(possible_points_in,2))))-(min(possible_points_in(:,size(possible_points_in,2)))))+0.1;%将平均轨迹点的风险值按照（x-min）/(max-min)的方法进行归一化；
possible_points_in(:,size(possible_points_in,2)) = sum_Dis_Path.*possible_points_in(:,size(possible_points_in,2));%sum_Dis_Path将平均风险乘以路径长度，构成路径风险的定义
% 风险的顺序赋值归一化   对possible_points_in(:,size(possible_points_in,2))
risk_handle = [(1:size(possible_points_in,1))' possible_points_in(:,size(possible_points_in,2))];
risk_handle = sortrows(risk_handle,2);
risk_handle = [risk_handle (1:size(possible_points_in,1))'];
risk_handle = sortrows(risk_handle,1);
possible_points_in(:,size(possible_points_in,2)) = risk_handle(:,3);
%  顺序赋值结束
possible_points_in(:,size(possible_points_in,2)) = ((possible_points_in(:,size(possible_points_in,2)))-(min(possible_points_in(:,size(possible_points_in,2)))))./((max(possible_points_in(:,size(possible_points_in,2))))-(min(possible_points_in(:,size(possible_points_in,2)))))+(min(possible_points_in(:,size(possible_points_in,2))))*0.1;%将总风险值归一化；

dis_allSample = (((-possible_points_in(:,3))-(min(-possible_points_in(:,3))-(min(-possible_points_in(:,3))/10)))./((max(-possible_points_in(:,3)))-(min(-possible_points_in(:,3)))));%将位移值按照（x-min）/(max-min)的方法进行归一化；  dis_allSample = (((-possible_points_in(:,3))-(min(-possible_points_in(:,3))-(min(-possible_points_in(:,3))/10)))./((max(-possible_points_in(:,3)))-(min(-possible_points_in(:,3)))));%      %dis_allSample = (((-possible_points_in(:,3))-(min(-possible_points_in(:,3))))./((max(-possible_points_in(:,3)))-(min(-possible_points_in(:,3)))));
dis_allSample = -dis_allSample;
%真正计算效用，
possible_points_in(:,3) = (1-k4).* (dis_allSample*1) + k4.* possible_points_in(:,size(possible_points_in,2));
disp(dis_allSample);%路程
disp(possible_points_in);%risk
%%  把目标值的地方以与真实轨迹的误差值进行替换，看看若机理万无一失的预测误差是多少？ 
possible_points_in_fit_dis = [possible_points_in(:,1:2) fit_dis (ones(size(possible_points_in,1),1)*-5) possible_points_in(:,5:size(possible_points_in,2))];%将fit以与真实轨迹的误差替换掉，找到生成轨迹中误差最小的轨迹；
% 以上结束

%% 以下是在选最优
% 对fit降序排列
possible_points_allData = sortrows(possible_points_in,3);
optimal_solution = sortrows(possible_points_in(:,1:size(possible_points_in,2)-1),3);%正号表示升序排列  找最优值  按    optimal_solution = sortrows(possible_points_in(:,1:size(possible_points_in,2)-1),3);%正号表示升序排列
save optimal_solution
% 对fit_dis降序排列
possible_points_allData_dis = sortrows(possible_points_in_fit_dis,3);
optimal_solution_dis = sortrows(possible_points_in_fit_dis(:,1:size(possible_points_in_fit_dis,2)-1),3);%正号表示升序排列  找最优值  按照第三列升序排列  找fitt最小的，即是效益值最大的    optimal_solution_dis = sortrows(possible_points_in_fit_dis(:,1:size(possible_points_in_fit_dis,2)-1),3);%正号表示升
%% 以fit_dis为目标值进行，正式计算时，这一小节不运行；
%optimal_solution = optimal_solution_dis; %自动选择最接近的预测轨迹

%% 旧的寻找最优的方法
index_OPT = 1;%记录取最优值的第几个为所选；
OPT_th_data_5 = [];
OPT_th_data_3 = [];

for i = 1:size(optimal_solution,1)
    if optimal_solution(i,4) == -5  %-5表示满足约束条件
        OPT_th_data_5 = [OPT_th_data_5; [index_OPT i]]; 
        index_OPT = index_OPT + 1;
    elseif optimal_solution(i,4) == -3  %-3表示满足约束条件
        OPT_th_data_3 = [OPT_th_data_3; i]; 
    end
end
if isempty(OPT_th_data_5)%若循环完还是没有满足约束条件的，则直接输出不满足条件的最优值
    if isempty(OPT_th_data_3)
        OPT_allData = optimal_solution(OPT_th,:);%不满足约束的最优
        const_output = optimal_solution(OPT_th,4);
        EXITFLAG = 1;%表示无可行解，输出的不满约束条件的最优值
    elseif size(OPT_th_data_3,1) >= 1
        OPT_allData = optimal_solution(OPT_th_data_3(1),:);%不满足约束的最优
        const_output = optimal_solution(OPT_th_data_3(1),4);
        EXITFLAG = 0;%表示无可行解，输出的不满约束条件的最优值
    end
elseif size(OPT_th_data_5,1) >= OPT_th
    OPT_allData = optimal_solution(OPT_th_data_5(OPT_th,2),:);%求最优
    const_output = optimal_solution(OPT_th_data_5(OPT_th,2),4);
    EXITFLAG = 0;%表示正常退出，找到了满足约束的最优值
else
    OPT_allData = optimal_solution(OPT_th_data_5(size(OPT_th_data_5,1),2),:);%求最优
    const_output = optimal_solution(OPT_th_data_5(size(OPT_th_data_5,1),2),4);
    EXITFLAG = 0;%表示正常退出，找到了满足约束的最优值
end

%% 以上穷举法求轨迹完成,一下输出OPT
% OPT = OPT_allData(5:size(OPT_allData,2));%只取后面的轨迹

%% 计算选取的轨迹是可选轨迹的第几位，同时最优解在第几位
optimal_solution_5 = optimal_solution(find(optimal_solution(:,4)==-5),:);
optimal_solution_3 = optimal_solution(find(optimal_solution(:,4)==-3),:);
optimal_solution_1 = optimal_solution(find(optimal_solution(:,4)==-1),:);
optimal_solution_11 = optimal_solution(find(optimal_solution(:,4)==1),:);
optimal_solution_33 = optimal_solution(find(optimal_solution(:,4)==3),:);
optimal_solution_order = [optimal_solution_5;optimal_solution_3;optimal_solution_1;optimal_solution_11;optimal_solution_33];%重新排序后的

OPT = optimal_solution_order(OPT_th,5:size(optimal_solution_order,2));
index_ii = find((Possible_points(:,1)==optimal_solution_dis(1,1))&(Possible_points(:,2)==optimal_solution_dis(1,2)));%找到真实轨迹的约束情况
const_output = const_output_all(:,index_ii);
% EXITFLAG = 1;
% const_output = optimal_solution_order(OPT_th,4);
ID_best_inOPT = find(optimal_solution_order(:,1)==optimal_solution_dis(1,1)&optimal_solution_order(:,2)==optimal_solution_dis(1,2)) ;  %真实值在第几位
if isempty(ID_best_inOPT)
    ID_best_inOPT = 0;
%     EXITFLAG = 0;
end
ID_best_inDis = find(optimal_solution_dis(:,1)==optimal_solution_order(OPT_th,1)&optimal_solution_dis(:,2)==optimal_solution_order(OPT_th,2)) ;%所选值在真实值的第几位
% ID_best_inDis
%风险和收益图来看看是否反比的关系
% bar(dis_allSample)
% hold on
% bar(possible_points_in(:,size(possible_points_in,2)))
% hold on
% bar(possible_points_in(:,3))
%  %% 做出所选轨迹
% hold on
% scatter(Truth_no(:,4),Truth_no(:,5),50,'o','b')  
% i=find(Possible_points(:,1)==optimal_solution_order(OPT_th,1)&Possible_points(:,2)==optimal_solution_order(OPT_th,2)) ;
% Potential_trajectory_allData = reshape(Possible_points(i,3:size(Possible_points,2))',[],perception_time)';%将一行还原成17行*14列  possible_points前面两列是序号
% [Potential_trajectory_allData_output] = Anti_normalizating_NEW(Potential_trajectory_allData,perception_time,mmax,mmin);%  反归一化，利用之前训练预处理数据的mmaxm和mmin
% Potential_trajectory = Potential_trajectory_allData_output(:,1:2);%只取前两列是研究主体位置
% hold on
% scatter(Potential_trajectory(:,1),Potential_trajectory(:,2),50,'o','r')  %o v *   %做出所选轨迹
% optimal_solution_dis(find(optimal_solution_dis(:,1)==optimal_solution_order(OPT_th,1)&optimal_solution_dis(:,2)==optimal_solution_order(OPT_th,2)),3)
% figure(2)
% [input_order] = Utility_heat_map(optimal_solution_order);%做个效用的热力图看看
% 
% 
% figure(3)%做个效用和ADE的折线对比图看看
% utility_ALL = input_order(:,1:3);
% ADE_ALL = optimal_solution_dis(:,1:3);
% for din = 1:size(utility_ALL,1)
%     IDD = find(ADE_ALL(:,1)==utility_ALL(din,1)&ADE_ALL(:,2)==utility_ALL(din,2));
%     utility_ALL(din,4:6)=ADE_ALL(IDD,:);
% end
% utility_ALL(:,4:5) = [];
% utility_ALL(:,size(utility_ALL,2)) = (utility_ALL(:,size(utility_ALL,2))-min(utility_ALL(:,size(utility_ALL,2))))/(max(utility_ALL(:,size(utility_ALL,2)))-min(utility_ALL(:,size(utility_ALL,2))));
% 
% 
% utility_ALL = sortrows(utility_ALL,4);
% end
