%% 本脚本的目标是对更改数据间隔
tic;
for type = [1,3]
%% 读取数据
%车辆类型，1是ES1，2是ES1V，3是EN1V
filename = 'C:\Users\honly\Desktop\分类完成数据（T=0.12s）.xlsx';
%将每个轨迹点对应的机动车和非机动车坐标放到同一行上,14列
[data]=xlsread('C:\Users\honly\Desktop\分类完成数据.xlsx',type);
title = {'GlobalTime','X[m]','Y[m]','Vx[m/s]','Vy[m/s]','Ax[m/s2]','Ay[m/s2]','Speed[km/h]','Acceleration[m/s2]','Space[m]','Curvature[1/m]','ID','ID_in','ID_straight','type'};
%将间隔时间改为0.12s
fdata = [];
%由于第一个点和最后一个点参数无法用运动学公式得出，删除最后一个点
delnum = 0;%删除的轨迹数
for i = 1:data(end,12)
    ID = find(data(:,12)==i);
    if length(ID) < 16
        data(ID,:) = [];
        continue;
    end
    data(ID(end-2):ID(end),:) = [];
    data(ID(1):ID(3),:) = [];
    %将间隔时间改为0.12s
    ID = [ID(1:end-6)];
    j = 1;
    while j <= (length(ID)-2)
        fdata = [fdata;data(ID(j),:)];
        j = j + 3;
    end
    %重新编号
    ID = find(fdata(:,12)==i);
    fdata(ID,12) = ones(length(ID),1).*(i-delnum);
    fdata(ID,13) = linspace(1,length(ID),length(ID));
end
if type == 1
    sheetname = 'ES1';
elseif type == 2
    sheetname = 'ES1V';
else
    sheetname = 'OTHER';
end

xlswrite(filename,[title;num2cell(fdata)],sheetname);
disp("finish!")
type
end
