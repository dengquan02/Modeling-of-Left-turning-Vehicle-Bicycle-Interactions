
%index_test是Parameter_calibration函数里的东西
%计算每个轨迹点的入侵概率(非入侵行为轨迹)
% drow = E_trajectory(find(E_trajectory(:,1)==681),:);
% scatter(drow(:,4),drow(:,5),'r','*')
% drow = sort(MDE_no);
% global data_test
% courr =[];%记录突发行为的平均曲率
% for i = 1:26: size(data_test)
% %     scatter(data_test(i:i+25,4),data_test(i:i+25,5),'*','r');
% %     pause(1);
%     courr = [courr; max(abs(data_test(i:i+25,13)))];%平均曲率
% end
% hist(courr,100);

%% 开始计算，先赋值
tic
test_result_no = [];%记录计算结果
data_EXITFLAG = [];%记录GA的退出条件

%% 读取测试数据
%   数据采用全部数据
 input = E_trajectory;

%数据采用测试数据
% global data_test
% input = data_test;%数据采用测试突发行为数据

%数据采用深度学习测试数据
sample_ID = [];
for i = 1 : 17: size(sample_test,1)
    sample_ID = [sample_ID; sample_test(i,1:3)];
end


%% 从这里开始
% input = Truth_no;%输入采用选中的一条轨迹；

%数据采用全部突发数据
%   global data_cal
%   input = data_cal;%数据采用测试突发行为数据
  
%input = trajectory_block;%数据采用全部数据
% index_all = randperm(input(size(input,1),1),round(input(size(input,1),1)*0.3));%从总样本随机选出30%的轨迹来进行计算
% index_test = 1:(size(data_test,1)/perception_time);%测试突发行为数据的序号
Parameter_cal = csvread('Parameter_cal_store.csv');%从已保存内容中读取基准信息

for ID = 1:size(sample_ID,1)%计算每条轨迹   %for ID = 1:size(index_test,2)%计算每条轨迹    for ID = 1:(perception_time+1):size(input,1)%计算每条轨迹 
    index = sample_ID(ID,2);%轨迹ID
    output = [];
%     extract_trajectory = input((input(:,1)==index),:);%提取轨迹编号为index的轨
%     extract_trajectory = input(ID:ID+perception_time,:);
    index_in = sample_ID(ID,3); %randperm(extract_trajectory(size(extract_trajectory,1),2)-perception_time-1,1);%随机选出轨迹的一个时刻来进行预测  
   %%% 提取测试样本
%    index = 196;
%    index_in = 1;
   extract_trajectory = input((input(:,1) == index),:);%提取轨迹编号为index的轨
   if index_in+perception_time > size(extract_trajectory,1)
       continue
   end
   extract_trajectory = extract_trajectory(index_in:index_in+perception_time-1,:);%提取预测轨迹
   
   %% 开始计算
    global extract_one
    extract_one = extract_trajectory(1,:);%每帧数据
    try
       tic
       global Parameter
%        Parameter = Parameter_cal;%标定的参数
      Parameter = [1 0.8 1 5 0.2 0.12 1 5 0.2 0.03];%手动填的参数(10个)  Parameter = [1 0.8 1 5 0.2 0.12 1 5 0.2 0.03];%计算的时候填的参数（202107022）
       MyGA;%用遗传算法求解
%        MyGa_Moeth3;%方法3求解
        data_EXITFLAG =[data_EXITFLAG;EXITFLAG  ];%-2表示未找到可行点
       toc
    catch
          continue
    end
%     test_result_precessing = [[floor(ID/(perception_time+1)) index index_in OPT]];
    test_result_no = [test_result_no;[floor(ID/(perception_time+1)) index index_in OPT]];%index是轨迹编号；index_in是轨迹内预测点的编号； OPT是优化后的加速度集合 
    disp(['已完成',num2str(ID/size(sample_ID,1)*100),'%'])
end
toc

%% 
% ID_check = find(test_result_no(:,2)==497)%&test_result_no(:,3)==40)
tic
MDE_no = [];%记录平均距离误差
ILP = [];
FDE_no = [];%存放最终误差
dele_j = [];
ang_dis_all = [];%存放最大曲率差,越大越好
accuracy_if_all = [];%存放准确性
accuracy_all = [];%存放误差
test_result_precessing = test_result_no;

for i =1:size(test_result_precessing,1)
    index_ce = find(input(:,1)==test_result_precessing(i,2)&(input(:,2)==test_result_precessing(i,3)));
    Truth_no = input(index_ce : index_ce + perception_time-1,:);%真实轨迹 
%     % 以下是转化形式，将真实轨迹带进去计算
%     output_compare = [];
%     for jj = 1:4
%         if jj==1 %预测值
%              [inter_extract,output,output1,output2] = Excur_predict_2(test_result_precessing(i,4:size(test_result_precessing,2)),Truth_no(1,:),Truth_no,perception_time,generating_lengh);%%output是目标值，output1是输出的预测点；output2是输出的风险值；
%             output_compare = [output_compare;output];
%         else
%         if jj==2
%         rand_acc = Truth_no(2:size(Truth_no,1),8:9);%真实值在第二个
%         elseif jj == 3
%         rand_acc = rand_acc_1;%下面的轨迹
%         elseif jj==4
%             rand_acc = rand_acc_2;%上面面的轨迹
%         end
%         [truth_input_pol_1,truth_input_pol_2] = cart2pol(rand_acc(:,1),rand_acc(:,2));
%          truth_input =  reshape([truth_input_pol_1 truth_input_pol_2],1,[]);%变换一下形式将真实轨迹带进去算
%         [inter_extract,output,output1,output2] = Excur_predict_2(truth_input,Truth_no(1,:),Truth_no,perception_time,generating_lengh);%%output是目标值，output1是输出的预测点；output2是输出的风险值；
%         hold on
%         scatter(output1(:,1),output1(:,2),'r','*');
%         output_compare = [output_compare;output];
%         end
%     end
%     [const,const2] = nonlcon(truth_input)
%      
     % 计算结束
      [inter_extract,output,output1,output2] = Excur_predict_2(test_result_precessing(i,4:size(test_result_precessing,2)),Truth_no(1,:),Truth_no,perception_time,generating_lengh);%%output是目标值，output1是输出的预测点；output2是输出的风险值；
%     [ILP_single] = LIP_cal(Truth_no(:,4:5),output1,0);
%     [ang_dis] = Curvature_dis(Truth_no(:,4:5),output1);%新的行为趋势计算方法（未完成）·
%     [accuracy_if,accuracy] = cross_dis(Truth_no(:,4:5),output1);%针对机动车侧的计算横向偏移是否预测准确，标准是超过1.5以内且在0.5以内
%       interAll = Truth_no;
%       interAll(:,1:14) = [];%去掉无用项和交互对象
%       
%       hold on
%     figure(2)
%     clf
%     for j =1:perception_time
%         inter_one = reshape(interAll(j,:)',11,[])';
%         inter_one(all(inter_one==0,2),:)=[];
%         scatter(Truth_no(:,4),Truth_no(:,5),50,'+','b')  %真实轨迹
%         hold on
%         scatter(output1(:,1),output1(:,2),50,'*','r')  %o v *   %预测轨迹
%         hold on
%         scatter(inter_one(:,1),inter_one(:,2),ones(size(inter_one,1),1)*50,50,'*','b')  %o v *   %交互轨迹
%         pause(0.5)
%     i = i+ 1;
%     end
%     set(gcf,'color','none')
%     set(gca,'color','none')
%     axis([-50 -20 15 25]);
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
    for h = 1:perception_time-1
        dis_head = [dis_head;(Truth_no(h,4)-Truth_no(h+1,4))];
    end
    if sum(sign(dis_head))~=perception_time-1
       dele_j = [dele_j i];
    end
    trend_points = [Truth_no(1,:);Truth_no(9,:);Truth_no(17,:);Truth_no(25,:)];%未   trend_points = [Truth_no(9,4:5);Truth_no(17,4:5);Truth_no(25,4:5);Truth_no(size(Truth_no,1),4:5)];%未包括已知点
    output1_part = [output1(1,:);output1(9,:);output1(17,:);output1(25,:)];%未
    [MDE_no] = [MDE_no ; ADE(trend_points(2:size(trend_points,1),4:5),output1_part(2:size(output1_part,1),:))];%计算平均距离误差  % [MDE_no] = [MDE_no ; ADE(trend_points(2:size(trend_points,1),:),output1(2:size(output1,1),:))];%计算平均距离误差     
    [FDE_no] = [FDE_no ; ADE(trend_points(size(trend_points,1),4:5),output1_part(size(output1_part,1),:))];%计算平均距离误差   
        [ILP_single] = LIP_cal(trend_points(:,4:5),output1_part,0);   % [ILP_single] = LIP_cal(trend_points,output1,0);
    ILP = [ILP;ILP_single];
%     ang_dis_all = [ang_dis_all;ang_dis];
%     accuracy_if_all = [accuracy_if_all;accuracy_if];
%     accuracy_all = [accuracy_all;accuracy];
end
mean(MDE_no)
mean(FDE_no)
mean(ILP)
%% % % %删掉一些错误数据
% dele_i = find(MDE_no(:,1)>1.5);
dele_i = dele_j;
MDE_no(dele_i,:) = [];
% ILP(dele_i,:) = [];
FDE_no(dele_i,:) = [];
% ang_dis_all(dele_i,:) = [];
test_result_no(dele_i,:) = [];
test_result_precessing(dele_i,:) = [];
data_EXITFLAG(dele_i,:) = [];
% %删除结束
hist(MDE_no)
toc
mean(MDE_no)
mean(FDE_no)
mean(ILP)

save('result基于3点生成完整轨迹趋势计算(20210907_1)')
disp('the job is done！!!')
运行至这里
% find((ang_dis_all<0.01))%找到机动车侧膨胀车流的特定误差的轨迹
%% 分拣出机动车侧膨胀、非机动车道内部以及行人侧膨胀的数据
ID_intruse_V = [];%存放机动车侧膨胀个体ID
ID_intruse_P = [];%存放行人侧膨胀个体ID
ID_in_NV = [];%存放非机动车内部个体ID
for i =1:size(test_result_precessing,1)
    index_ce = find(input(:,1)==test_result_precessing(i,2)&(input(:,2)==test_result_precessing(i,3)));
    Truth_no = input(index_ce : index_ce + perception_time,:);%真实轨迹
    dis_line = min(Truth_no(:,5))-22;
    if dis_line<0
        ID_intruse_V = [ID_intruse_V; i];
    elseif (min(Truth_no(:,5))-22)>=0&&(max(Truth_no(:,5))-26)<=0
        ID_in_NV = [ID_in_NV; i];
    elseif (max(Truth_no(:,5))-26)>0
        ID_intruse_P = [ID_intruse_P; i];
    end
end
%% 按照入侵和返回分拣
ID_intruse_V_in = [];%存放入侵
ID_intruse_V_out = [];%存放返回
for i = 1:size(ID_intruse_V,1)
    if data_test((ID_intruse_V(i)*26-20),5)-data_test((ID_intruse_V(i)*26-5),5)>=0%找到对应的轨迹,若>=0，则说明是入侵
        ID_intruse_V_in = [ID_intruse_V_in;ID_intruse_V(i)];
    else
        ID_intruse_V_out = [ID_intruse_V_out;ID_intruse_V(i)];
    end
end
disp(['机动车侧入侵平均MLIP误差为',num2str(mean(ILP(ID_intruse_V_in,:)))])
disp(['机动车侧返回平均MLIP误差为',num2str(mean(ILP(ID_intruse_V_out,:)))])
% hist(ILP(ID_intruse_V_in,:))%机动车侧入侵MLIP的hist图  
% title('机动车侧入侵非机动车平均MLIP误差分布')
% hist(ILP(ID_intruse_V_out,:))%机动车侧返回的MLIP的hist图
% title('机动车侧返回非机动车平均MLIP误差分布')

%%
disp(['机动车侧平均MLIP误差为',num2str(mean(ILP(ID_intruse_V,:)))])
disp(['行人侧平均MLIP误差为',num2str(mean(ILP(ID_intruse_P,:)))])
disp(['非机动车内部平均MLIP误差为',num2str(mean(ILP(ID_in_NV,:)))])
disp(['机动车侧准确性为',num2str(sum(accuracy_if_all(ID_intruse_V,:))/(size(accuracy_if_all(ID_intruse_V,:),1)))])%计算机动车侧突发行为的的模型预测准确性（通过左右横向误差确定）
disp(['机动车侧入侵行为准确性为',num2str(sum(accuracy_if_all(ID_intruse_V_in,:))/(size(accuracy_if_all(ID_intruse_V_in,:),1)))])%   %ID_intruse_V_in
disp(['机动车侧返回行为准确性为',num2str(sum(accuracy_if_all(ID_intruse_V_out,:))/(size(accuracy_if_all(ID_intruse_V_out,:),1)))])%   %ID_i
hist(accuracy_all);%所有行为的误差
title('突发行为事件误差分布')
hist(accuracy_all(ID_intruse_V_in));%入侵行为的误差
title('入侵行为事件误差分布')
hist(accuracy_all(ID_intruse_V_out));%返回行为的误差
title('返回行为事件误差分布')


effet = ID_intruse_V(find((ILP(ID_intruse_V,:)<=0.4)&(ILP(ID_intruse_V,:)>0.0)),:)%找到机动车侧膨胀车流的特定误差的轨迹
size(effet,1)/size(ILP(ID_intruse_V,:),1)%MLIP小于0.2的概率；
hist(ILP(ID_intruse_V,:))%机动车侧的MLIP的hist图
title('机动车侧自行车车平均MLIP误差分布')

%% 按照车型异质性分拣
ID_intruse_V_EB = [];%存放机动车侧的电动车编号
ID_intruse_V_RB = [];%存放机动车侧的人力动车编号

for i = 1:size(ID_intruse_V,1)
    if data_test((ID_intruse_V(i)*26-5),14)==2%找到对应的轨迹的轨迹点,若==2，则为电动车
        ID_intruse_V_EB = [ID_intruse_V_EB;ID_intruse_V(i)];
    else
        ID_intruse_V_RB = [ID_intruse_V_RB;ID_intruse_V(i)];
    end
end
disp(['机动车侧电动车行为准确性为',num2str(sum(accuracy_if_all(ID_intruse_V_EB,:))/(size(accuracy_if_all(ID_intruse_V_EB,:),1)))])%   %可靠性  电动车
disp(['机动车侧人力车行为准确性为',num2str(sum(accuracy_if_all(ID_intruse_V_RB,:))/(size(accuracy_if_all(ID_intruse_V_RB,:),1)))])%   %可靠性  人力自行车
hist(accuracy_all(ID_intruse_V_EB));%电动车的误差
title('电动车突发行为事件误差分布')
hist(accuracy_all(ID_intruse_V_RB));%人力车的误差
title('人力车突发行为事件误差分布')
%%
disp(['机动车侧电动车平均MLIP误差为',num2str(mean(ILP(ID_intruse_V_EB,:)))])
disp(['机动车侧人力自行车平均MLIP误差为',num2str(mean(ILP(ID_intruse_V_RB,:)))])
hist(ILP(ID_intruse_V_EB,:))%机动车侧电动车的MLIP的hist图  
title('机动车侧电动自行车平均MLIP误差分布')
hist(ILP(ID_intruse_V_RB,:))%机动车侧人力自行车的MLIP的hist图
title('机动车侧常规自行车车平均MLIP误差分布')

size(ILP(ID_in_NV,:))
% nu_e = 0;%电动车数量
% nu_h = 0;%人力自行车数量
% for i = 1:size(ID_intruse_V,1)
%     if data_test(i*26+2,14)==2%电动车
%         nu_e = nu_e+1;
%     elseif data_test(i*26+2,14)==1%人力自行车
%         nu_h = nu_h+1;
%     end
% end
        
        

% 
%% % %找到没有可行解的，看是否存在明显误差增大情况
% un_MDE_no = [];
% un_FDE_no = [];
% un_ILP = [];
% yes_MDE_no = [];
% yes_FDE_no = [];
% yes_ILP = [];
% for i = 1:size(data_EXITFLAG,1)
%     if data_EXITFLAG(i)==-2
%         un_MDE_no = [un_MDE_no;MDE_no(i)];
%         un_FDE_no = [un_FDE_no;FDE_no(i)];
%         un_ILP = [un_ILP;ILP(i)];
%     else
%         yes_MDE_no = [yes_MDE_no;MDE_no(i)];
%         yes_FDE_no = [yes_FDE_no;FDE_no(i)];
%         yes_ILP = [yes_ILP;ILP(i)];
%     end
% end
% disp(['最优解和非可行解的平均距离误差为',num2str(mean(yes_MDE_no)),'和',num2str(mean(un_MDE_no))]);
% disp(['最优解和非可行解的平均ILP为',num2str(mean(yes_ILP)),'和',num2str(mean(un_ILP))]);
% disp(['最优解和非可行解的平均距离误差为',num2str(mean(yes_FDE_no)),'和',num2str(mean(un_FDE_no))]);
% % %查看结束
% ILP(find(isnan(ILP)),:)=[];
%% 保存
save('result取消异质性骑行需求最终使用数据(20210719_1)')
disp('the job is done！!!')
disp(['平均距离误差为',num2str(mean(MDE_no))])
disp(['MLIP值为',num2str(mean(ILP))])
disp(['最终距离误差为',num2str(mean(FDE_no))])
MDE_sort = sort(MDE_no);
% hist(ILP)
% hist(MDE_no)
%% 找到偏移比较大的
ID_abrupt = [];
dis_abrupt = [];
% test_result_no
for i = 1:size(test_result_no,1)
    ID_intr = find((E_trajectory(:,1)==test_result_no(i,2))&(E_trajectory(:,2)==test_result_no(i,3)));
    drow = E_trajectory(ID_intr:ID_intr+20,:);
    V_zeros = ((sum(sign(drow(:,7))>0))/size(drow,1));%左右横向速度的占比
    dis_S_E = abs(max(drow(:,5))-min(drow(:,5)));
    dis_abrupt = [dis_abrupt;dis_S_E];
    if dis_S_E>2  %V_zeros >0.4&&V_zeros <0.6&&dis_S_E>2
        ID_abrupt = [ID_abrupt ; i];
    end
end
hist(dis_abrupt)

MDE_no_abrupt = (MDE_no(ID_abrupt,:));%MDE_no_abrupt(12,:)=[];
FDE_no_abrupt = (FDE_no(ID_abrupt,:));%FDE_no_abrupt(12,:)=[];
ILP_abrupt = (ILP(ID_abrupt,:));%ILP_abrupt(12,:) = [];
mean(MDE_no_abrupt)
mean(FDE_no_abrupt)
mean(ILP_abrupt)
% hist(FDE_no_abrupt)
%% 计算了一下socai-lstm的误差
OUTPUT_socai_LSTM = csvread('output_social_LSTM.csv');
%以上计算完之后，下面开始计算其误差
social_LSTM_ILP = [];%记录ILP值
social_LSTM_MDE = [];%记录平均距离误差
social_LSTM_FDE = [];%记录平均距离误差
for i=1:40:3880
    [ILP_single_social_LSTM] = LIP_cal([OUTPUT_socai_LSTM(i,5:6) ; OUTPUT_socai_LSTM(i+1:i+20,3:4)],OUTPUT_socai_LSTM(i:i+20,5:6),0);
    MDE_single_social_LSTM = ADE([OUTPUT_socai_LSTM(i,5:6) ; OUTPUT_socai_LSTM(i+1:i+20,3:4)],OUTPUT_socai_LSTM(i:i+20,5:6));
    FDE_single_social_LSTM = ADE( OUTPUT_socai_LSTM(i,3:4),OUTPUT_socai_LSTM(i,5:6));
    social_LSTM_ILP = [social_LSTM_ILP ; ILP_single_social_LSTM];
    social_LSTM_MDE = [social_LSTM_MDE; MDE_single_social_LSTM ];%记录平均距离误差
    social_LSTM_FDE = [social_LSTM_FDE; FDE_single_social_LSTM ];%记录最终距离误差
end
mean(social_LSTM_ILP)
mean(social_LSTM_MDE)
mean(social_LSTM_FDE)
% 上面的错误
% scatter(OUTPUT_socai_LSTM(i:i+20,3),OUTPUT_socai_LSTM(i:i+20,4))
%% 计算了一下Conv-lstm的误差
predictiton_Conv_LSTM = csvread('Conv_LSTM_prediction.csv');
truth_Conv_LSTM = csvread('Conv_LSTM_trutn.csv');
%以下开始数据格式处理并计算误差值
Conv_LSTM_ILP = [];%记录ILP值
Conv_LSTM_MDE = [];%记录平均距离误差
Conv_LSTM_FDE = [];%记录最终距离误差
for i = 1: size(predictiton_Conv_LSTM,1)
    pre_Conv_LSTM_sigle = reshape(predictiton_Conv_LSTM(i,:),9,[])';%换成9列的
    tru_Conv_LSTM_sigle = reshape(truth_Conv_LSTM(i,:),9,[])';%换成9列的
    [ILP_single_Conv_LSTM] = LIP_cal(pre_Conv_LSTM_sigle(20:41,1:2),tru_Conv_LSTM_sigle(20:41,1:2),0);
    MDE_single_Conv_LSTM = ADE(pre_Conv_LSTM_sigle(20:41,1:2),tru_Conv_LSTM_sigle(20:41,1:2));
    FDE_single_Conv_LSTM = ADE(pre_Conv_LSTM_sigle(41,1:2),tru_Conv_LSTM_sigle(41,1:2));%计算最终距离误差
    Conv_LSTM_ILP = [Conv_LSTM_ILP ; ILP_single_Conv_LSTM];%记录ILP值
    Conv_LSTM_MDE = [Conv_LSTM_MDE; MDE_single_Conv_LSTM ];%记录平均距离误差
    Conv_LSTM_FDE = [Conv_LSTM_FDE; FDE_single_Conv_LSTM ];%记录平均距离误差
end
mean(Conv_LSTM_ILP)
mean(Conv_LSTM_MDE)
mean(Conv_LSTM_FDE)