%% 本脚本的目标是对数据进行预处理，并输出训练样本、验证样本以及测试样本
tic;
%% 读取数据，输入参数
%将每个轨迹点对应的机动车和非机动车坐标放到同一行上,14列
filename = 'C:\Users\honly\Desktop\分类完成数据（T=0.12s）.xlsx';
[E1]=xlsread(filename,1);%东—南左转非机动车
[E1V]=xlsread(filename,2);%东—南左转机动车
[W1V]=xlsread(filename,3);%东—北右转机动车
E1(:,14) = [];
E1V(:,14) = [];
W1V(:,14) = [];
E1= [E1(:,1:11) E1(:,13) E1(:,12) E1(:,14)];
E1V= [E1V(:,1:11) E1V(:,13) E1V(:,12) E1V(:,14)];
W1V= [W1V(:,1:11) W1V(:,13) W1V(:,12) W1V(:,14)];

% scatter(E1(:,2),E1(:,3),'.','r');%做图

% scatter(W1V(:,3),W1V(:,2),'.','r');%做图

%% 这里需要检查轨迹，保证后续的前进方向是从右往左
[E1] = change_rad(E1,90);
[E1V] = change_rad(E1V,90);
[W1V] = change_rad(W1V,90);
%%  输入参数
Num_No=1;%交互的非机动车对象的个数（目前是按照距离最短的计算,参考齐骁6个）
Num_V=0;%交互的机动车个数
perception_time = 17;%即是预测步长  17/33
generating_lengh = perception_time;
n_input=generating_lengh;%样本的输入轨迹点个数
% csvwrite('intrusion_cood_EXXRoad.csv',intrusion_cood_EXXRoad)
global intrusion_cood_E
intrusion_cood_EXXRoad = csvread('intrusion_cood_EXXRoad.csv');%读取机动车道基准信息，表示基准点坐标，里面的排列应该是四个点，当道路纵向向上时，分别为右下、左下、右上、左上
intrusion_cood_E = intrusion_cood_EXXRoad;



%%%去除相同数据
% [E1] = same_out(E1);
% [E1V] = same_out(E1V);
% [W1V] = same_out(W1V);


%%%找到直行非机动车
[E_straight] = [E1(:,1:12) E1(:,14) E1(:,13)];%find_straight(E1,35,60,15,40,-10,10,20,40);


%% 初步的特征矩阵构造  输出E_trajectory
%%%%%%%对E和N处理成特征交互矩阵%%%%%%%
[NVinterract,Vinterract] = DATA_merge (E1,[],E1V,W1V,[]);%%DATA merge
%设置全局变量
% global trajectory_block;
global E_trajectory;
[E_trajectory] = data_handle(E_straight,NVinterract,Vinterract,Num_No,Num_V,1);%!!!将原始数据处理后，弄成特征矩阵 ,最后一个数字表示轨迹中0的个数不能超过此限制

% scatter(E_trajectory(:,4),E_trajectory(:,5),'.','b')
%做交互图
benchmark_EXXRoad = csvread('benchmark_EXXRoad.csv');%读取基准信息
% csvwrite('benchmark_EXXRoad.csv',benchmark_EXXRoad);%读取基准信息


%% 去掉无效交互对象的轨迹样本
N_eist = [];
N_zeros = find(E_trajectory(:,25)==0);
for i = 1:size(N_zeros,1)
    N_eist = [N_eist;E_trajectory(N_zeros(i),1)];
end
N_eist = unique(N_eist);
for j = 1:size(N_eist,1)
    E_trajectory(find(E_trajectory(:,1)==N_eist(j)),:)=[];%去掉缺省值
end

%%%% 以上得到E_trajectory，初步的特征矩阵，上面的确定输出无误之后可以保存下来，调整模型只涉及下面的 data_dividing函数


%%
%%%%%数据分割，包括训练数据、验证数据和测试数据%%%%  接下来是划分数据集，并进行数据处理，归一化，基准化之类的
[mmin,mmax,x_train,y_train,x_ver,y_ver,x_test,y_test,sample_test] = data_dividing(E_trajectory,generating_lengh);%minE表示每个轨迹的轨迹点的数量 n_input表示输入的个数 ,start_point_test,ratio_test,mmin,mmax



%% 删掉一部分无用的特征  主要是终点的速度和加速度特征  这样会导致终点和起点和中间点的长度不同  每个点特征数不一样时启用
% x_train(:,17:size(x_train,2)) = [];%删掉终点的除位置以外的特征；
% x_ver(:,17:size(x_ver,2)) = [];%删掉终点的除位置以外的特征；
% x_test(:,17:size(x_test,2)) = [];%删掉终点的除位置以外的特征；

%% 写出数据%%%
csvwrite('x_train.csv',x_train);%以下都保存到当前目录下了
csvwrite('y_train.csv',y_train);
csvwrite('x_ver.csv',x_ver);
csvwrite('y_ver.csv',y_ver);
csvwrite('x_test.csv',x_test);
csvwrite('y_test.csv',y_test);

testdividing(x_test,'D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\trajectory_generation_deeplearingModel\data_test');  %地址是保存测试样本的地址

%% 去python训练模型和预测，最后得到生成轨迹点，转入脚本可视化验证Visualization_TG；

toc
disp('The job is done!!!')



