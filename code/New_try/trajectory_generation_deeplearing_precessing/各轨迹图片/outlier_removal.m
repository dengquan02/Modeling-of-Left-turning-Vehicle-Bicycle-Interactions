%% 本脚本的目标是对更改数据间隔
tic;
%% 读取数据
type = 1;
%车辆类型，1是ES1，2是ES1V，3是EN1V
%将每个轨迹点对应的机动车和非机动车坐标放到同一行上,14列
[data]=xlsread('C:\Users\honly\Desktop\分类完成数据（T=0.12s）.xlsx',type);
title = {'GlobalTime','X[m]','Y[m]','Vx[m/s]','Vy[m/s]','Ax[m/s2]','Ay[m/s2]','Speed[km/h]','Acceleration[m/s2]','Space[m]','Curvature[1/m]','ID','ID_in','ID_straight','type'};
fdata = [];
if type == 1
    sheetname = 'ES1';
elseif type == 2
    sheetname = 'ES1V';
else
    sheetname = 'EN1V';
end

for i = 1:data(end,12)
    i
    ID = find(data(:,12)==i);
    scatter(data(ID,2),data(ID,3),'.','r');%做图
%     hold on
%     outliers = find(abs(data(ID,11))>=10);
%     scatter(data(ID(outliers),2),data(ID(outliers),3),'*','b');%做图
    saveas(gcf,num2str(i), 'png');
%     hold off
end

% xlswrite(filename,[title;num2cell(fdata)],sheetname);


