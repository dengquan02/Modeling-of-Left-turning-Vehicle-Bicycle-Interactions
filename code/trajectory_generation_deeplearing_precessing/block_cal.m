%计算每个轨迹点的入侵概率（入侵行为轨迹）
tic
test_result_block = [];%记录计算结果
input = trajectory_block;%先计算入侵行为的
index_all = randperm(trajectory_block(size(trajectory_block,1),1),33);%从总样本随机选出30%的轨迹来进行计算
for ID = 1:size(index_all,2)%计算每条轨迹
    index = index_all(ID);%轨迹编号
    output = [];
    Nu_point = 1;%仅仅是为了计数
    DIS = [];
    result_point = [];
    buxing = 0;
    Plo = [];
    lo = [];
        extract_trajectory = input((input(:,1)==index),:);%提取轨迹编号为index的轨迹
      % 做图
%       hold on
%       drow_point = extract_trajectory;
%       for i = 4:11:size(drow_point)
%           scatter(drow_point(:,i),drow_point(:,i+1),'*','r');
%       end  
        index_in = randperm(extract_trajectory(size(extract_trajectory,1),2)-perception_time-1,1);%随机选出轨迹的一个时刻来进行预测
%         while index_in <=size(extract_trajectory,1)-1%提取每个轨迹点，即每帧
            global extract_one
            extract_one = extract_trajectory(index_in,:);%每帧数据
%           next_point =  [(extract_one(1,6)*0.12),(extract_one(1,7)*0.12)];%找到下一个恒速度的点（以当前点为原点归一化）
%           next_point = [next_point;[extract_trajectory(index_in+1,4)-extract_trajectory(index_in,4),extract_trajectory(index_in+1,5)-extract_trajectory(index_in,5)]];%将真实点放在后面
%           [nextPol_point(:,1),nextPol_point(:,2)] = cart2pol(next_point(:,1),next_point(:,2));%转化为极坐标
%           Plo = [Plo;abs(rad2deg(nextPol_point(1,1)-nextPol_point(2,1)))];
%           lo = [lo;abs(nextPol_point(1,2)-nextPol_point(2,2))];
%           if (abs(rad2deg(nextPol_point(1,1)-nextPol_point(2,1)))>15&&abs(rad2deg(nextPol_point(1,1)-nextPol_point(2,1)))<345)||(((nextPol_point(2,2)-nextPol_point(1,2))>0.12)||((nextPol_point(2,2)-nextPol_point(1,2))<-0.24))
%               buxing = buxing + 1;%对不满足条件的计数
%           end
%             做到这里了，做预测
            tic
            MyGA;%用遗传算法求解
            toc
            test_result_block = [test_result_block;[ID index index_in OPT]];%index是轨迹编号；index_in是轨迹内预测点的编号； OPT是优化后的加速度集合
%             Myfmincon;%用fmincon求解
%             以上是遗传算法求解
%             以下是做出预测轨迹的可视化
%             scatter(extract_time_i(2:size(extract_time_i,1),1),extract_time_i(2:size(extract_time_i,1),2),'*','p')%交互对象的
%             hold on
%             for i =1:20
%             scatter(extract_trajectory(index_in+i-1:index_in+i,4),extract_trajectory(index_in+i-1:index_in+i,5),'*','b')
%             hold on
%             scatter(output1(i+1,1),output1(i+1,2),'*','r')
% %             hold on 
% %             scatter(standard_point(i,1),standard_point(i,2),'*','g')
% %             i = i+1;
%             pause(0.5)
%             end
%            [MDE] = ADE(extract_trajectory(index_in:index_in+20,4:5),output1);%计算平均距离误差     
     disp(['已完成',num2str(ID/size(index_all,2)*100),'%'])
end
toc

%以上计算完之后，下面开始计算其误差
MDE = [];%记录误差
for i =1:size(test_result_block,1)
    index_ce = find(input(:,1)==test_result_block(i,2)&(input(:,2)==test_result_block(i,3)));
    Truth_block = input(index_ce : index_ce + perception_time,:);%真实轨迹
    [output,output1,output2] = Excur_predict_2(test_result_block(i,4:size(test_result_block,2)),Truth_block(1,:),Truth_block);%%output是目标值，output1是输出的预测点；output2是输出的风险值；
    clf
    for j =1:20
        scatter(Truth_block(j+1,4),Truth_block(j+1,5),'*','b')
        hold on
        scatter(output1(j+1,1),output1(j+1,2),'*','r')
        pause(0.5)
    end
    [MDE] = [MDE ; ADE(Truth_block(:,4:5),output1)];%计算平均距离误差   
%     pause(2)
    disp(ADE(Truth_block(:,4:5),output1))
end
disp(min(MDE))
disp('done！!!')