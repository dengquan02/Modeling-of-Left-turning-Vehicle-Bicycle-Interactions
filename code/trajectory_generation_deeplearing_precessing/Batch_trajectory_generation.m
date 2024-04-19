function [possible_points,status ] = Batch_trajectory_generation(extract_one,perception_time,resolution,mmax,mmin)
%% 本函数的作用是在已知起点的条件下，调用一次pyhon文件，生成所有潜在轨迹，以便后面直接取用；
% resolution = 0.4;
% Horizontal_range = 3;
Perception_interval = resolution/(2^0.5);  %0.4表示离散化的分辨率
perception_Radius = resolution;
V_cos = 15; %最大速度约束

%% 指定横向和纵向的最大加速度
if extract_one(1,14)==2%若是2，则为电动车  前进方向
    a_limit_border = 0.74;%20211018使用的是0.36  %最大值：3.8   %0.259结果用的是0.2703；效果好的时候是平均值0.4；取得是平均值和当前值的最大值  ，目前在尝试百分位数0.74、中位数0.31、众数0.03
elseif extract_one(1,14)==1%若是1，则为自行车
    a_limit_border = 0.5;%20211018使用的是0.22   %最大值：1.58   0.259结果用的是0.05934效果好的时候是平均值0.26；取得是平均值和当前值的最大值，目前在尝试百分位数0.5、中位数0.2、众数0.01
end
a_limit_border = max(a_limit_border,abs(extract_one(1,8)));%当前前进方向加速度和我给的约束，取平均值   a_limit_border = mean([a_limit_border;abs(extract_one(1,8))])+0.05;%当前前进方向加速度和我给的约束，取平均值
if extract_one(1,14)==2%若是2，则为电动车   横向
    a_limit_Horizontal = 0.4;%20211018使用的是0.189   1217之前用的是0.4；% %最大值：3.8   %0.259结果用的是0.2703；效果好的时候是平均值0.4；取得是平均值和当前值的最大值  ，目前在尝试百分位数0.74、中位数0.31、众数0.03
elseif extract_one(1,14)==1%若是1，则为自行车
    a_limit_Horizontal = 0.15;%20211018使用的是0.15    1217之前用的是0.4；% %最大值：1.58   0.259结果用的是0.05934效果好的时候是平均值0.26；取得是平均值和当前值的最大值，目前在尝试百分位数0.5、中位数0.2、众数0.01
end
a_limit_Horizontal = max(a_limit_Horizontal,abs(extract_one(1,9)));%当前前进方向加速度和我给的约束，取平均值    a_limit_Horizontal = mean([a_limit_Horizontal;abs(extract_one(1,9))])+0.1;%当前前进方向加速度和我给的约束，取平均值

%% 计算前进方向的范围
V_max = extract_one(1,10)+(perception_time*0.12)*a_limit_border*3.6;  %   计算可能的最大速度，若大于一定值则约束住  都是km/h
border_near = ceil((min(0,((extract_one(1,6)*(perception_time*0.12)+0.5*a_limit_border*((perception_time*0.12)^2)))+3))/Perception_interval);%搜索远界,算出来的是序号个数为了预测值x方向接近真实值（现在超过了接近值，所以要缩短距离，所以加2）
border_far = ceil((min((extract_one(1,6)*(perception_time*0.12)-0.5*a_limit_border*((perception_time*0.12)^2)))+3)/Perception_interval);%border_far = ceil((min(-4.6,(extract_one(1,6)*(perception_time*0.12)-0.5*a_limit_border*((perception_time*0.12)^2))))/Perception_interval);     %搜索远界，算出来的是序号个数  -4.6是最大横向速度  border_near = ceil((max(extract_one(1,6)*(perception_time*0.12)-0.5*a_limit*((perception_time*0.12)^2),0))/Perception_interval);%搜
if V_max > V_cos  %km/h若速度大于15，则约束住
    border_far = ceil((((-V_cos/3.6)*(perception_time*0.12))/Perception_interval));% 则恒速度过去算了
end
border = [border_near;border_far];
border = sortrows(border);%顺序排序

%% 计算横向的范围
Horizontal_range_1  = ceil(((extract_one(1,7)*(perception_time*0.12)+0.5*a_limit_Horizontal*((perception_time*0.12)^2)+1))/(Perception_interval));   %左界
Horizontal_range_0 = ceil(((extract_one(1,7)*(perception_time*0.12)-0.5*a_limit_Horizontal*((perception_time*0.12)^2)+1))/Perception_interval);   %右界
    
%% 删除文件夹，并重建
delet_file1 = ' D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\Data_processing\ ';
delet_file_1 = rmdir(delet_file1,'s');  % 删除当前路径下名为file的文件夹
delet_file_2 = mkdir('D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\Data_processing', 'data_test');  % 在当前路径创建名为file的文件夹

delet_file2 = ' D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\Data_processing\result_test\ ';
delet_file_11 = rmdir(delet_file2,'s');  % 删除当前路径下名为file的文件夹
delet_file_22 = mkdir('D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\Data_processing', 'result_test'); 

%% 旧方法  以下是对各个点进行分别生成写出
% possible_points = [];%初始可行域
% % optimal_solution = [];
% % SET_Complete_Data_odPoints_output = []; %用来存放已知的起终点信息
% index = 1;
% for i = border(1) : border(2)   %序号个数
%     for j =  min(Horizontal_range_1,Horizontal_range_0) : max(Horizontal_range_1,Horizontal_range_0)  %横向坐标的上下界序号个数
%         %% 生成潜在起终点，并处理成轨迹生成的所需的形式
%         start_point = extract_one(1,4:5);%赋予起点
%         end_point = [i j]*Perception_interval+start_point;%整合成终点， [ x, y]
%         [Complete_Data_odPoints] = Complete_feature_ODpoints(start_point,end_point,extract_one,perception_time);%利用已知起终点位置得到完成深度学习所需数据  Complete_Data_odPoints的形状是 1*14
% %         hold on
% %         scatter(end_point(1),end_point(2))
%         [Complete_Data_odPoints_output] = Normalizating_NEW(Complete_Data_odPoints,2,mmax,mmin);%利用训练深度学习模型的最大值和最小值归一化数据
%         dlmwrite(['E:\Prediction_NV\New_try\Data_processing\data_test\x_test_',num2str(index),'.txt'],Complete_Data_odPoints_output);
% %         disp(Complete_Data_odPoints_output(1:2))
%         possible_points = [possible_points;[i j]]; 
%         index = index +1;
% %         这里要改各自的名字dlmwrite('E:\Prediction_NV\New_try\Data_processing\data_test\Complete_Data_odPoints.txt',Complete_Data_odPoints_output);%写出数据  text格式
%    end
% end

%% 新方法 与上面的只能运行一个   以下是对各个点进行分别生成写出
possible_points = [];%初始可行域
% optimal_solution = [];
% SET_Complete_Data_odPoints_output = []; %用来存放已知的起终点信息
index = 1;
disp(min(Horizontal_range_1,Horizontal_range_0) : max(Horizontal_range_1,Horizontal_range_0)) %横向范围
border_all = border(1) : border(2);%前进方向  
Horizontal_rangeAll = min(Horizontal_range_1,Horizontal_range_0) : max(Horizontal_range_1,Horizontal_range_0); %横向   min(Horizontal_range_1,Horizontal_range_0) : max(Horizontal_range_1,Horizontal_range_0) 
start_point = extract_one(1,4:5);%赋予起点
[perception_point] = search_discretization(perception_Radius,start_point,border_all,Horizontal_rangeAll);%生成所有终点

% truth_input = [extract_one(1,4:9) extract_one(1,14) extract_one(1,15:20) extract_one(1,25)];
% index_end = find((E_trajectory(:,1)==extract_one(1,1))&E_trajectory(:,2)==extract_one(1,2))+16;
% truth_input = [truth_input E_trajectory(index_end,4:9) E_trajectory(index_end,14) E_trajectory(index_end,15:20) E_trajectory(index_end,25)];

for i = 1:size(perception_point,1)
   %% 生成潜在起终点，并处理成轨迹生成的所需的形式
   end_point = perception_point(i,4:5);%读取终点， [ x, y]
   [Complete_Data_odPoints] = Complete_feature_ODpoints(start_point,end_point,extract_one,perception_time)%利用已知起终点位置得到完成深度学习所需数据  Complete_Data_odPoints的形状是 1*14
%  hold on
%  scatter(end_point(1),end_point(2))
   [Complete_Data_odPoints_output] = Normalizating_NEW(Complete_Data_odPoints,2,mmax,mmin);%利用训练深度学习模型的最大值和最小值归一化数据
   dlmwrite(['D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\Data_processing\data_test\x_test_',num2str(index),'.txt'],Complete_Data_odPoints_output);
%  disp(Complete_Data_odPoints_output(1:2))
   possible_points = [possible_points;[perception_point(i,2:3)]]; 
   index = index +1;
%  这里要改各自的名字dlmwrite('E:\Prediction_NV\New_try\Data_processing\data_test\Complete_Data_odPoints.txt',Complete_Data_odPoints_output);%写出数据  text格式
end



 %% 以下是调用python文件对各个点进行轨迹生成
status = system('code.bat');%调用外部程度运行python文件，实现轨迹生成   status是返回值，若为0则说明调用成功； 调用0929_02模型

	%以下是读取所有数据，包括所有潜在轨迹，参考深度学习的可视化
%% 读取该目录下的所有txt文件，即是所有生成轨迹
path = 'D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\Data_processing\result_test\';
namelist = dir('D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\Data_processing\result_test\*.txt');%读取所有txt文件名
file_list = sort_nat({namelist.name}); %对文件名进行排序， 原来是乱序的
leng = length(file_list);%获取总数量
P = cell(1,leng);%定义一个细胞数组，用于存放所有txt文件
for i = 1:leng
    file_name{i}=file_list(1,i);
    file_name_1 = strcat(file_name{i});
    file_name_curent = strcat(path,file_name_1);
    P{1,i} = load(cell2mat(file_name_curent));
end
prediction = P;
pre_data_test = zeros(leng,perception_time*(size(Complete_Data_odPoints,2)/2));%yy是预测值
for i = 1:leng %把预测值放到真值形状
    pre_data_test(i,:)=(reshape(prediction{1,i}',[],1));%变形  (size(Complete_Data_odPoints,2)/2)  是14
end
possible_points = [possible_points pre_data_test];%把序号和待选轨迹拼到一起

%%  后面的都没啥用，测试代码
% figure(9)
% for i = 1:leng
%     zuotu = reshape(pre_data_test(i,:)',[],perception_time)';
%     hold on
%     scatter(zuotu(:,1),zuotu(:,2),'*','r');
% %     i = i+1;
% end
% 
% %% 
% Possible_points = possible_points;
%  Potential_trajectory_allData = reshape(Possible_points(i,3:size(Possible_points,2)),perception_time,[]);%将一行还原成17行*14列  possible_points前面两列是序号
%         %% 以下是逆归一化
%         [Potential_trajectory_allData_output] = Anti_normalizating_NEW(Potential_trajectory_allData,perception_time);%  反归一化，利用之前训练预处理数据的mmaxm和mmin
%         %% 继续计算
%         Potential_trajectory = Potential_trajectory_allData_output(:,1:2);%只取前两列是研究主体位置
% %        %做图出来看一看
%         hold on
%         scatter(Potential_trajectory(:,1),Potential_trajectory(:,2),50,'*','r')  %o v *   %预测轨迹
%         Potential_trajectory_1D = reshape(Potential_trajectory, 1 , []);%
end