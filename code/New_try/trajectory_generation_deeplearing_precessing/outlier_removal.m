%% 本脚本的目标是对更改数据间隔
tic;
%% 读取数据
type = 1;
%车辆类型，1是ES1，2是ES1V，3是EN1V
filename = 'D:\File\Received File\交科赛大三\资料（交科0106）\按照外轮廓四个世界坐标转换后轨迹-初始轨迹\重新编号\数据范围修正\三分类处理完成数据（T=0.12s）（手动筛除异常值）.xlsx';
%将每个轨迹点对应的机动车和非机动车坐标放到同一行上,14列
[data]=xlsread('D:\File\Received File\交科赛大三\资料（交科0106）\按照外轮廓四个世界坐标转换后轨迹-初始轨迹\重新编号\数据范围修正\三分类处理完成数据（T=0.12s）.xlsx',type);
title = {'GlobalTime','X[m]','Y[m]','Vx[m/s]','Vy[m/s]','Ax[m/s2]','Ay[m/s2]','Speed[km/h]','Acceleration[m/s2]','Space[m]','Curvature[1/m]','ID','ID_in','ID_straight','type'};
%将间隔时间改为0.12s
fdata = [];
%由于第一个点和最后一个点参数无法用运动学公式得出，删除最后一个点
if type == 1
    sheetname = 'ES1';
elseif type == 2
    sheetname = 'ES1V';
else
    sheetname = 'EN1V';
end

for i = 1:2%data(end,12)
    i
    ID = find(data(:,12)==i);
    scatter(data(ID,2),data(ID,3),'.','r');%做图
    saveas(gcf,num2str(i), 'png');
end

% xlswrite(filename,[title;num2cell(fdata)],sheetname);

