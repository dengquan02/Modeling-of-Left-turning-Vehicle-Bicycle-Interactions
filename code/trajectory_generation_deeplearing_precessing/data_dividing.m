%%数据分割%%%%
function [mmin,mmax,x_train,y_train,x_ver,y_ver,x_test,y_test,sample_test] = data_dividing(input,generating_lengh) %start_point_test,ratio_test,mmin,mmax
% input=E_trajectory;
% 以上数据输入为测试时使用；
%% 以下首先开始划分数据集（包括训练集、验证集和测试集）
% 指定比例
p_test=0.1;%测试集占所有数据的比例（其他数据还要进行数据拓展，因此这个比例取小一些）
p_train=0.7;%训练集占训练集和验证集的比例；


%n_input为输入轨迹个数（已知的轨迹个数）
%训练集、验证集、测试集的划分按照0.6 0.2 0.2划分  20个x，1个y  input=(2160,1681)
%x_train=(27216*180) y_train=(27216*9)
%x_ver=(11664*180) y_ver=(11664*9)
%x_test=(216*180) y_test=(216*189)


%% 首先截掉测试集

%%%%%测试集和训练+验证集分开%%%%%%

all_ID=unique(input(:,1));%提取轨迹的ID
t=round(p_test*size(all_ID,1));%测试集数量
nu=randperm(size(all_ID,1));%随机分开，取前t个为测试集数据，后面的是训练集和验证集；
all_ID = all_ID(nu',:);%按照新序号随机排列
data=input;%自立一个，以免污染数据；
data_test = [];
data_train_ver = [];
for i = 1:size(all_ID,1)
    if i <= t
        data_test = [data_test;data(find(data(:,1)==all_ID(i)),:)];
    else
        data_train_ver = [data_train_ver;data(find(data(:,1)==all_ID(i)),:)];
    end
end

%% 下面开始对两个数据集基准化、归一化以及数据拓展；循环取样；

%%%以下分别对两个数据集做样本%%%%%

%% 数据拓展
[sample_test] = data_expand_test(data_test,generating_lengh) ;%拓展测试集
[sample_train_ver] = data_expand(data_train_ver) ;%拓展训练和验证集

%数据拓展完最好保存一下进程，因为上面的数据处理比较耗时，并且对后续没什么影响，可以重复使用进行后面的尝试
% 运行到这里了
%% 下面对样本进行打乱
N_lengh_point = size(sample_test,2);%读取样本的一个点一共有多少个数据
N_lengh_train = 3*N_lengh_point;%读取每个样本一共有多少个数据
N_lengh_test = N_lengh_point * generating_lengh;%test的宽矩阵宽度，即一个样本的特征数


%%%将训练集_验证集和测试集重新赋予形状,变成宽矩阵；
precessing_test=reshape(sample_test',N_lengh_test,[])';%N_lengh表示一个样本的长度；
precessing_train_ver=reshape(sample_train_ver',N_lengh_train,[])';%N_lengh表示训练样本的长度；

%%%%%%将训练集数据打乱%%%%%%%
rrnu=randperm(size(precessing_train_ver,1));   %产生行数的随机排列
precessing_train_ver = precessing_train_ver(rrnu, :); %按照r的随机排列进行重新排列

% 运行到第二个点；
%%%进行数据放缩，每个点以起点为零点变化坐标以后，再除以他们之间的距离。保证数据内部的不变性和数据之间的相似性；基准信息不放缩，宽矩阵
% [ratio_test,start_point_test,data_train_ver,data_test] = scal(data_test,data_train_ver,t,minE,fe,n_input);

%%%%变换形状，准备进行数据归一化%%%%% 变换形状后列数是N_lengh_point，变成窄矩阵
precessing_test=reshape(precessing_test',N_lengh_point,[])';%minE*fe表示测试集每条轨迹的点数*每个点的特征数；
precessing_train_ver=reshape(precessing_train_ver',N_lengh_point,[])';%fe表示测试集每个点的特征数；

%% 这里添加一个内容，是把终点的未知量替换掉（基于运动学公式补充完整）
[precessing_train_ver_output,precessing_test_output] = Replace_feature_ODpoints(precessing_train_ver,precessing_test,generating_lengh);
% precessing_train_ver_output=precessing_train_ver;
% precessing_test_output=precessing_test;
%% 下面进行归一化
char_all=[precessing_train_ver_output;precessing_test_output];%放到一个矩阵里进行归一化；



%% 以上完成数据打乱，开始数据归一化  从这里开始进采用char_all数据
%%%%%数据归一化、输出每个特征值归一化的最小值和最大值，输入的是窄矩阵%%%%
char_all(:,1:4) = [];%删掉前几列的序号


% 增添特征可以从这里开始

%%% 趁机精简一下特征值
char_all_handle = char_all;%
char_all_handle(:,7:9) = [];   %ADE=0.046的时候是：char_all_handle(:,7:10) = [];
char_all_handle(:,15:17) = [];   %ADE=0.046的时候是：char_all_handle(:,14:17) = []; 

char_all_handle_copy=char_all_handle;

[output,mmin,mmax] = Normalizing(char_all_handle);
%output=char_all;


% output(:,7)=char_all_handle(:,7);
% output(:,15)=char_all_handle(:,15);
%% 给每个数据增加比例信息



lin_train_ver=size(precessing_train_ver,1);%读取训练验证集行数(列数是N_lengh_point)
N_lengh_point = size(output,2);%读取样本的一个点一共有多少个数据
N_lengh_train = 3*N_lengh_point;%读取每个样本一共有多少个数据
N_lengh_test = N_lengh_point * generating_lengh;%test的宽矩阵宽度，即一个样本的特征数

% 对训练验证集操作 换成宽矩阵，每行是一个样本
data_train_ver_Nor=output(1:lin_train_ver,:);
data_train_ver_Nor=reshape(data_train_ver_Nor',N_lengh_train,[])';%换成长矩阵，即每行是一个样本；


% 对测试集操作  换成宽矩阵，每行是一个样本
data_test_Nor=output(lin_train_ver+1:size(output,1),:);
data_test_Nor=reshape(data_test_Nor',N_lengh_test,[])';


tr=round(p_train*size(data_train_ver_Nor,1));%读取训练集行数（列数是N_lengh）




%% 赋值%%%%%%%%
x_test = [data_test_Nor(:,1:N_lengh_point) data_test_Nor(:,N_lengh_test-N_lengh_point+1:N_lengh_test)];%取前后两个点作为x
y_test = data_test_Nor(:,N_lengh_point+1:N_lengh_test-N_lengh_point);%取中间的点作为y

x_train = [data_train_ver_Nor(1:tr,1:N_lengh_point) data_train_ver_Nor(1:tr,2*N_lengh_point+1:N_lengh_train)];%取前后两个点作为x
y_train = data_train_ver_Nor(1:tr,N_lengh_point+1:2*N_lengh_point);%取中间的点作为y

x_ver = [data_train_ver_Nor((tr+1):size(data_train_ver_Nor,1),1:N_lengh_point) data_train_ver_Nor((tr+1):size(data_train_ver_Nor,1),2*N_lengh_point+1:N_lengh_train)];%取前后两个点作为x
y_ver = data_train_ver_Nor((tr+1):size(data_train_ver_Nor,1),N_lengh_point+1:2*N_lengh_point);%取中间的点作为y


%% 归一化处理 y
[y_train,x_train] = handle_Y(y_train,x_train) ;
[y_ver,x_ver] = handle_Y(y_ver,x_ver) ;
save data_new2;
end