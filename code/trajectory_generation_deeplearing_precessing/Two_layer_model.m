%% 该脚本是双层轨迹预测模型的主函数
% 共分为几个部分，分别是：
%% 在这里面挑选一下轨迹
% ID_out = [];
% for i = 22%1:E_trajectory(size(E_trajectory,1),1)   size(ID_out,2)
%     index= i;%ID_out(1,i);
%     figure(1)
%     clf
%     OPtertion = E_trajectory((E_trajectory(:,1)==index),:);
% %     if min(OPtertion(:,5))<=22
% %         ID_out = [ID_out,i];
% %     end
%     for j = 1:size(OPtertion,1)
%         inter_OBJ = reshape(OPtertion(j,4:size(OPtertion,2))',11,[])';
%         inter_OBJ(all(inter_OBJ==0,2),:) = [];%删除零行
%         hold on
%         scatter(inter_OBJ(1,1),inter_OBJ(1,2),'o','b','linewidth',1);
%         if size(inter_OBJ,1)>1
%             hold on
%            scatter(inter_OBJ(2:size(inter_OBJ,1),1),inter_OBJ(2:size(inter_OBJ,1),2),'+','black','linewidth',1);
%         end
% %         pause(0.5)
%     end
% %     pause(1)
%     disp(index)
%     i = i +1;
% end
%
tic
%% 该部分是数据预处理，最终得到E_trajectory
%%% ①读取之前的测试数据序号
load('data_new.mat');%load('result(ADE=0.08生成未知量调整后3.6训练0929_2).mat');%load('data_precessing(0831_1)ADE=0.0358).mat')
load('data_new2.mat');
csvwrite('mmax(20211124_1).csv',mmax);
csvwrite('mmin(20211124_1).csv',mmin);
% clearvars -except sample_test
mmax = csvread('mmax(20211124_1).csv');%读最大值数据   %mmax = csvread('mmax(20210831_1).csv');%读最大值数据
mmin = csvread('mmin(20211124_1).csv');%读最小值数据   %mmin = csvread('mmin(20210831_1).csv');%读最小值数据

Mytest_ID = sample_test(:,1:3);%读取上述数据中测试数据的序号   sample_test在以前保存的数据之中
% csvwrite('ID_mutation.csv',ID_mutation);%写出突变行为ID
% csvwrite('ID_mutation_small.csv',ID_mutation_small);%写出突变行为ID 17个步长的
% ID_mutation_small = ID_mutation; % 17个步长的
% ID_mutation = csvread('ID_mutation.csv');%读取突变行为ID
% ID_mutation = csvread('ID_mutation_small.csv');%读取突变行为ID
%%%  ②输入一些参数
benchmark_EXXRoad = csvread('benchmark_EXXRoad.csv');%读取基准信息
% csvwrite('benchmark_EXXRoad.csv',benchmark_EXXRoad);%读取基准信息
global intrusion_cood_E
intrusion_cood_E= csvread('intrusion_cood_EXXRoad.csv');%读取机动车道基准信息，表示基准点坐标，里面的排列应该是四个点，当道路纵向向上时，分别为右下、左下、右上、左上


perception_time = 17;%即是预测步长   17/33
generating_lengh = perception_time;
n_input=generating_lengh;%样本的输入轨迹点个数
Num_No=6;%交互的非机动车对象的个数（目前是按照距离最短的计算,参考齐骁6个）
Num_V=6;%交互的机动车个数

% %%% ③数据预处理
% [E1]=xlsread('M:\New_try\三分类处理完成数据（T=0.12s）.xlsx',1);%东进口直行非机动车
% [E1V]=xlsread('M:\New_try\三分类处理完成数据（T=0.12s）.xlsx',2);%东进口直行机动车
% [W1V]=xlsread('M:\New_try\三分类处理完成数据（T=0.12s）.xlsx',3);%西进口左转机动车
% global E_trajectory;
% [E_trajectory] = input_data_XianXiaRoad(E1,E1V,W1V,Num_No,Num_V);%数据预测
%
% %%% 数据预处理结束  最终的目的是得到E_trajectory

%% 预测轨迹  以Mytest_ID的序号进行预测
%%% 开始计算，先赋值

test_result_no = [];%记录计算结果
data_EXITFLAG = [];%记录GA的退出条件
where_best = [];%记录真实值在目标值排序的第几位，0表示不满足约束大于3（一共5分）个；
where_const = [];
where_OPT = [];%记录最优值在真实值排序的第几位
% Parameter_cal = csvread('Parameter_cal_store.csv');%从已保存内容中读取基准信息

%% 读取测试数据
%   数据采用全部数据
input = E_trajectory;
test_ID = Mytest_ID(1:generating_lengh:size(Mytest_ID,1),:); % 得到测试数据的ID

%% 将test_ID换算成34个步长的
ID_set_dele = [];
for i = 1:size(test_ID,1)-1
    see_ID = test_ID(i,2:3);%读取当前ID
    End_ID = see_ID(1,2) + perception_time ;
    if End_ID > test_ID(i+1,3)&&see_ID(1,1)==test_ID(i,2)
        ID_set_dele = [ID_set_dele;i+1];
    end
end
test_ID(ID_set_dele,:) = [];%删除掉可能会使测试数据重合的测试样本
%% 从这里开始  以下先算50个样本
for ID = 1:size(test_ID,1)%计算每条轨迹   %for ID = 1:size(test_ID,1)%计算每条轨迹    计算突变行为%for ID = 1:size(ID_mutation,1)%
    index = test_ID(ID,2);%轨迹ID
    index_in = test_ID(ID,3); %轨迹点ID
    %     index = ID_mutation(ID,1);
    %     index_in = ID_mutation(ID,2);
    %         index = 272; %78;%90
    %     index_in = 32;%20; %86
    %%% 提取测试样本，%单独样本测试时_使用
    %    index = 196;
    %    index_in = 1;
    extract_trajectory = input((input(:,1) == index),:);%提取轨迹编号为index的轨
    if index_in+perception_time > size(extract_trajectory,1) %若剩余轨迹点不足以在预测步长内，则跳出该次循环
        continue
    end
    extract_trajectory = extract_trajectory(index_in:index_in+perception_time-1,:);%提取预测轨迹
    
    %% 开始计算
    global extract_one
    extract_one = extract_trajectory(1,:);%当前时刻的状态数据
    %     try
    tic
    global Parameter
    %       Parameter = Parameter_cal;%标定的参数
    Parameter = [1 0.8 1 5 0.2 0.12 1 5 0.2 0.03]; %手动填的参数(10个)  Parameter = [1 0.8 1 5 0.2 0.12 1 5 0.2 0.03];%计算的时候填的参数（202107022）
    %       先生成所有轨迹，再去选择
    [possible_points,status ] = Batch_trajectory_generation(extract_one,perception_time,0.4,mmax,mmin);%一次性调用py文件，生成素有可选轨迹   0.4是潜在终点分辨率  3是横向范围的序号
    disp(status)
    if status ~= 0 %判断一下是否调用成功，若不成功则跳出该次循环
        continue
    end
    %第三个参数，一般选择排名最好的所以是1，可以修改
    [OPT,EXITFLAG,optimal_solution,const_output,ID_best_inOPT,ID_best_inDis] = Exhaustion_Method(perception_time,possible_points,1,mmax,mmin);% 利用深度学习生成完整轨迹进行穷举法进行求解
    where_best = [where_best;ID_best_inOPT];%真实值在第几位
    where_OPT = [where_OPT;ID_best_inDis];%所选值在真值的第几位
    where_const = [where_const const_output];%每个样本横向排列，-1表示满足约束，1表示不满足约束
    data_EXITFLAG =[data_EXITFLAG;EXITFLAG  ];%-2表示未找到可行点
    toc
    %     catch
    %           continue
    %     end
    %     test_result_precessing = [[floor(ID/(perception_time+1)) index index_in OPT]];
    test_result_no = [test_result_no;[size(where_best,1) index index_in OPT sum(sign(const_output))]];%index是轨迹编号；index_in是轨迹内预测点的编号； OPT是优化后的加速度集合
    disp(['已完成',num2str(ID/size(test_ID,1)*100),'%'])
end


%%  计算误差
% ID_check = find(test_result_no(:,2)==497)%&test_result_no(:,3)==40)

MDE_no = [];%记录平均距离误差
ILP = [];
FDE_no = [];%存放最终误差
dele_j = [];
accuracy_if_all = [];%存放准确性
accuracy_all = [];%存放误差
Type_All = [];%存放车辆类型
test_result_precessing = test_result_no;

for i = 1:size(test_result_precessing,1)
    index_ce = find(input(:,1)==test_result_precessing(i,2)&(input(:,2)==test_result_precessing(i,3)));
    Truth_no = input(index_ce : index_ce + perception_time-1,:);%真实轨迹
    predicted_trajectory = reshape(test_result_precessing(i,4:size(test_result_precessing,2)-1), [] , 2);%reshpe成两列，第1列是[1x；2x；3x]，第2列是[1y；2y；3y]
    predicted_trajectory(1,1:2) = Truth_no(1,4:5);%避免后面出现错误，将起点直接赋予一下预测点；
    %      Type_All = [Type_All; E_trajectory(find((E_trajectory(:,1)==test_result_precessing(i,2))&(E_trajectory(:,2)==test_result_precessing(i,3))),14)];
    %     [ILP_single] = LIP_cal(Truth_no(:,4:5),output1,0);
    %     [ang_dis] = Curvature_dis(Truth_no(:,4:5),output1);%新的行为趋势计算方法（未完成）·
    %     [accuracy_if,accuracy] = cross_dis(Truth_no(:,4:5),output1);%针对机动车侧的计算横向偏移是否预测准确，标准是超过1.5以内且在0.5以内
    %       interAll = Truth_no;
    %       interAll(:,1:14) = [];%去掉无用项和交互对象
    %
    %       hold on
    figure(1)
    clf
    %     for j =1:perception_time
    %         inter_one = reshape(interAll(j,:)',11,[])';
    %         inter_one(all(inter_one==0,2),:)=[];
    %         hold on
    scatter(Truth_no(:,4),Truth_no(:,5),50,'*','b')  %真实轨迹
    hold on
    scatter(predicted_trajectory(:,1),predicted_trajectory(:,2),50,'*','black')  %o v *   %预测轨迹
    hold off
    %         axis([-50 -0 10 30]);
    %         hold on
    %         scatter(inter_one(:,1),inter_one(:,2),ones(size(inter_one,1),1)*50,50,'*','b')  %o v *   %交互轨迹
    pause(1)
    %     i = i+ 1;
    %         trend_points = Truth_no;%未   trend_points = [Truth_no(9,4:5);Truth_no(17,4:5);Truth_no(25,4:5);Truth_no(size(Truth_no,1),4:5)];%未包括已知点
    %         output1_part = predicted_trajectory;%未
    %         ADE(trend_points(2:size(trend_points,1),4:5),output1_part(2:size(output1_part,1),:))
    %     end
    %     set(gcf,'color','none')
    %     set(gca,'color','none')
    %     legend('trurth behavior','prediction behavior','prediction behavior','prediction behavior')
    %     set(gca,'FontSize',15,'LineWidth',0.5,'FontName','Times New Roman')
    %     title(['i等于',num2str(i),'  平均距离误差为',num2str(ADE(Truth_no(:,4:5),output1)),'  ILP为',num2str(ILP_single),'  形状差为',num2str(ang_dis)]);
    %     pause(2)
    %     disp(ADE(Truth_no(:,4:5),output1))
    %     disp('风险是')
    %     disp(max(output2(:,1)));
    %     disp(max(output2(:,2)));
    %计算轨迹是够连续、正确
    %     abs(max(Truth_no(:,5))-min(Truth_no(:,5)))
    %下面插回来
    dis_head = [];
    dis_head_pre = [];
    for h = 1:perception_time-1
        dis_head = [dis_head;(Truth_no(h,4)-Truth_no(h+1,4))];
        dis_head_pre = [dis_head_pre;(predicted_trajectory(h,1)-predicted_trajectory(h+1,1))];
    end
    if (sum(sign(dis_head))~=perception_time-1)||(sum(sign(dis_head_pre))~=perception_time-1)
        dele_j = [dele_j i];
    end
    trend_points = Truth_no;%未   trend_points = [Truth_no(9,4:5);Truth_no(17,4:5);Truth_no(25,4:5);Truth_no(size(Truth_no,1),4:5)];%未包括已知点
    output1_part = predicted_trajectory;%未
    [MDE_no] = [MDE_no ; ADE(trend_points(2:size(trend_points,1),4:5),output1_part(2:size(output1_part,1),:))];%计算平均距离误差  % [MDE_no] = [MDE_no ; ADE(trend_points(2:size(trend_points,1),:),output1(2:size(output1,1),:))];%计算平均距离误差
    [FDE_no] = [FDE_no ; ADE(trend_points(size(trend_points,1),4:5),output1_part(size(output1_part,1),:))];%计算平均距离误差
    [ILP_single] = LIP_cal(trend_points(:,4:5),output1_part,0);   % [ILP_single] = LIP_cal(trend_points,output1,0);
    ILP = [ILP;ILP_single];
    %     accuracy_if_all = [accuracy_if_all;accuracy_if];
    %     accuracy_all = [accuracy_all;accuracy];
end
% mean(MDE_no(Type_All==1))
% mean(FDE_no(Type_All==1))
% mean(ILP(Type_All==1))

mean(MDE_no)
mean(FDE_no)
mean(ILP)
% 查看效用函数的的优劣，看理论最好和效用函数选出的
figure(2)
hist(MDE_no)
where_best_hand = where_best;
where_best_hand(find(where_best_hand>100),:)=[];
E_trajectory(find(abs(E_trajectory(:,11))>2),:)=[];
figure(3)
hist(where_best_hand)  %真实值以fit排序的次序分布
% size(find((1<=where_best_hand)&(where_best_hand<=1)),1)/63  %查看
figure(4)
hist(where_OPT,20)  %所选值在真实值的次序分布
% size(find(where_OPT==1),1)/63  %查看所选轨迹是第几位的真实轨迹；
save('result双层模型17个步长所有行为0_4分辨率(20211227_1)')
disp('the job is done!!!')
toc
%
% % 结束
% %% 一些处理
% %查看约束条件满足的概率
size(find(sign(where_const(5,:))==-1),2)/24
% %% 找到里面的突变行为
% MDE_no_mutation = [];
% FDE_no_mutation =[];
% ILP_mutation =[];
% curvature_Truth_all = [];
% Type_mutation =[];
% ID_mutation = [];  %以大曲率行为为标准的突变行为ID
% MDE_no_lateral = [];
% FDE_no_lateral =[];
% ILP_lateral =[];
% Type_lateral_displacement =[];
% ID_lateral_displacement =[];%以横向偏移为标注的突变行为ID
% lateral_displacement_all =[];
% for i = 1:size(test_result_precessing,1)
%     index_ce = find(input(:,1)==test_result_precessing(i,2)&(input(:,2)==test_result_precessing(i,3)));
%     Truth_no = input(index_ce : index_ce + perception_time-1,:);%真实轨迹
%     predicted_trajectory = reshape(test_result_precessing(i,4:size(test_result_precessing,2)-1), [] , 2);%reshpe成两列，第1列是[1x；2x；3x]，第2列是[1y；2y；3y]
%     predicted_trajectory(1,1:2) = Truth_no(1,4:5);%避免后面出现初五，将起点直接赋予一下预测点；
%     trend_points = Truth_no;%真实轨迹
%     output1_part = predicted_trajectory;%预测轨迹
%     % 先利用真实轨迹找到突变行为
%     curvature_Truth = mean(abs(trend_points(:,13)));%定义为平均曲率超过一定限度的轨迹
%     [curvature_Truth_all] =[curvature_Truth_all; curvature_Truth];%存放每个突变行为的平均曲率
%     if curvature_Truth>=0.05 %如果平均曲率超过这个限度，则拿出来，就是突变行为
%         ID_mutation = [ID_mutation; test_result_precessing(i,2:3)];%提取突变行为的序号
%         Type_mutation = [Type_mutation; E_trajectory(find((E_trajectory(:,1)==test_result_precessing(i,2))&(E_trajectory(:,2)==test_result_precessing(i,3))),14)];
%         [MDE_no_mutation] = [MDE_no_mutation ; ADE(trend_points(2:size(trend_points,1),4:5),output1_part(2:size(output1_part,1),:))];%计算平均距离误差  % [MDE_no] = [MDE_no ; ADE(trend_points(2:size(trend_points,1),:),output1(2:size(output1,1),:))];%计算平均距离误差
%         [FDE_no_mutation] = [FDE_no_mutation ; ADE(trend_points(size(trend_points,1),4:5),output1_part(size(output1_part,1),:))];%计算平均距离误差
%         [ILP_mutation] = [ILP_mutation; LIP_cal(trend_points(:,4:5),output1_part,0)];
% %         figure(2)
% %         clf
% %         scatter(trend_points(:,4),trend_points(:,5),50,'*','b')  %真实轨迹
% %         hold on
% %         scatter(output1_part(:,1),output1_part(:,2),50,'*','r')  %o v *   %预测轨迹
% %         pause(1)
%     end
%     lateral_displacement_Truth = (abs(max(trend_points(:,5))-min(trend_points(:,5))));%定义为横向偏移比较大的轨迹
%     [lateral_displacement_all] = [lateral_displacement_all; lateral_displacement_Truth];
%     if lateral_displacement_Truth>0.5
%         ID_lateral_displacement = [ID_lateral_displacement; test_result_precessing(i,2:3)];%提取横向偏移行为的序号
%         Type_lateral_displacement = [Type_lateral_displacement; E_trajectory(find((E_trajectory(:,1)==test_result_precessing(i,2))&(E_trajectory(:,2)==test_result_precessing(i,3))),14)];
%         [MDE_no_lateral] = [MDE_no_lateral ; ADE(trend_points(2:size(trend_points,1),4:5),output1_part(2:size(output1_part,1),:))];%计算平均距离误差  % [MDE_no] = [MDE_no ; ADE(trend_points(2:size(trend_points,1),:),output1(2:size(output1,1),:))];%计算平均距离误差
%         [FDE_no_lateral] = [FDE_no_lateral ; ADE(trend_points(size(trend_points,1),4:5),output1_part(size(output1_part,1),:))];%计算平均距离误差
%         [ILP_lateral] = [ILP_lateral; LIP_cal(trend_points(:,4:5),output1_part,0)];
% %         figure(3)
% %         clf
% %         scatter(trend_points(:,4),trend_points(:,5),50,'o','b')  %真实轨迹
% %         hold on
% %         scatter(output1_part(:,1),output1_part(:,2),50,'o','r')  %o v *   %预测轨迹
% %         pause(1)
%     end
% %     i=i+1
% end
%
% %计算车辆异质性的大曲率行为
% mean(MDE_no_mutation(Type_mutation==1))%2是计算电动车   1是计算人力车
% mean(FDE_no_mutation(Type_mutation==1))
% mean(ILP_mutation(Type_mutation==1))
%
% %计算总的大曲率行为
% mean(MDE_no_mutation)
% mean(FDE_no_mutation)
% mean(ILP_mutation)
% hist(curvature_Truth_all)
%
% %计算车辆异质性的横向偏移行为
% mean(MDE_no_lateral(Type_lateral_displacement==2))
% mean(FDE_no_lateral(Type_lateral_displacement==2))
% mean(ILP_lateral(Type_lateral_displacement==2))
%
% %计算总的横向偏移行为
% mean(MDE_no_lateral)
% mean(FDE_no_lateral)
% mean(ILP_lateral)
%
%
% %% 计算突变行为的准确性
%
%
%
% %% % % %删掉一些错误数据
% % dele_i = find(MDE_no(:,1)>1.5);
% dele_i = dele_j;
% MDE_no(dele_i,:) = [];
% ILP(dele_i,:) = [];
% FDE_no(dele_i,:) = [];
% % ang_dis_all(dele_i,:) = [];
% test_result_no(dele_i,:) = [];
% test_result_precessing(dele_i,:) = [];
% data_EXITFLAG(dele_i,:) = [];
% % %删除结束
% hist(MDE_no)
% toc
% mean(MDE_no)
% mean(FDE_no)
% mean(ILP)
%
% save('result双层模型(20210917_2)')
% disp('the job is done！!!')
% % 运行至这里
% % find((ang_dis_all<0.01))%找到机动车侧膨胀车流的特定误差的轨迹
% %% 分拣出机动车侧膨胀、非机动车道内部以及行人侧膨胀的数据
% ID_intruse_V = [];%存放机动车侧膨胀个体ID
% ID_intruse_P = [];%存放行人侧膨胀个体ID
% ID_in_NV = [];%存放非机动车内部个体ID
% for i =1:size(test_result_precessing,1)
%     index_ce = find(input(:,1)==test_result_precessing(i,2)&(input(:,2)==test_result_precessing(i,3)));
%     Truth_no = input(index_ce : index_ce + perception_time,:);%真实轨迹
%     dis_line = min(Truth_no(:,5))-22;
%     if dis_line<0
%         ID_intruse_V = [ID_intruse_V; i];
%     elseif (min(Truth_no(:,5))-22)>=0&&(max(Truth_no(:,5))-26)<=0
%         ID_in_NV = [ID_in_NV; i];
%     elseif (max(Truth_no(:,5))-26)>0
%         ID_intruse_P = [ID_intruse_P; i];
%     end
% end
% %% 按照入侵和返回分拣
% ID_intruse_V_in = [];%存放入侵
% ID_intruse_V_out = [];%存放返回
% for i = 1:size(ID_intruse_V,1)
%     if data_test((ID_intruse_V(i)*26-20),5)-data_test((ID_intruse_V(i)*26-5),5)>=0%找到对应的轨迹,若>=0，则说明是入侵
%         ID_intruse_V_in = [ID_intruse_V_in;ID_intruse_V(i)];
%     else
%         ID_intruse_V_out = [ID_intruse_V_out;ID_intruse_V(i)];
%     end
% end
% disp(['机动车侧入侵平均MLIP误差为',num2str(mean(ILP(ID_intruse_V_in,:)))])
% disp(['机动车侧返回平均MLIP误差为',num2str(mean(ILP(ID_intruse_V_out,:)))])
% % hist(ILP(ID_intruse_V_in,:))%机动车侧入侵MLIP的hist图
% % title('机动车侧入侵非机动车平均MLIP误差分布')
% % hist(ILP(ID_intruse_V_out,:))%机动车侧返回的MLIP的hist图
% % title('机动车侧返回非机动车平均MLIP误差分布')
%
% %%
% disp(['机动车侧平均MLIP误差为',num2str(mean(ILP(ID_intruse_V,:)))])
% disp(['行人侧平均MLIP误差为',num2str(mean(ILP(ID_intruse_P,:)))])
% disp(['非机动车内部平均MLIP误差为',num2str(mean(ILP(ID_in_NV,:)))])
% disp(['机动车侧准确性为',num2str(sum(accuracy_if_all(ID_intruse_V,:))/(size(accuracy_if_all(ID_intruse_V,:),1)))])%计算机动车侧突发行为的的模型预测准确性（通过左右横向误差确定）
% disp(['机动车侧入侵行为准确性为',num2str(sum(accuracy_if_all(ID_intruse_V_in,:))/(size(accuracy_if_all(ID_intruse_V_in,:),1)))])%   %ID_intruse_V_in
% disp(['机动车侧返回行为准确性为',num2str(sum(accuracy_if_all(ID_intruse_V_out,:))/(size(accuracy_if_all(ID_intruse_V_out,:),1)))])%   %ID_i
% hist(accuracy_all);%所有行为的误差
% title('突发行为事件误差分布')
% hist(accuracy_all(ID_intruse_V_in));%入侵行为的误差
% title('入侵行为事件误差分布')
% hist(accuracy_all(ID_intruse_V_out));%返回行为的误差
% title('返回行为事件误差分布')
%
%
% effet = ID_intruse_V(find((ILP(ID_intruse_V,:)<=0.4)&(ILP(ID_intruse_V,:)>0.0)),:)%找到机动车侧膨胀车流的特定误差的轨迹
% size(effet,1)/size(ILP(ID_intruse_V,:),1)%MLIP小于0.2的概率；
% hist(ILP(ID_intruse_V,:))%机动车侧的MLIP的hist图
% title('机动车侧自行车车平均MLIP误差分布')
%
% %% 按照车型异质性分拣
% ID_intruse_V_EB = [];%存放机动车侧的电动车编号
% ID_intruse_V_RB = [];%存放机动车侧的人力动车编号
%
% for i = 1:size(ID_intruse_V,1)
%     if data_test((ID_intruse_V(i)*26-5),14)==2%找到对应的轨迹的轨迹点,若==2，则为电动车
%         ID_intruse_V_EB = [ID_intruse_V_EB;ID_intruse_V(i)];
%     else
%         ID_intruse_V_RB = [ID_intruse_V_RB;ID_intruse_V(i)];
%     end
% end
% disp(['机动车侧电动车行为准确性为',num2str(sum(accuracy_if_all(ID_intruse_V_EB,:))/(size(accuracy_if_all(ID_intruse_V_EB,:),1)))])%   %可靠性  电动车
% disp(['机动车侧人力车行为准确性为',num2str(sum(accuracy_if_all(ID_intruse_V_RB,:))/(size(accuracy_if_all(ID_intruse_V_RB,:),1)))])%   %可靠性  人力自行车
% hist(accuracy_all(ID_intruse_V_EB));%电动车的误差
% title('电动车突发行为事件误差分布')
% hist(accuracy_all(ID_intruse_V_RB));%人力车的误差
% title('人力车突发行为事件误差分布')
% %%
% disp(['机动车侧电动车平均MLIP误差为',num2str(mean(ILP(ID_intruse_V_EB,:)))])
% disp(['机动车侧人力自行车平均MLIP误差为',num2str(mean(ILP(ID_intruse_V_RB,:)))])
% hist(ILP(ID_intruse_V_EB,:))%机动车侧电动车的MLIP的hist图
% title('机动车侧电动自行车平均MLIP误差分布')
% hist(ILP(ID_intruse_V_RB,:))%机动车侧人力自行车的MLIP的hist图
% title('机动车侧常规自行车车平均MLIP误差分布')
%
% size(ILP(ID_in_NV,:))
% % nu_e = 0;%电动车数量
% % nu_h = 0;%人力自行车数量
% % for i = 1:size(ID_intruse_V,1)
% %     if data_test(i*26+2,14)==2%电动车
% %         nu_e = nu_e+1;
% %     elseif data_test(i*26+2,14)==1%人力自行车
% %         nu_h = nu_h+1;
% %     end
% % end
%
%
%
% %
% %% % %找到没有可行解的，看是否存在明显误差增大情况
% % un_MDE_no = [];
% % un_FDE_no = [];
% % un_ILP = [];
% % yes_MDE_no = [];
% % yes_FDE_no = [];
% % yes_ILP = [];
% % for i = 1:size(data_EXITFLAG,1)
% %     if data_EXITFLAG(i)==-2
% %         un_MDE_no = [un_MDE_no;MDE_no(i)];
% %         un_FDE_no = [un_FDE_no;FDE_no(i)];
% %         un_ILP = [un_ILP;ILP(i)];
% %     else
% %         yes_MDE_no = [yes_MDE_no;MDE_no(i)];
% %         yes_FDE_no = [yes_FDE_no;FDE_no(i)];
% %         yes_ILP = [yes_ILP;ILP(i)];
% %     end
% % end
% % disp(['最优解和非可行解的平均距离误差为',num2str(mean(yes_MDE_no)),'和',num2str(mean(un_MDE_no))]);
% % disp(['最优解和非可行解的平均ILP为',num2str(mean(yes_ILP)),'和',num2str(mean(un_ILP))]);
% % disp(['最优解和非可行解的平均距离误差为',num2str(mean(yes_FDE_no)),'和',num2str(mean(un_FDE_no))]);
% % % %查看结束
% % ILP(find(isnan(ILP)),:)=[];
% %% 保存
% save('result取消异质性骑行需求最终使用数据(20210719_1)')
% disp('the job is done！!!')
% disp(['平均距离误差为',num2str(mean(MDE_no))])
% disp(['MLIP值为',num2str(mean(ILP))])
% disp(['最终距离误差为',num2str(mean(FDE_no))])
% MDE_sort = sort(MDE_no);
% % hist(ILP)
% % hist(MDE_no)
% %% 找到偏移比较大的
% ID_abrupt = [];
% dis_abrupt = [];
% % test_result_no
% for i = 1:size(test_result_no,1)
%     ID_intr = find((E_trajectory(:,1)==test_result_no(i,2))&(E_trajectory(:,2)==test_result_no(i,3)));
%     drow = E_trajectory(ID_intr:ID_intr+20,:);
%     V_zeros = ((sum(sign(drow(:,7))>0))/size(drow,1));%左右横向速度的占比
%     dis_S_E = abs(max(drow(:,5))-min(drow(:,5)));
%     dis_abrupt = [dis_abrupt;dis_S_E];
%     if dis_S_E>2  %V_zeros >0.4&&V_zeros <0.6&&dis_S_E>2
%         ID_abrupt = [ID_abrupt ; i];
%     end
% end
% hist(dis_abrupt)
%
% MDE_no_abrupt = (MDE_no(ID_abrupt,:));%MDE_no_abrupt(12,:)=[];
% FDE_no_abrupt = (FDE_no(ID_abrupt,:));%FDE_no_abrupt(12,:)=[];
% ILP_abrupt = (ILP(ID_abrupt,:));%ILP_abrupt(12,:) = [];
% mean(MDE_no_abrupt)
% mean(FDE_no_abrupt)
% mean(ILP_abrupt)