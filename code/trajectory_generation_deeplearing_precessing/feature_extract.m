tic;
%读取数据，输入参数
%将每个轨迹点对应的机动车和非机动车坐标放到同一行上,14列
[N1]=xlsread('E:\Prediction_of_BIM\Data_Preparing（三）\data_SH.xlsx',1);
[E1]=xlsread('E:\Prediction_of_BIM\Data_Preparing（三）\data_SH.xlsx',2);
[N1V]=xlsread('E:\Prediction_of_BIM\Data_Preparing（三）\data_SH.xlsx',3);
[E1V]=xlsread('E:\Prediction_of_BIM\Data_Preparing（三）\data_SH.xlsx',4);
[S]=xlsread('E:\Prediction_of_BIM\Data_Preparing（三）\data_SH.xlsx',5);

Num_No=60;%交互的非机动车对象的个数（目前是按照距离最短的计算,参考齐骁6个）
Num_V=20;%交互的机动车个数
n_input=20;%样本的输入轨迹点个数
intrusion_cood_E = csvread('intrusion_cood_E.csv');%读取机动车道基准信息，表示基准点坐标，里面的排列应该是四个点，当道路横向向左时，从上至下，分别是左上、左下、右上、右下的顺序，横坐标-纵坐标
%需要标定的参数
% char_intrusion = 200;%侵入危险度的参数
% M = 100;%取得的上限值，足够大的正数
% frequency_NV = 10^5;%机动车随机点个数
long = 4.5;%非机动车长半轴 原来是5
short = 2.5; %非机动车短半轴  原来是3
% char_end = 6;%终点复杂度的参数
% char_NV = 5;%非机动车的参数
% char_V = 5;%机动车的参数
long_V = 5.5;%机动车长半轴
short_V = 3.5;%机动车短半轴
% NV_index = 0.9;%非机动车危险度陡峭指数，0-1之间
% V_index = 0.9;%机动车危险度陡峭指数，0-1之间
% index_end = 2;%侵入危险的的参数
% % long_Per = 1.8;%感知长轴
% % short_Per = 0.8;%感知短轴
% benchmark_risk = 120 ;%基准风险值
% perception_Radius = 0.3;%感知圆形半径
% max_acc = 0.06;%最大加速度

%不需要标定的参数
perception_time = 20;%感知扇形区域长度,步长数量

%标定后的参数
char_intrusion = OPT(1);
M = OPT(2);
char_end = OPT(3);
char_NV = OPT(4);
char_V = OPT(5);
NV_index = OPT(6);
V_index = OPT(7);
index_end = OPT(8);
max_excur = OPT(9);


%%%去除相同数据
[E1] = same_out(E1);
[E1V] = same_out(E1V);
[N1] = same_out(N1);
[N1V] = same_out(N1V);
[S] = same_out(S);

%做个图
figure(1)%做图
scatter(E_straight(:,2),E_straight(:,3),'.','b')
% hold on
% scatter(N1(:,2),N1(:,3),'.','r')

%%%找到直行非机动车
[E_straight] = find_straight(E1,35,60,15,40,-10,10,20,40);
[N_straight] = find_straight(N1,0,20,40,60,0,20,0,20);


%%%%%%%对E和N处理成特征交互矩阵%%%%%%%
[NVinterract,Vinterract] = DATA_merge (E1,N1,E1V,N1V,S);%%DATA merge
%设置全局变量
global trajectory_block;
global E_trajectory;
[E_trajectory] = data_handle(E_straight,NVinterract,Vinterract,Num_No,Num_V,1);%将原始数据处理后，弄成特征矩阵 ,最后一个数字表示轨迹中0的个数不能超过此限制
[N_trajectory] = data_handle(N_straight,NVinterract,Vinterract,Num_No,Num_V,1);%
% scatter(E_trajectory(:,4),E_trajectory(:,5),'.','b')
%做交互图
benchmark_E = csvread('benchmark_E.csv');%读取基准信息
% csvwrite('benchmark_E.csv',benchmark_E);%读取基准信息
[trajectory_block,trajectory_no] = trajectory_divide(E_trajectory,27,55);%划分为干扰和非干扰,只要靠近机动车的一边  后面的数字是下限和上限，上限55是为了只筛选朝下方越线的
% [EL_co] = elliptical_index(E_trajectory,e,angle);%验证动态交互对象椭圆危险区域的正确性，EL_co是欧式坐标的交互距离
% [~] = inter(trajectory_block,benchmark_E,Num_No,Num_V);%做图




%参数标定
做到标定这里啦


%下面这个式子是计算各个客体的客观危险度，还未感知；
[aim_danger_NV,aim_danger_int,aim_danger_end,aim_danger_V] = Risk_each(intrusion_cood_E,M,frequency_NV,long,short,long_V,short_V,char_intrusion,char_end,char_NV ,char_V,NV_index,V_index,index_end);


读取的文件是到这里的

block_cal;%脚本，预测入侵轨迹
all_cal;%脚本，预测全部轨迹  ，0.3的测试集

disp(['MAX=',num2str(max(DIS(:,3)))])
disp(['Mean=',num2str(mean(DIS(:,3)))])
disp(['Min=',num2str(min(DIS(:,3)))])
% max(Plo)
% Plo = sort(Plo,descend);
% max(lo)
% hist(Plo)
% hist(lo)
% lo(find(lo>0.1))=[];
% hist(all_risk(:,7))

toc
disp('The job is done!!!')


