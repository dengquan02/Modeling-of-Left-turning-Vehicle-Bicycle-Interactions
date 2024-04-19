function [Parameter_cal,FVAL,EXITFLAG,OUTPUT] = Parameter_calibration(E_trajectory)
%% 重新计算一下各点的曲率
E_trajectory_reCur = E_trajectory;
Cur = [];
for i =1:E_trajectory(size(E_trajectory,1),1)%共680个轨迹
    [reCur] = Curvature_calculation(E_trajectory(find(E_trajectory(:,1)==i),4),E_trajectory(find(E_trajectory(:,1)==i),5));  %输入轨迹的x和y，计算每个点的曲率
    figure(1)
    bar(reCur)
    figure(2)
     scatter(E_trajectory(find(E_trajectory(:,1)==i),4),E_trajectory(find(E_trajectory(:,1)==i),5),'*','r');
    reCur = E_trajectory_reCur(find(E_trajectory(:,1)==i),13) ;
    Cur = [Cur;mean(reCur)];%记录下每个轨迹的平均曲率
end
Cur(find(abs(Cur)>0.2),:) = [];%去掉曲率大于0.2的非正常数据；
hist(Cur,100);

%% 计算突发行为测试数据的平均曲率
global data_test
Cur_intruse = [];
for i =1:(1+perception_time):size(data_test,1)%每26个为一组
%     [reCur] = Curvature_calculation(E_trajectory(find(E_trajectory(:,1)==i),4),E_trajectory(find(E_trajectory(:,1)==i),5));  %输入轨迹的x和y，计算每个点的曲率
%     figure(1)
%     bar(reCur)
%     figure(2)
%      scatter(E_trajectory(find(E_trajectory(:,1)==i),4),E_trajectory(find(E_trajectory(:,1)==i),5),'*','r');
    reCur_intruse = data_test(i:(i+perception_time),13) ;
    Cur_intruse = [Cur_intruse;mean(reCur_intruse)];%记录下每个轨迹的平均曲率
end
min(abs(Cur_intruse))%突发行为的最小平均曲率  大概0.0044左右；
size(Cur(find(abs(Cur)>0.0044),:),1)/size(Cur,1)%查看大于0.002的平均曲率在总数据中的百分比  大概曲率前1/3左右；
%% 找到偏移比较大的作为训练和预测对象
dis_abrupt = [];
perception_time = 25;  %Excur_predict_1,Excur_predict_2中都有
% global data_test
% input_abrupt = data_test;%拿测试轨迹，捡出突发行为

input_abrupt = E_trajectory_reCur;%拿全部轨迹，捡出突发行为
data_wash = [];%存放突变行为数据
% test_result_no
index_i = 1;
area_line_all = [];
for i = 1:input_abrupt(size(input_abrupt,1),1)
    drow = input_abrupt(find((input_abrupt(:,1)==i)),:);%提取出当前完整轨迹（轨迹顺序→轨迹点顺序）
    j = 1;
    while j <size(drow,1)-perception_time
        drow_1 = drow(j:j+perception_time,:);%提取出当前判断对象轨迹
        %下面是通过计算左右横向速度的占比和偏移程度进行提取突发行为
%         V_zeros = ((sum(sign(drow_1(:,7))>0))/size(drow_1,1));%左右横向速度的占比
%         dis_S_E = abs(max(drow_1(:,5))-min(drow_1(:,5)));%计算偏移程度
%         dis_abrupt = [dis_abrupt;dis_S_E];
%         dis_head = [];
%         for h = 1:perception_time
%             dis_head = [dis_head;(drow_1(h,4)-drow_1(h+1,4))];
%         end
        %以上是通过计算左右横向速度的占比和偏移程度进行提取突发行为
        
        %以下是通过计算轨迹点围成的面积的大小进行提取突发行为
%         area_line =  polyarea(drow_1(:,4),drow_1(:,5))/(max(drow_1(:,4))-min(drow_1(:,4)));
        %以上是通过计算轨迹点围成的面积的大小进行提取突发行为
        
        %以下是通过曲率计算提取突发行为
        curvat = max(drow_1(:,13));%计算平均曲率
        area_line = curvat;%将曲率计算结果赋予area_line
        %以上是曲率计算结束
        

        %以下挑拣出错误数据；
        dis_x = [];
        dis_y = [];
        for h = 1:perception_time
            dis_x = [dis_x;(drow_1(h,4)-drow_1(h+1,4))];
            dis_y = [dis_y;(drow_1(h,5)-drow_1(h+1,5))];
        end
        if sum(sign(dis_x))==perception_time&&sum(sign(dis_y))==perception_time
            error = 1;%若是正确数据
        else
            error = 0;%若是错误数据
        end
        if error == 1%若是正确数据
            area_line_all = [area_line_all;area_line];
        end
        if area_line>0.2&&error==1           %dis_S_E>2&&sum(sign(dis_head))==perception_time  %V_zeros >0.4&&V_zeros <0.6&&dis_S_E>2
            data_wash = [data_wash ; drow_1];
%             scatter(drow_1(:,4),drow_1(:,5),'*','r');
%             title(['轨迹ID为',num2str(drow_1(1,1)),'轨迹点数为',num2str(drow_1(1,2))]);
%             pause(0.5)
            j = j+perception_time;%若是突变行为，则后面perception_time个数据点排除掉
            index_i = index_i+1;
        else
            j = j+1;
        end
    end
end
% hist(input_abrupt(:,13),100) %所有曲率
% hist(area_line_all,100) %所有最大曲率
size(data_wash,1)/(perception_time+1)%显示提取出的数据数量

%下面是直接拿测试轨迹中的突发行为去做测试①
global data_test
data_test = data_wash;%reshape(data_wash',size(drow_1,2)*21,[])';
做到这里了，相当于弄出了测试数据；

%下面是要分开训练和测试样本②
% % data_test = data_cal;%全部突发行为数据赋予测试集
% data_wash = reshape(data_wash',size(drow_1,2)*21,[])';
% n_id = randperm(size(data_wash,1));
% data_wash_1 = [];
% data_wash_2 = [];
% for i = 1:round(size(data_wash,1)*0.6)%拿出60%来训练，剩下的去测试
%     data_wash_1 = [data_wash_1;data_wash(n_id(i),:)];
% end
% for i = round(size(data_wash,1)*0.6):size(data_wash,1)%拿出60%来训练，剩下的去测试
%     data_wash_2 = [data_wash_2;data_wash(n_id(i),:)];
% end
% global data_cal
% data_cal = reshape(data_wash_1',size(drow_1,2),[])';
% global data_test
% data_test = reshape(data_wash_2',size(drow_1,2),[])';
figure(2)
scatter(data_cal(:,4),data_cal(:,5),'r','.');
hold on
figure(1)
scatter(data_wash(:,4),data_wash(:,5),'b','.');
以上运行有问题
%% 标定数据和验证数据处理，全部数据随机取样
input_trajectory = E_trajectory;%使用全部数据计算
%input_trajectory = trajectory_block;%使用入侵数据计算
%首先数据预处理；
% index_cal = 88;%假设只用一条轨迹去标定，再检查这一条轨迹的拟合度，就知道标定方法行不行了
% index_test = 104;%测试集也用这条轨迹

% 划分标定数据和验证数据
index_cal = randperm(input_trajectory(size(input_trajectory,1),1),round(input_trajectory(size(input_trajectory,1),1)*1));%随机取0.6的数据ID
index_test = 1:input_trajectory(size(input_trajectory,1),1);%剩下的是测试集
for i = 1:size(index_cal,2)
    index_test(:,index_test(1,:)==index_cal(i)) = [];
end
global data_cal%分构建出训练数据轨迹
data_cal = [];
for i = 1:size(index_cal,2) 
    data_cal = [data_cal;input_trajectory(find(input_trajectory(:,1)==index_cal(i)),:)];%标定的数据
end
global data_test%分构建出测试数据轨迹
data_test = [];
for i = 1:size(index_test,2) 
    data_test = [data_test;input_trajectory(find(input_trajectory(:,1)==index_test(i)),:)];%测试的数据
end
先假设全部拿去当样本，算一下每个循环需要多长时间，再看样本的问题    

%%
%利用GA工具箱对参数进行标定

options = gaoptimset('PopInitRange',[;0,1;0,1],'PopulationSize',50, 'Generations', 500,'CrossoverFraction',0.8,'MigrationFraction',0.02','Display','iter'); % 遗传算法相关配置
tic
%上下界
lb = [0.001;0.001;0.001;0.001;0.001;0.001;0.001;0.001;0.001;0.001];%小于;%大于0
ub = [10;10;10;10;10;10;10;10;10;10];%小于约束  [1;2;1;5;5;5];%小于约束
[Parameter_cal,FVAL,EXITFLAG,OUTPUT] =ga(@Myfitting,10,[],[],[],[],lb,ub,[],options);%利用遗传算法进行参数标定
% [best_fitness, elite, generation, last_generation] = my_ga(9,@fitting,100,20,0.01,200,0);
toc

% csvwrite('Parameter_cal_store.csv',Parameter_cal);%读取基准信息
save('result(0224仙霞路100%训练数据全部采样标定caliration)')
disp('the job is done')
end

% [all_output] = Myfitting(X)