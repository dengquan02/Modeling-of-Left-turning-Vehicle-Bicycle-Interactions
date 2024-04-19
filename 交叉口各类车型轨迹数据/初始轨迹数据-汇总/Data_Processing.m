%% 本脚本的目标是新数据的预处理，包括筛选、处理
tic;
%% 读取数据，输入参数
%将每个轨迹点对应的机动车和非机动车坐标放到同一行上,14列
[Data_1,String_1]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\1-虹梅路江安路东侧-转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选
[Data_2,String_2]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\2-沪闵路桂林路东侧-转换后轨迹数据.xlsx',1);%读取出字符串和数字  看起来数据不怎么样
[Data_3,String_3]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\3-漕溪路漕宝路东侧-转换后轨迹数据.xlsx',1);%读取出字符串和数字  直行数据较好，但突变不多
[Data_4,String_4]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\4-桂林路吴中路东侧-转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_5,String_5]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\5-桂林路吴中路南侧-转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_6,String_6]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\6-斜土路东安路东侧-转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_7,String_7]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\7-斜土路东安路南侧-转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_8,String_8]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\8-斜土路宛平路东侧-转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_9,String_9]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\9-斜土路宛平路南侧-转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_10,String_10]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\10-田林路柳州路西侧-转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_11,String_11]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\11-田林路柳州路南侧-转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_12,String_12]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\12-田林路柳州路西侧-转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_13,String_13]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\13-斜土路宛平路东侧-转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_14,String_14]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\14-沪闵路桂林路东侧-转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_15,String_15]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\15_国定路-邯郸路_转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_16,String_16]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\16_国定路-邯郸路_转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_17,String_17]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\17_隆昌路-长阳路_转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_18,String_18]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\18_隆昌路-长阳路_转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_19,String_19]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\19_隆昌路-长阳路_转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_20,String_20]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\20_隆昌路-长阳路_转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面
[Data_21,String_21]=xlsread('E:\Prediction_NV\NEW_dataset\交叉口各类车型轨迹数据\初始轨迹数据-汇总\21_宁武路-河间路_转换后轨迹数据.xlsx',1);%读取出字符串和数字  数据还可以，需要筛选，比较全面

先处理一下表格1的数据



scatter(Data_2(:,9),Data_2(:,10),'.','r')
做到这里了


%% 数据处理
index_ID = unique(Data_1(:,1));%获取轨迹ID
Data_TureLeft = [];
index = 1;
for i = 1:size(index_ID,1)
    ID = find(Data_1(:,1)==index_ID(i));
    if strcmp(String_1(ID(2),10),'左转')  %判断两个字符串是否相同
        Data_TureLeft = [Data_TureLeft; Data_1(ID,:)];
        index = index + 1;
    end
end
disp(index)
scatter(Data_TureLeft(:,9),Data_TureLeft(:,10),'.','r')
scatter(Data_TureLeft(find(Data_TureLeft(:,1)==10003),9),Data_TureLeft(find(Data_TureLeft(:,1)==10003),10),'.','r')




